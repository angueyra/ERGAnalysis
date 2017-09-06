classdef ERGmerge < handle 
% erg=ERGmerge('subDirectory/',{'h5file1';'h5file2',...})
% after remapping csv file to h5, create new h5 file containing both data
% sets. By default, new h5file will be named ['h5file1' + 'merged']
    properties
        % path
        dirRoot = '~/Documents/LiData/invivoERG/';
        dirData
        dirFile
        dirFull
        dirSave
        
        h5i
        erg
        
        out
    end
    
    properties (SetAccess = private)
    end
    
    methods
        function ergM=ERGmerge(dirData, dirFile)
            dirFile = cellstr(dirFile);
            ergM.dirFile=sprintf('%s_merged',dirFile{1});
            ergM.dirData = dirData;
            ergM.dirFull=sprintf('%s%s/%s.h5',ergM.dirRoot,ergM.dirData,ergM.dirFile);
            ergM.dirSave=sprintf('%s%s/%s.mat',ergM.dirRoot,ergM.dirData,ergM.dirFile);
            
            % load h5 files
            ergM.erg = cell(length(dirFile),1);
            ergM.h5i = cell(length(dirFile),1);
            for i=1:length(dirFile)
                ergM.erg{i} = ERGobj(dirData,dirFile{i});
                ergM.h5i{i} = h5info(sprintf('%s%s/%s.h5',ergM.erg{i}.dirRoot,ergM.erg{i}.dirData,ergM.erg{i}.dirFile));
            end
            
            % make a copy of first h5 file to overwrite
%             if exist(ergM.dirFull,'file')==2
%                 warning('Merged file already exists. Overwriting...');
%             end
            % Seems like this is not the best way. Better to create blank
            % h5 file and then repopulate it
            srcFile = sprintf('%s%s/%s.h5',ergM.dirRoot,dirData,dirFile{1});
            copyfile(srcFile,ergM.dirFull);
            fileattrib(ergM.dirFull,'+w');
            
            % modify or create attributes
            % h5writeatt(ergM.dirFull,'/','creation_date',datestr(now));
%             h5writeatt(ergM.dirFull,'/','genotype','Loon2');

            % read some data
            Chan1 = h5read(ergM.erg{1}.dirFull,'/Chan');
            Chan2 = h5read(ergM.erg{2}.dirFull,'/Chan');
            
            Chan = [Chan1,Chan2];
            % write some data
            h5write(ergM.dirFull,'/Chan', Chan);
%             error('Under construction...')
            %not sure this is the right place to do this. Requires writing
            %a new h5 file (or duplicating one, then creating new groups
            %and repopulating them). Maybe should do it during mapping in
            %python
        end 
        
        
    end
    
    methods (Static=true)
        
    end
end
