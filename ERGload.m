classdef ERGload < handle
% usage (after remapping csv from erg to h5 file using ????.py: 
% erg=ERGload('subDirectory/','h5file')
    properties
        % path
        dirRoot = '/Users/angueyraaristjm/Documents/LiData/invivoERG/';
        dirData
        dirFile
        dirFull
        dirSave
        
        initialparseFlag = 0
        
        info = struct();
        stepnames
        step = struct();
        stepn
    end
    
    properties (SetAccess = private)
    end
    
    methods
        function erg=ERGload(dirData, dirFile)
            if ~ischar(dirData)
                error('dirData must be a string (e.g. ''20160422'')')
            elseif ~ischar(dirFile)
                error('dirFile must be a string (e.g. ''01_1sG'')')
            else
                % file has been previously loaded, parsed and saved
                if exist(sprintf('%s%s/%s.mat',erg.dirRoot,dirData,dirFile),'file')==2
                    temp_esp=load(sprintf('%s/%s',dirData,dirFile));
                    erg=temp_esp.erg;
                else % parse file for the first time
                    if exist(sprintf('%s%s/%s.h5',erg.dirRoot,dirData,dirFile),'file')==2
                        % run py code from here!
                        erg.dirData=dirData;
                        erg.dirFile=dirFile;
                        erg=ERGparse(erg);
                    else
                        error('file <%s.h5> does not exist in <%s>',dirFile,dirData)
                    end
                end
            end
        end 
        
        function erg=ERGparse(erg)
            erg.dirFull=sprintf('%s%s/%s.h5',erg.dirRoot,erg.dirData,erg.dirFile);
            erg.dirSave=sprintf('%s%s/%s.mat',erg.dirRoot,erg.dirData,erg.dirFile);
            h5i = h5info(erg.dirFull);
            
            % info metadata
            for i=1:size(h5i.Attributes,1)
                if iscell(h5readatt(erg.dirFull,'/',h5i.Attributes(i).Name))
                    erg.info.(h5i.Attributes(i).Name)= char(h5readatt(erg.dirFull,'/',h5i.Attributes(i).Name));
                else
                    erg.info.(h5i.Attributes(i).Name)= h5readatt(erg.dirFull,'/',h5i.Attributes(i).Name);
                end
            end
            
            % data pre-allocation
            erg.stepnames=cell(size(h5i.Groups,1),1);
            erg.stepn=NaN(size(h5i.Groups,1),1);
            for i=1:size(h5i.Groups,1)
                erg.stepnames{i}=strrep(h5i.Groups(i).Name,'/','');
                erg.step.(erg.stepnames{i}).t=h5read(erg.dirFull,sprintf('/%s/t',erg.stepnames{i}));
                erg.step.(erg.stepnames{i}).L=NaN(size(erg.step.(erg.stepnames{i}).t));
                erg.step.(erg.stepnames{i}).R=NaN(size(erg.step.(erg.stepnames{i}).t));
                erg.stepn(i)=size(h5read(erg.dirFull,sprintf('/%s/L',erg.stepnames{i})),1);
                erg.step.(erg.stepnames{i}).selL=true(erg.stepn(i),1);
                erg.step.(erg.stepnames{i}).selR=true(erg.stepn(i),1);
            end
            
            erg.initialparseFlag=1;
        end
        
        function erg=ERGsave(erg)
           save(erg.dirSave,'erg')
           fprintf('Saved as %s\n',erg.dirSave);
        end
        
        function[Ltrials,Rtrials] = ERGfetchtrials(erg,stepname)
            Ltrials=h5read(erg.dirFull,sprintf('/%s/L',stepname));
            Rtrials=h5read(erg.dirFull,sprintf('/%s/R',stepname));
        end
    end
    
    methods (Static=true)
        
    end
end