classdef ERGobj < handle
% usage (after remapping csv from erg to h5 file using ????.py: 
% erg=ERGload('subDirectory/','h5file')
    properties
        % path
        dirRoot = '~/Documents/LiData/invivoERG/';
        dirData
        dirFile
        dirFull
        dirSave
        
        initialparseFlag = 0
        
        info = struct();
        stepnames
        step = struct();
        stepn
        
        results
        
        id
        genotype
    end
    
    properties (SetAccess = private)
    end
    
    methods
        function erg=ERGobj(dirData, dirFile)
            if ~ischar(dirData)
                error('dirData must be a string (e.g. ''20160422'')')
            elseif ~ischar(dirFile)
                error('dirFile must be a string (e.g. ''01_1sG'')')
            else % file has been previously loaded, parsed and saved
                if exist(sprintf('%s%s/%s.mat',erg.dirRoot,dirData,dirFile),'file')==2
                    temp_esp=load(sprintf('%s%s/%s.mat',erg.dirRoot,dirData,dirFile));
                    erg=temp_esp.erg;
                    fprintf('Loaded previously saved version!\n')
                    erg.dirRoot = '~/Documents/LiData/invivoERG/';
                    erg.dirFull=sprintf('%s%s/%s.h5',erg.dirRoot,erg.dirData,erg.dirFile);
                    erg.dirSave=sprintf('%s%s/%s.mat',erg.dirRoot,erg.dirData,erg.dirFile);
                else % espion csv file has been remapped to h5 file but not manipulated in matlab
                    if exist(sprintf('%s%s/%s.h5',erg.dirRoot,dirData,dirFile),'file')==2
                        erg.dirData=dirData;
                        erg.dirFile=dirFile;
                        erg=ERGparse(erg);
                    else % espion csv file exist but hasn't been remapped to h5 file
                        if exist(sprintf('%s%s/%s.csv',erg.dirRoot,dirData,dirFile),'file')==2
%                             error('file <%s.h5> does not exist in <%s>\n Remap in Jupyter',dirFile,dirData)
                            fprintf('file <%s.h5> does not exist in <%s>\n',dirFile,dirData)
                            fprintf('\tattempting to run python csv parser:\n')
                            pyout=erg.runpycsvparser;
                            if pyout==0
                                fprintf('\t\tPY_SUCCESS!\n')
                                erg.dirData=dirData;
                                erg.dirFile=dirFile;
                                erg=ERGparse(erg);
                            else
                                fprintf('PY_FAIL\n')
                            end
                        else
                            error('file <%s.csv> does not exist in <%s>',dirFile,dirData)
                        end
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
            erg.id = regexprep(erg.info.ID,'\W','_');
            erg.genotype = erg.info.genotype;
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
            if sum(ismember(erg.stepnames,stepname)) % check if dataset exists in hdf5 file
                Ltrials=h5read(erg.dirFull,sprintf('/%s/L',stepname));
                Rtrials=h5read(erg.dirFull,sprintf('/%s/R',stepname));
            else %provide empty vectors
                Ltrials=[];
                Rtrials=[];
            end
        end
        
        function tAxis = ERGfetchtime(erg,stepname)
            if sum(ismember(erg.stepnames,stepname)) % check if dataset exists in hdf5 file
                tAxis=h5read(erg.dirFull,sprintf('/%s/t',stepname));
            else %provide empty vectors
                tAxis=[];
            end
        end
        
        function trials = ERGseltrials(erg,stepname)
            % get selected trials after erg_screentrials has been run
            trials = struct;
            [Ltrials,Rtrials] = ERGfetchtrials(erg,stepname);
            trials.L = Ltrials(erg.step.(stepname).selL,:);
            trials.R = Rtrials(erg.step.(stepname).selR,:);
        end
        
        
        function iS=Iseries_abpeaks(erg)
            % find peaks of a and b wave for each Step
            % b-wave is measured as [ab] segment
            iS=struct;
            
            switch erg.info.Species
                case 'Mouse'
                    if isempty(regexp(erg.info.Protocol,'Xe','once')) % used Cyan LED protocol
                        iFmap=[0.0001,0.0003,0.001,0.003,0.01,0.03,0.1,0.3,1,3,10,30,100]';
                    else % used Xenon Lamp protocol
                        iFmap=[0.0001,0.0003,0.001,0.003,0.01,0.03,0.1,0.3,1,3,10,30,100,300,1000,3000]';
                    end
                case 'Squirrel'
                    iFmap=[0.01,0.03,0.1,0.3,1,3,10,30,100,300,1000,3000,4000]';
            end
            
            % before I extended the protocol. Manual fix for this ones
            if strcmp(erg.dirData,'20160928/20160928_wl05_2_eml1het/')||strcmp(erg.dirData,'20160928/20160928_wl05_3_wt/')
                iFmap=[0.0001,0.0003,0.001,0.003,0.01,0.03,0.1,0.3,1,3,10,30]';
            end
            
            iS.La_peak=NaN(size(erg.stepnames));
            iS.La_t=NaN(size(erg.stepnames));
            iS.Lb_peak=NaN(size(erg.stepnames));
            iS.Lb_t=NaN(size(erg.stepnames));
            
            iS.Ra_peak=NaN(size(erg.stepnames));
            iS.Ra_t=NaN(size(erg.stepnames));
            iS.Rb_peak=NaN(size(erg.stepnames));
            iS.Rb_t=NaN(size(erg.stepnames));
            
            % for reporting b-wave amplitude
            iS.Lab_peak=NaN(size(erg.stepnames));
            iS.Rab_peak=NaN(size(erg.stepnames));
            
            for i=1:size(erg.stepnames,1)
                
                currStep=erg.stepnames{i};
                tAx=erg.step.(currStep).t;
                L=erg.step.(currStep).L;
                R=erg.step.(currStep).R;
                
                
                if strcmpi(erg.info.Species,'Mouse')
                    alims=~(tAx>0.00 & tAx<0.05); 
                    blims=~(tAx>0.045 & tAx<0.15);
                else
                    alims=~(tAx>0.000 & tAx<0.025); % This works well for Squirrel
                    blims=~(tAx>0.015 & tAx<0.1);   % This works well for Squirrel
                end
                aL=L; aL(alims)=0;
                aR=R; aR(alims)=0;
                
                bL=L; bL(blims)=0;
                bR=R; bR(blims)=0;
                
                iS.La_peak(i)=min(aL);
                iS.La_t(i)=tAx(find(aL==min(aL),1,'first'));
                iS.Ra_peak(i)=min(aR);
                iS.Ra_t(i)=tAx(find(aR==min(aR),1,'first'));
                
                iS.Lb_peak(i)=max(bL);
                iS.Lb_t(i)=tAx(find(bL==max(bL),1,'first'));
                iS.Rb_peak(i)=max(bR);
                iS.Rb_t(i)=tAx(find(bR==max(bR),1,'first'));
                
                % making b-wave amplitude actually be [ab] segment (standard in ERG measurements)
                iS.Lab_peak(i)=iS.Lb_peak(i)-iS.La_peak(i);
                iS.Rab_peak(i)=iS.Rb_peak(i)-iS.Ra_peak(i);
                
                iS.iF(i)=iFmap(str2double(currStep(regexp(currStep,'\d'))));

            end
        end
        
        function rS=recovery_abpeaks(erg)
            % find peaks of a and b wave for each trial in Step01
            % b-wave is measured as [ab] segment
            
            currStep = 'Step01';
            [Ltrials,Rtrials] = ERGfetchtrials(erg,currStep);
            isi=1.5;
            
            rS=struct;
            
            rS.t=(1:1:(size(Ltrials,1)))'.*isi;
            
            rS.La_peak=NaN(size(Ltrials,1),1);
            rS.Lb_peak=NaN(size(Ltrials,1),1);
            rS.La_ttp=NaN(size(Ltrials,1),1);
            rS.Lb_ttp=NaN(size(Ltrials,1),1);
            
            
            
            rS.Ra_peak=NaN(size(Rtrials,1),1);
            rS.Rb_peak=NaN(size(Rtrials,1),1);
            rS.Ra_ttp=NaN(size(Rtrials,1),1);
            rS.Rb_ttp=NaN(size(Rtrials,1),1);
            
            % for reporting b-wave amplitude
            rS.Lab_peak=NaN(size(Rtrials,1),1);
            rS.Rab_peak=NaN(size(Rtrials,1),1);
            
            tAx=erg.step.(currStep).t;
            if strcmpi(erg.info.Species,'Mouse')
                alims=~(tAx>0.00 & tAx<0.05);
                blims=~(tAx>0.045 & tAx<0.15);
            else
                alims=~(tAx>0.000 & tAx<0.025); % This works well for Squirrel
                blims=~(tAx>0.015 & tAx<0.1);   % This works well for Squirrel
            end
            
            for i=1:size(Ltrials,1)
                
                aL=Ltrials(i,:); aL(alims)=0;
                aR=Rtrials(i,:); aR(alims)=0;
                
                bL=Ltrials(i,:); bL(blims)=0;
                bR=Rtrials(i,:); bR(blims)=0;
                
                rS.La_peak(i)=min(aL);
                rS.La_ttp(i)=tAx(find(aL==min(aL),1,'first'));
                rS.Ra_peak(i)=min(aR);
                rS.Ra_ttp(i)=tAx(find(aR==min(aR),1,'first'));
                
                rS.Lb_peak(i)=max(bL);
                rS.Lb_ttp(i)=tAx(find(bL==max(bL),1,'first'));
                rS.Rb_peak(i)=max(bR);
                rS.Rb_ttp(i)=tAx(find(bR==max(bR),1,'first'));
                
                % making b-wave amplitude actually be [ab] segment (standard in ERG measurements)
                rS.Lab_peak(i)=rS.Lb_peak(i)-rS.La_peak(i);
                rS.Rab_peak(i)=rS.Rb_peak(i)-rS.Ra_peak(i);
                
            end
        end
        
        function pyout=runpycsvparser(erg)
            pypath='/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/AnalysisMain/ERGAnalysis/test.py';
            pypath=['~/anaconda/python.app/Contents/MacOS/python ' pypath];
            filepath=sprintf(' "%s"',erg.dirData);
            filename=sprintf(' "%s"',erg.dirFile);
            species=sprintf(' "%s"','Squirrel');
            % run python file through system (UNIX)
%             pyout=system([pypath filepath filename species]);
            error ('Py script not running properly. Reqs. variable input or manual adjustments'); pyout=[];
            % try import sys in python for argument values
        end
    end
    
    methods (Static=true)
        
    end
end
