function [ScratchDir,dc]=ScratchDir_Lookup(varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin==1
        LabDefaults=varargin{1};
    else
        LabDefaults=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['=========================================================================================='])
    disp(['=========================================================================================='])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear ComputerChoices
    %%%%%%%%%%%%%%%
    c=1;
    ComputerChoices(c).Label='Custom';
    ComputerChoices(c).CompNames=[];
    ComputerChoices(c).Users={};
    ComputerChoices(c).VPN=0;
    ComputerChoices(c).OS=[];
    ComputerChoices(c).LocalScratchDir=[];
    %%%%%%%%%%%%%%%
    clear VPNChoices
    %%%%%%%%%%%%%%%
    c=1;
    VPNChoices(c).Label='Custom';
    VPNChoices(c).CompNames=[];
    VPNChoices(c).Users={};
    VPNChoices(c).VPN=1;
    VPNChoices(c).OS=[];
    VPNChoices(c).LocalScratchDir=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DefaultLoadLabel='Computers';
    if exist('LabDefaults')
        if exist(LabDefaults)
%             LoadLabDefaultsChoice = questdlg([LabDefaults,' Exist...Load: ',DefaultLoadLabel,'?'],'Load Lab Defaults?','Load','Skip','Load');
%             switch LoadLabDefaultsChoice
%                 case 'Load'
%                     run(LabDefaults)
%             end
            run(LabDefaults)
        end
    else
        warning('<LabDefaults> Variable Doesnt Exist...')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    AllComputerChoices=[];
    Count1=0;
    for cc=1:length(ComputerChoices)
        Count1=Count1+1;
        AllComputerChoices{Count1}=ComputerChoices(cc).Label;
    end        
    AllVPNChoices=[];
    Count2=0;
    for cc=1:length(VPNChoices)
        Count2=Count2+1;
        AllVPNChoices{Count2}=VPNChoices(cc).Label;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['Finding ScratchDir for ',compName,'...'])
    ScratchDir=[];
    IsVPN=0;
    ComputerChoiceIndex=0;
    if any(findstr(compName, 'vpn'))
        IsVPN=1;
        warning('NOTE: Currently Connected to VPN')
        disp('Please Choose VPN Computer: ')
        [ComputerChoiceIndex, checking] = listdlg('PromptString','Select VPN Computer:','SelectionMode','single','ListString',AllVPNChoices);
        disp(['Selected: ',VPNChoices(ComputerChoiceIndex).Label])
        ScratchDir=VPNChoices(ComputerChoiceIndex).LocalScratchDir;
    else
        for ccc=1:length(AllComputerChoices)
            for cccc=1:length(ComputerChoices(ccc).CompNames)
                if any(strfind(lower(compName),lower(ComputerChoices(ccc).CompNames{cccc})))...
                        &&any(strfind(OS,ComputerChoices(ccc).OS))
                    ComputerChoiceIndex=ccc;
                    disp(['Found!'])
                end
            end
        end
        if ComputerChoiceIndex>0&&ComputerChoiceIndex<=length(AllComputerChoices)
            ScratchDir=ComputerChoices(ComputerChoiceIndex).LocalScratchDir;
        else
            warning('Unable to find computer')
            ScratchDir=[];
        end
    end
    if isempty(ScratchDir)
        warning('Please Select a Local ScratchDir')
        ScratchDir=uigetdir('', 'Pick a LOCAL SCRATCH Directory');
    end    
    if ~strcmp(ScratchDir(length(ScratchDir)),dc)
        ScratchDir=[ScratchDir,dc];
    end
    if ~exist(ScratchDir)
        warning(['MISSING ScratchDir: ',ScratchDir])
        [success,~,~]=mkdir(ScratchDir);
        if success
             disp(['CREATED ScratchDir: ',ScratchDir])
        else
             warning(['UNABLE TO CREATE ScratchDir: ',ScratchDir])
        end
    else
        disp(['VALIDATED  ScratchDir: ',ScratchDir])
    end
    disp(['=========================================================================================='])
    disp(['=========================================================================================='])




end
