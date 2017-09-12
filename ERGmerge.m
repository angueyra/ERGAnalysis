classdef ERGmerge < handle 
% erg=ERGmerge('subDirectory/',{'h5file1';'h5file2',...})
% after remapping csv file to h5, create new h5 file containing both data
% sets. By default, new h5file will be named ['h5file1' + 'merged']
    properties
        % path
        dirRoot = '~/Documents/LiData/invivoERG/';
        dirData
        dirFiles
        dirFile
        dirFull
        dirSave
        
        h5i
        erg
        
        overwriteFlag = 0;
        
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
            rootData=struct;
            stepData=struct('L',struct(),'R',struct(),'t',struct());
            for i=1:length(dirFile)
                ergM.erg{i} = ERGobj(dirData,dirFile{i});
                ergM.h5i{i} = h5info(sprintf('%s%s/%s.h5',ergM.erg{i}.dirRoot,ergM.erg{i}.dirData,ergM.erg{i}.dirFile));
                % compile all root data
                for j=1:length(ergM.h5i{i}.Datasets)
                    fname = ergM.h5i{i}.Datasets(j).Name;
                    if ~isfield(rootData,fname)
                        rootData.(fname)=[];
                    end
                    tempData = h5read(ergM.erg{i}.dirFull,sprintf('/%s',fname));
                    rootData.(fname)=[rootData.(fname);tempData];
                end
                if ~isfield(rootData,'originFile')
                    rootData.('originFile')=[];
                end
                tempOF=i .* ones(length(tempData),1);
                rootData.('originFile')=[rootData.('originFile');tempOF];
                % compile all step data
                for j=1:length(ergM.h5i{i}.Groups)
                    fname = ergM.erg{i}.stepnames{j};
                    [tempL, tempR] = ergM.erg{i}.ERGfetchtrials(fname);
                    if ~isfield(stepData.L,fname)
                        stepData.L.(fname)=[];
                    end
                    if ~isfield(stepData.R,fname)
                        stepData.R.(fname)=[];
                    end
                    stepData.L.(fname)=[stepData.L.(fname);tempL];
                    stepData.R.(fname)=[stepData.R.(fname);tempR];
                    if ~isfield(stepData.t,fname)
                        stepData.t.(fname)=ergM.erg{i}.ERGfetchtime(fname);
                    end
                end
            end
            
            ergM.out = stepData;
            
            if ~ergM.overwriteFlag && exist(ergM.dirFull,'file')==2 % safeguard against overwriting
                fprintf('File has already been created. Not overwriting.\n')
                ergM.bip();
            else
                % create new hdf5 file
                nowFolder = pwd;
                cd (fullfile(ergM.dirRoot,ergM.dirData));
                fcpl = H5P.create('H5P_FILE_CREATE');
                fapl = H5P.create('H5P_FILE_ACCESS');
                fid = H5F.create(sprintf('%s.h5',ergM.dirFile),'H5F_ACC_TRUNC',fcpl,fapl);
                H5F.close(fid);
                cd(nowFolder);
                fileattrib(ergM.dirFull,'+w');
                
                % assume files have identical structure and use #1 as template attributes
                for j=1:length(ergM.h5i{1}.Attributes)
                    Value = ergM.h5i{1}.Attributes(j).Value;
                    if isa(Value,'cell')
                        Value = Value{:};
                    end
                    h5writeatt(ergM.dirFull,'/',ergM.h5i{1}.Attributes(j).Name,Value)
                end
                % compiled root data from all files
                for j=1:length(ergM.h5i{i}.Datasets)
                    fname = ergM.h5i{1}.Datasets(j).Name;
                    h5create(ergM.dirFull,sprintf('/%s',fname),size(rootData.(fname)),'Datatype',class(rootData.(fname)));
                    h5write(ergM.dirFull,sprintf('/%s',fname), rootData.(fname));
                end
                fname='originFile';
                h5create(ergM.dirFull,sprintf('/%s',fname),size(rootData.(fname)),'Datatype',class(rootData.(fname)));
                h5write(ergM.dirFull,sprintf('/%s',fname), rootData.(fname));
                % merged step data from all files
                fnames = fields(stepData.t);
                for j = 1:length(fnames)
                    fname=fnames{j};
                    % left eye
                    h5create(ergM.dirFull,sprintf('/%s/L',fname),size(stepData.L.(fname)),'Datatype',class(stepData.L.(fname)));
                    h5write(ergM.dirFull,sprintf('/%s/L',fname), stepData.L.(fname));
                    % right eye
                    h5create(ergM.dirFull,sprintf('/%s/R',fname),size(stepData.R.(fname)),'Datatype',class(stepData.R.(fname)));
                    h5write(ergM.dirFull,sprintf('/%s/R',fname), stepData.R.(fname));
                    % time axis
                    h5create(ergM.dirFull,sprintf('/%s/t',fname),size(stepData.t.(fname)),'Datatype',class(stepData.t.(fname)));
                    h5write(ergM.dirFull,sprintf('/%s/t',fname), stepData.t.(fname));
                end
            end
            fprintf('In directory:\n\t''%s''\ncreated:\n\t''%s.h5''\n',ergM.dirData,ergM.dirFile);
        end 
        
        
    end
    
    methods (Static=true)
        function bip()
            beep
            pause(0.12)
            beep
            pause(0.12)
            beep
        end
    end
end
