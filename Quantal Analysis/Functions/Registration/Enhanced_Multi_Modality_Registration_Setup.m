%Note to user:
%To alter image enhancements necessary for clean Demon tracking you can
%adjust the StretchLims.  Lower the upper limit to increase contrast but it
%is a percentage of total pixels so you need to compensate when altering
%the DemonReg.Padding size

%Increase Accumulated Field Smoothing or the Demon Smoothing (in temporal
%domain) is helpful to restrict the movement artifacts but may under
%correct.  Decreasing either value will often lead to overcorrection
%artificats.  The sweet spot is DemonReg.AccumulatedFieldSmoothing of 5 +/- 1

        %NOTE: currently adjusting the "Smoothing Demon Fields" with custom
        %moving average filter and Accumulated Field Smoothing by just
        %reducing the field smoothing by size of DemonReg.DynamicSmoothing

    
function [RegistrationSettings,RegEnhancement,RefRegEnhancement,DemonReg]=...
            Enhanced_Multi_Modality_Registration_Setup(StackSaveName,ImageArray,ReferenceImage,AllBoutonsRegion,Crop_Props,...
            ImagingInfo,RegistrationSettings,RegEnhancement,RefRegEnhancement,DemonReg)
    fprintf('====================================================================================\n')
    fprintf('====================================================================================\n')
    disp(['Starting Enhanced_Muli_Modality_Registration_Setup for: ',StackSaveName])
    fprintf('====================================================================================\n')
    fprintf('====================================================================================\n')
    [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
    close all
    warning on all
    warning off backtrace
    warning off verbose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TestFrames=[1];
    if ~isfield(DemonReg,'BorderAdjustSize')
        DemonReg.BorderAdjustSize=10;
    end
    if ~isfield(DemonReg,'BorderAdjustFilterRadius_px')
        DemonReg.BorderAdjustFilterRadius_px=10;
    end
    if ~isfield(DemonReg,'CoarseTranslation')
        warning('Adding DemonReg.CoarseTranslation')
        switch ImagingInfo.ModalityType
            case 1
                DemonReg.CoarseTranslation=1;
            case 2
                DemonReg.CoarseTranslation=0;
            case 3
                DemonReg.CoarseTranslation=0;
        end
    end
    if ~isfield(DemonReg,'CoarseTranslationMode')
        warning('Adding DemonReg.CoarseTranslationMode')
        switch ImagingInfo.ModalityType
            case 1
                DemonReg.CoarseTranslationMode=1;
            case 2
                DemonReg.CoarseTranslationMode=1;
            case 3
                DemonReg.CoarseTranslationMode=1;
        end
    end
    if ~isfield(RefRegEnhancement,'DemonMask')
        DemonReg.DemonMask=[];
    end
    if ~isfield(RegEnhancement,'EnhanceFilterSize_um')
        RegEnhancement.EnhanceFilterSize_um=2;%9
        RegEnhancement.EnhanceFilterSigma_um=0.2;%1
        RegEnhancement.EnhanceFilterSigma_px=...
            RegEnhancement.EnhanceFilterSigma_um/ImagingInfo.PixelSize;
        RegEnhancement.EnhanceFilterSize_px=...
            ceil(RegEnhancement.EnhanceFilterSize_um/ImagingInfo.PixelSize);
    if rem(RegEnhancement.EnhanceFilterSize_px,2)==0
        RegEnhancement.EnhanceFilterSize_px=RegEnhancement.EnhanceFilterSize_px+1;
    end
    end
    if ~isfield(RefRegEnhancement,'EnhanceFilterSize_um')
        RefRegEnhancement.EnhanceFilterSize_um=RegEnhancement.EnhanceFilterSize_um;
        RefRegEnhancement.EnhanceFilterSigma_um=RegEnhancement.EnhanceFilterSigma_um;
        RefRegEnhancement.EnhanceFilterSigma_px=...
            RefRegEnhancement.EnhanceFilterSigma_um/ImagingInfo.PixelSize;
        RefRegEnhancement.EnhanceFilterSize_px=...
            ceil(RefRegEnhancement.EnhanceFilterSize_um/ImagingInfo.PixelSize);
    if rem(RefRegEnhancement.EnhanceFilterSize_px,2)==0
        RefRegEnhancement.EnhanceFilterSize_px=RefRegEnhancement.EnhanceFilterSize_px+1;
    end
    end
    PREVIOUS_ReferenceImage_Padded_Masked_Filtered_Enhanced=[];
    PREVIOUS_TestImage_Padded_Masked_Filtered_Enhanced=[];
    DilateRegion=1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SettingUpRegistration=1;
    ImportChoice = questdlg({['Currently Setting Up: ',StackSaveName];...
        'Do you want to import settings from another file?';...
        'You can also do a Import ONLY where you skip all setting adjustments';...
        'However this is NOT recommended';...
        'When Importing Make sure you match protocol!'},...
        'Import Registration Settings?','Import and Check','Import ONLY','Define','Define');
    if strcmp(ImportChoice,'Import and Check')
        SettingUpRegistration=1;
        ImportSettings=1;
    elseif strcmp(ImportChoice,'Import ONLY')
        SettingUpRegistration=0;
        ImportSettings=1;
    elseif strcmp(ImportChoice,'Define')
        SettingUpRegistration=1;
        ImportSettings=0;
    else
        SettingUpRegistration=1;
        ImportSettings=0;
    end
    if ImportSettings
        TempCurrentDir=cd;
        [TempParentDir, ~] = fileparts(TempCurrentDir);
        cd(TempParentDir);

        FileSuffix='_Analysis_Setup.mat';
        [LoadingFile, LoadingDir, ~] = uigetfile( ...
        {   '*_Analysis_Setup.mat','_Analysis_Setup.mat';...
           }, ...
           ['Pick _Analysis_Setup.mat File for parameters to import for: ',StackSaveName]);
        LoadingStackSaveName=LoadingFile(1:length(LoadingFile)-length(FileSuffix));
        FileSuffix='_Analysis_Setup.mat';
        fprintf(['Loading: ',StackSaveName,FileSuffix,'...'])
        save([CurrentScratchDir,StackSaveName,FileSuffix],...
            'RegistrationSettings',...
            'DemonReg',...
            'RegEnhancement',...
            'RefRegEnhancement')
        
        cd(TempCurrentDir)
        clear TempCurrentDir TempParentDir
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while SettingUpRegistration
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SettingUp=1;
        while SettingUp

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             ModeChoice = questdlg('Registration Setup/Adjustment Mode?','Setup/Adjustment Mode?','Beginner','Intermediate','Advanced','Advanced');
%             if strcmp(ModeChoice,'Advanced')
%                 TutorialNotes=0;
%                 AdvancedMode=1;
%             elseif strcmp(ModeChoice,'Intermediate')
%                 TutorialNotes=1;
%                 AdvancedMode=1;
%             elseif strcmp(ModeChoice,'Beginner')
%                 TutorialNotes=1;
%                 AdvancedMode=0;
%             end
            ModeChoice = questdlg('Registration Setup/Adjustment Mode?','Setup/Adjustment Mode?','Hints ON','Hints OFF','Hints OFF');
            if strcmp(ModeChoice,'Hints OFF')
                TutorialNotes=0;
            elseif strcmp(ModeChoice,'Hints ON')
                TutorialNotes=1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if TutorialNotes
                Instructions={'General Settings';...
                    'RegistrationClass (1 first image of episode, 2 All Images w/Blocks): Important distinction here. We can either register just the first of each episode to the master reference image, after which all subsequent frames will be shifted by the same amount or we can register each frame individually in comparision to the master ReferenceImage. The former method is ONLY safe to use when using very short imaging windows';...
                    'RegistrationMethod (1 OLD, 2 DFT,3 DFTDemon(rec)): Old method uses pixel limited whole NMJ coarse registration and then bouton specific rigid registrations. This can create edge artificats between bouton regions and is now outdated';...
                    'DFT refers to the sub-pixel registration method that performs a rigid transformation but can interpolate within pixels to generate a less jittery result. Jitters here refer to pixel-pixel jitters that result from a pixel limted registration';...
                    'Currently DFTDemon option 3 will peform coarse, sub-pixel and demons (non-rigid) registrations in that order and produces by far the best result when set up properly';...
                    'the tradeoff is that it takes MUCH MUCH longer and is more sensitive to difference in the contrast enhancement.';...
                    'CoarseReg_MinCorrValue CoarseReg_MaxShiftX_um (um) CoarseReg_MaxShiftY_um (um) are all used by the Coarse_Reg.m funciton to peform a rigid registration by normxcorr2.m used by the CorrRegionImage.m function';...
                    'Coarse registration is used and very useful for all registration methods because it can help get images closer prior to DFT or Demons';...
                    };
                    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                        TutorialNotes=0;
                    end
            end

            
            warning on
            warning(['RegistrationClass 1 = Short Episodic, 2 = Streaming'])
            warning(['RegistrationMethod 1 = Simple, 2 = SubPixel ONLY, 3 = SubPx and Demon (Recommended)'])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            prompt = {  'RegistrationClass (1 first image of episode, 2 All Images w/Blocks)',...
                        'RegistrationMethod (1 OLD, 2 DFT,3 DFTDemon(rec))',...
                        'CoarseReg_MinCorrValue','CoarseReg_MaxShiftX_um (um)','CoarseReg_MaxShiftY_um (um)',...
                        };
            dlg_title = 'Some Basic Registration settings';
            num_lines = 1;
            def = {num2str(RegistrationSettings.RegistrationClass),...
                num2str(RegistrationSettings.RegistrationMethod),...
                num2str(RegistrationSettings.CoarseReg_MinCorrValue),...
                num2str(RegistrationSettings.CoarseReg_MaxShiftX_um),...
                num2str(RegistrationSettings.CoarseReg_MaxShiftY_um),...
                };
            answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            RegistrationSettings.RegistrationClass=str2num(answer{1});
            RegistrationSettings.RegistrationMethod=str2num(answer{2});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            RegistrationSettings.CoarseReg_MinCorrValue=str2num(answer{3});
            RegistrationSettings.CoarseReg_MaxShiftX_um=str2num(answer{4});
            RegistrationSettings.CoarseReg_MaxShiftY_um=str2num(answer{5});
            RegistrationSettings.CoarseReg_MaxShiftX=round(RegistrationSettings.CoarseReg_MaxShiftX_um/ImagingInfo.PixelSize);
            RegistrationSettings.CoarseReg_MaxShiftY=round(RegistrationSettings.CoarseReg_MaxShiftY_um/ImagingInfo.PixelSize);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            run('Quantal_Analysis_BleachCorr_Setup.m')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GoodSettings=questdlg('Are you happy with the settings or do you want to redo?','Redo Settings?','Good','Redo','Good');
            switch GoodSettings
                case 'Good'
                    SettingUp=0;
                case 'Redo'
                    SettingUp=1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Contrast Enhancments
        SettingUp=1;
        while SettingUp&&(RegistrationSettings.RegistrationMethod==2||RegistrationSettings.RegistrationMethod==3)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Padding to avoid edge artifacts
            warning('Padding helps to avoid loosing the demon registration at the edges of the image')
            warning(['PadValue_Method 1 = median (recommended), 2 = mean, 3 = min'])
            if TutorialNotes
                Instructions={'Registration Padding Settings';...
                    'PadValue_Method (0-3) and Padding (px): all registration algorithms perform a little better with parts of the NMJ close to the edge of the imaging window when you add some padding to the image. 0 will turn off but I do not recommend turning off. When we pad the image we want to fill the padded region with "Background" pixels so you do not create artifical edges that the registration algorithm will pay attention to';...
                    'for Options 1-3 the value of of the padded region is set by one of these: PadValue_Method==1 Pad_Value=median(ReferenceImage(:)) PadValue_Method==2 Pad_Value=mean(ReferenceImage(:)) PadValue_Method==3 Pad_Value=min(ReferenceImage(:))';...
                    'DFT_Pad_Enhance (1/0): this is often helpful to enhance prior to performing sub-pixel reg while hte enhancement is required for Demons to work';...
                    'DemonReg.BorderAdjustSize (px) and BorderAdjustFilterRadius_px (px disk radius): also both help with making sure that the edges of the Image-Pad region dont contain any sharp edges that the registration will pay attention to'};
                TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                    TutorialNotes=0;
                end
            end

            prompt = {'PadValue_Method (0-3):','Padding (px):','DFT_Pad_Enhance (1/0)',...
                'DemonReg.BorderAdjustSize (px)','BorderAdjustFilterRadius_px (px disk radius)'};
            dlg_title = ['Define Padding Settings'];
            num_lines = 1;
            def = {num2str(DemonReg.PadValue_Method),num2str(DemonReg.Padding),num2str(DemonReg.DFT_Pad_Enhance),...
                num2str(DemonReg.BorderAdjustSize),num2str(DemonReg.BorderAdjustFilterRadius_px)};
            answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
            DemonReg.PadValue_Method=                   str2num(answer{1});
            DemonReg.Padding=                           str2num(answer{2});
            DemonReg.DFT_Pad_Enhance=                   str2num(answer{3});
            DemonReg.BorderAdjustSize=                  str2num(answer{4});   
            DemonReg.BorderAdjustFilterRadius_px=       str2num(answer{5});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %ReferenceImage Enhancements
            cont1=1;
            while cont1
                if TutorialNotes
                    Instructions={'REFERENCE IMAGE ENHANCEMENT SETTINGS';...
                                'Filter_Enhanced (1/0), EnhanceFilterSigma_um and EnhanceFilterSize_um: can help clean up the data a little before contrasting to provide a better contrast enhancement or to suppress active AZs whose activity may throw off the registration if too strong';...
                                'These next settings will be used by the Zach_enhanceContrastForDemon.m function to enhance contrast (actually used both before and after biasing).'
                                'StretchLimParams Low and High(0-1): allow you to adjust the effective normalized contrast values for the image';...
                                'weinerParams: these are set in pixel sizes and should be both modified together and used by the weiner2.m function which is a "2-D adaptive noise-removal filter" used in Zach_enhanceContrastForDemon.m';...
                                'openParams (px disk Radius): used by imopen.m function within Zach_enhanceContrastForDemon.m';...
                                'MaskSplitPercentage (0-1) and MaskSplitDilate (px): will help alter the bouton region used for biasing by performing an imdilate with a box of the size indicated';...
                                'Bias_Region (1/0) ,BiasRatios, BiasRatioDiv, BiasProportion: are all settings that allow you to use the bouton region to help bias the contrast enhancement. This way only the relevant sectors should be strongly enhanced while outside your region will be suppressed';...
                            };
                    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                        TutorialNotes=0;
                    end
                end
                prompt = {  'REF Filter_Enhanced (1/0):',...
                            'REF EnhanceFilterSigma_um:',...
                            'REF EnhanceFilterSize_um:',...
                            'REF StretchLimParams Low(0-1):',...
                            'REF StretchLimParams High(0-1):',...
                            'REF weinerParams 1 (px; match 2):',...
                            'REF weinerParams 2 (px; match 1):',...
                            'REF openParams (px disk Radius):',...
                            'REF MaskSplitPercentage (0-1):',...
                            'REF MaskSplitDilate (px):',...
                            'REF Bias_Region (1/0):',...
                            'REF BiasRatios:',...
                            'REF BiasRatioDiv:',...
                            'REF BiasProportion:',...
                            };
                dlg_title = ['Define REFERENCE IMAGE Contrast Enhancements'];
                num_lines = 1;
                def = {     num2str(RefRegEnhancement.Filter_Enhanced),num2str(RefRegEnhancement.EnhanceFilterSigma_um),num2str(RefRegEnhancement.EnhanceFilterSize_um),...
                            num2str(RefRegEnhancement.StretchLimParams(1)),num2str(RefRegEnhancement.StretchLimParams(2)),...
                            num2str(RefRegEnhancement.weinerParams(1)),num2str(RefRegEnhancement.weinerParams(2)),num2str(RefRegEnhancement.openParams),...
                            num2str(RefRegEnhancement.MaskSplitPercentage),num2str(RefRegEnhancement.MaskSplitDilate),...
                            num2str(RefRegEnhancement.Bias_Region),num2str(RefRegEnhancement.BiasRatios),...
                            num2str(RefRegEnhancement.BiasRatioDiv),num2str(RefRegEnhancement.BiasProportion),...
                            };
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);
                RefRegEnhancement.Filter_Enhanced=        str2num(answer{1});
                RefRegEnhancement.EnhanceFilterSigma_um=  str2num(answer{2});
                RefRegEnhancement.EnhanceFilterSize_um=   str2num(answer{3});

                RefRegEnhancement.StretchLimParams(1)=    str2num(answer{4});
                RefRegEnhancement.StretchLimParams(2)=    str2num(answer{5});
                RefRegEnhancement.weinerParams(1)=        str2num(answer{6});
                RefRegEnhancement.weinerParams(2)=        str2num(answer{7});
                RefRegEnhancement.openParams=             str2num(answer{8});

                RefRegEnhancement.MaskSplitPercentage=    str2num(answer{9});
                RefRegEnhancement.MaskSplitDilate=        str2num(answer{10});

                RefRegEnhancement.Bias_Region=            str2num(answer{11});
                RefRegEnhancement.BiasRatios=             str2num(answer{12});
                RefRegEnhancement.BiasRatioDiv=           str2num(answer{13});
                RefRegEnhancement.BiasProportion=         str2num(answer{14});

                RefRegEnhancement.EnhanceFilterSigma_px=...
                    RefRegEnhancement.EnhanceFilterSigma_um/ImagingInfo.PixelSize;
                RefRegEnhancement.EnhanceFilterSize_px=...
                    ceil(RefRegEnhancement.EnhanceFilterSize_um/ImagingInfo.PixelSize);
                if rem(RefRegEnhancement.EnhanceFilterSize_px,2)==0
                    RefRegEnhancement.EnhanceFilterSize_px=RefRegEnhancement.EnhanceFilterSize_px+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Set up DemonReg.Padding and Masking regions
                AllBoutonsRegionPerim=bwperim(AllBoutonsRegion);
                [EnhanceRegionBorderLines]=FindROIBorders(AllBoutonsRegion,DilateRegion);


                [BorderY BorderX] = find(AllBoutonsRegionPerim);
                AllBoutonsRegion_Mask=ones(size(AllBoutonsRegion));
                AllBoutonsRegion_Padded = padarray(AllBoutonsRegion,[DemonReg.Padding DemonReg.Padding],0);
                [EnhanceRegionPaddedBorderLines]=FindROIBorders(AllBoutonsRegion_Padded,DilateRegion);
                AllBoutonsRegion_Mask_Padded = padarray(AllBoutonsRegion_Mask,[DemonReg.Padding DemonReg.Padding],1);
                for j=1:RefRegEnhancement.BiasRatios
                        Temp=imdilate(AllBoutonsRegion,ones(j*RefRegEnhancement.BiasRatioDiv));
                        AllBoutonsRegion_Mask=AllBoutonsRegion_Mask+Temp;
                        Temp=imdilate(AllBoutonsRegion_Padded,ones(j*RefRegEnhancement.BiasRatioDiv));
                        AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded+Temp;
                end
                AllBoutonsRegion_Mask=AllBoutonsRegion_Mask/max(AllBoutonsRegion_Mask(:));
                AllBoutonsRegion_Mask=AllBoutonsRegion_Mask*RefRegEnhancement.BiasProportion+(1-RefRegEnhancement.BiasProportion);
                AllBoutonsRegion_Mask_Crop=imcrop(AllBoutonsRegion_Mask,Crop_Props.BoundingBox);

                AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded/max(AllBoutonsRegion_Mask_Padded(:));
                AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded*RefRegEnhancement.BiasProportion+(1-RefRegEnhancement.BiasProportion);

    %             %Determine Value to use for filling Pad area
    %             if DemonReg.PadValue_Method==1
    %                 ReferenceImage_Pad_Value=median(ReferenceImage(:));
    %             elseif DemonReg.PadValue_Method==2
    %                 ReferenceImage_Pad_Value=mean(ReferenceImage(:));
    %             elseif DemonReg.PadValue_Method==3
    %                 ReferenceImage_Pad_Value=min(ReferenceImage(:));
    %             else
    %                 ReferenceImage_Pad_Value=0;
    %             end
    %             %Pad Border
    %             ReferenceImage_Padded = padarray(ReferenceImage,[DemonReg.Padding DemonReg.Padding],ReferenceImage_Pad_Value);
    %             %Smooth pad interface border
    %             BorderAdjust1=zeros(size(AllBoutonsRegion_Mask_Padded));
    %             BorderAdjust1(1+DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,1)-DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,2)-DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2)=1;
    %             BorderAdjust2=zeros(size(AllBoutonsRegion_Mask_Padded));
    %             BorderAdjust2(1+DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,1)-DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,2)-DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2)=1;
    %             BorderAdjust=BorderAdjust1+BorderAdjust2;
    %             BorderAdjust(BorderAdjust==0)=1;
    %             BorderAdjust(BorderAdjust==2)=0;
    %             ReferenceImage_Padded= roifilt2(fspecial('disk', 10),double(ReferenceImage_Padded),logical(BorderAdjust));
    %             %Enhance once to set up ROIs
    %             if RefRegEnhancement.Filter_Enhanced
    %                 Temp_ReferenceImage_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(ReferenceImage_Padded), fspecial('gaussian', RefRegEnhancement.EnhanceFilterSize_um,  RefRegEnhancement.EnhanceFilterSigma_um)),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             else
    %                 Temp_ReferenceImage_Enhanced=Zach_enhanceContrastForDemon(uint16(ReferenceImage_Padded),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             end
    %             ReferenceImage_Enhanced_Mask=Temp_ReferenceImage_Enhanced;
    %             ReferenceImage_Enhanced_Mask(ReferenceImage_Enhanced_Mask<RefRegEnhancement.MaskSplitPercentage*max(Temp_ReferenceImage_Enhanced(:)))=0;
    %             ReferenceImage_Enhanced_Mask(ReferenceImage_Enhanced_Mask>=RefRegEnhancement.MaskSplitPercentage*max(Temp_ReferenceImage_Enhanced(:)))=1;
    %             ReferenceImage_Enhanced_Mask=imdilate(ReferenceImage_Enhanced_Mask,ones(RefRegEnhancement.MaskSplitDilate));
    %             %Pick Mask that overlaps with AllBoutonsRegion
    %             [~,NumRegions] = bwlabel(AllBoutonsRegion_Padded);
    %             AllBoutounsRegion_Padded_ROIs=bwconncomp(AllBoutonsRegion_Padded);
    %             AllBoutounsRegion_Padded_ROIs_RegionProps = regionprops(AllBoutounsRegion_Padded_ROIs,'PixelList');
    %             ReferenceImage_Enhanced_Mask_MatchedROI=zeros(size(ReferenceImage_Enhanced_Mask));
    %             for z=1:NumRegions
    %                 cont=1;
    %                 k=1;
    %                 while cont
    %                      TempROI = bwselect(ReferenceImage_Enhanced_Mask, AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2));
    %                      if any(TempROI(:)>0)
    %                          ReferenceImage_Enhanced_Mask_MatchedROI=ReferenceImage_Enhanced_Mask_MatchedROI+TempROI;
    %                          cont=0;
    %                      elseif k>=size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
    %                          cont=0;
    %                      else
    %                          k=k+1;
    %                      end
    %                 end
    %             end
    %             %Set up Bias with the new ROIs
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ones(size(ReferenceImage_Enhanced_Mask_MatchedROI));
    %             for j=1:RefRegEnhancement.BiasRatios
    %                 Temp=imdilate(ReferenceImage_Enhanced_Mask_MatchedROI,ones(j*RefRegEnhancement.BiasRatioDiv));
    %                 ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ReferenceImage_Enhanced_Mask_MatchedROI_Biased+Temp;
    %             end
    %             clear Temp
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ReferenceImage_Enhanced_Mask_MatchedROI_Biased/max(ReferenceImage_Enhanced_Mask_MatchedROI_Biased(:));
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ReferenceImage_Enhanced_Mask_MatchedROI_Biased*RefRegEnhancement.BiasProportion+(1-RefRegEnhancement.BiasProportion);
    %             %use the dilated region for filtereing anything outside the regions
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask=ReferenceImage_Enhanced_Mask_MatchedROI_Biased;
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask==min(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask(:)))=0;
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask=logical(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask);
    %             %Apply bias
    %             if RefRegEnhancement.Bias_Region
    %                 ReferenceImage_Padded_Biased=double(ReferenceImage_Padded).*double(ReferenceImage_Enhanced_Mask_MatchedROI_Biased);
    %             else
    %                 ReferenceImage_Padded_Biased=ReferenceImage_Padded;
    %             end
    %             %filter all pixels outside of the region
    %             ReferenceImage_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(ReferenceImage_Padded_Biased),~logical(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask));
    %             if RefRegEnhancement.Filter_Enhanced
    %                 ReferenceImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(ReferenceImage_Padded_Masked_Filtered), fspecial('gaussian', RefRegEnhancement.EnhanceFilterSize_um,  RefRegEnhancement.EnhanceFilterSigma_um)),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             else
    %                 ReferenceImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(uint16(ReferenceImage_Padded_Masked_Filtered),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             end             
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             
    %                 FigureSize=[size(ReferenceImage_Padded,2)*3,size(ReferenceImage_Padded,1)*2];
    %                 if FigureSize(2)>ScreenSize(4)-150
    %                     ExportScalarModifier=(ScreenSize(4)-150)/FigureSize(2);
    %                     FigureSize=round(FigureSize*ExportScalarModifier);
    %                 end
    %                 if FigureSize(1)>ScreenSize(3)
    %                     ExportScalarModifier=ScreenSize(3)/FigureSize(1);
    %                     FigureSize=round(FigureSize*ExportScalarModifier);
    %                 end
    %                 %%%%%%%%%%%
    %                 figure('name',[StackSaveName,' ','ReferenceImage Enhancements'])
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,1,[0,0],[0,0],[0,0])
    %                 imagesc(ReferenceImage)
    %                 axis equal tight
    %                 colormap('jet')
    %                 hold on
    %                 text(size(ReferenceImage,2)*0.01,size(ReferenceImage,1)*0.05,[StackSaveName,' ','ReferenceImage'],'fontsize',12,'color','w','interpreter','none')
    %                 plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionBorderLines)
    %                     plot(EnhanceRegionBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,2,[0,0],[0,0],[0,0])
    %                 imagesc(ReferenceImage_Padded)
    %                 axis equal tight
    %                 colormap('jet')
    %                 hold on
    %                 text(size(ReferenceImage_Padded,2)*0.01,size(ReferenceImage_Padded,1)*0.05,['ReferenceImage Padded and EdgeFixed'],'fontsize',12,'color','w')
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionPaddedBorderLines)
    %                     plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,3,[0,0],[0,0],[0,0]),imagesc(ReferenceImage_Padded_Masked_Filtered)
    %                 axis equal tight
    %                 colormap('jet'),
    %                 hold on
    %                 text(size(ReferenceImage_Padded,2)*0.01,size(ReferenceImage_Padded,1)*0.05,['ReferenceImage Masked and Filtered'],'fontsize',12,'color','w')
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionPaddedBorderLines)
    %                     plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,4,[0,0],[0,0],[0,0])
    %                 imagesc(ReferenceImage_Padded_Masked_Filtered_Enhanced)
    %                 axis equal tight
    %                 colormap('jet')
    %                 hold on
    %                 text(size(ReferenceImage_Padded,2)*0.01,size(ReferenceImage_Padded,1)*0.05,['ReferenceImage Final Enhanced'],'fontsize',12,'color','w')
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionPaddedBorderLines)
    %                     plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 if ~isempty(PREVIOUS_ReferenceImage_Padded_Masked_Filtered_Enhanced)
    %                     
    %                     
    %                     subtightplot(2,3,5,[0,0],[0,0],[0,0])
    %                     imagesc(PREVIOUS_ReferenceImage_Padded_Masked_Filtered_Enhanced)
    %                     axis equal tight
    %                     colormap('jet')
    %                     hold on
    %                     text(size(ReferenceImage_Padded,2)*0.01,size(ReferenceImage_Padded,1)*0.05,['Previous Final Enhanced REFERENCE'],'fontsize',12,'color','w')
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                     for j=1:length(EnhanceRegionPaddedBorderLines)
    %                         plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                             EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                             ':','color','w','linewidth',0.5)
    %                     end
    %                     set(gca,'xtick',[],'ytick',[]);
    %                 end
    %                 %%%%%%%%%%%%%%%%%%%%%%
    %                 set(gcf,'position',[0 50,FigureSize])
    %                 drawnow
    %                 clear BorderAdjust BorderAdjust1 BorderAdjust2
    %             


                if ~isempty(PREVIOUS_ReferenceImage_Padded_Masked_Filtered_Enhanced)
                    FigureSize=[size(ReferenceImage_Padded,2)*1,size(ReferenceImage_Padded,1)*1];
                    if FigureSize(2)>ScreenSize(4)-150
                        ExportScalarModifier=(ScreenSize(4)-150)/FigureSize(2);
                        FigureSize=round(FigureSize*ExportScalarModifier);
                    end
                    if FigureSize(1)>ScreenSize(3)
                        ExportScalarModifier=ScreenSize(3)/FigureSize(1);
                        FigureSize=round(FigureSize*ExportScalarModifier);
                    end
                    FigureSize1=[size(ReferenceImage_Padded,2)*3,size(ReferenceImage_Padded,1)*2];
                    if FigureSize1(2)>ScreenSize(4)-150
                        ExportScalarModifier=(ScreenSize(4)-150)/FigureSize1(2);
                        FigureSize1=round(FigureSize1*ExportScalarModifier);
                    end
                    if FigureSize1(1)>ScreenSize(3)
                        ExportScalarModifier=ScreenSize(3)/FigureSize1(1);
                        FigureSize1=round(FigureSize1*ExportScalarModifier);
                    end
                    subtightplot(1,1,1,[0,0],[0,0],[0,0])
                    imagesc(PREVIOUS_ReferenceImage_Padded_Masked_Filtered_Enhanced)
                    axis equal tight
                    colormap('jet')
                    hold on
                    text(size(ReferenceImage_Padded,2)*0.01,size(ReferenceImage_Padded,1)*0.05,['Previous Final Enhanced REFERENCE'],'fontsize',12,'color','w')
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                    for j=1:length(EnhanceRegionPaddedBorderLines)
                        plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
                            EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
                            ':','color','m','linewidth',0.5)
                    end
                    set(gca,'xtick',[],'ytick',[]);
                    set(gcf,'position',[FigureSize1(1), 80,FigureSize/2])
                end
                %%%%%%%%%%%%%%%%%%%%%%
                [ReferenceImage_Padded,ReferenceImage_Padded_Masked_Filtered_Enhanced]=...
                    RegistrationImageEnhancement(RegistrationSettings.OverallReferenceImage,...
                    AllBoutonsRegion_Padded,AllBoutonsRegion_Mask_Padded,EnhanceRegionBorderLines,...
                    Crop_Props,DemonReg,RefRegEnhancement,[StackSaveName,' ReferenceImage'],[],1,0);
                %%%%%%%%%%%%%%%%%%%%%%
                PREVIOUS_ReferenceImage_Padded_Masked_Filtered_Enhanced=ReferenceImage_Padded_Masked_Filtered_Enhanced;
                commandwindow
                cont1=InputWithVerification('Enter <1> to fix params: ',{[],1},0);
                close all            
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if RegistrationSettings.RegisterToReference
                warning('RegisterToReference to register to a separate reference file is ACTIVE')
            else
                warning('RegisterToReference to register to a separate reference file is NOT ACTIVE')
            end
            OverwriteEnhancements=questdlg({'Do you want to apply the REFERENCE contrast enhancemnt settings';...
                'To all of the data? If you are registering to a separate file';'I would recommend that you check and adjust these next settings independently';...
                'Therefore Skip this if you have previously adjusted the data settings and do NOT want to overwrite with reference settings'},...
                'Apply reference settings?','Apply','Skip','Apply');
            switch OverwriteEnhancements
                case 'Apply'
                    warning('Updating Enhancement settings for ACTUAL data with Reference Data...')
                    RegEnhancement=RefRegEnhancement;
                case 'Skip'
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %All Enhancements
            fprintf('Now Checking Enhancement settings for ACTUAL data...\n')
            commandwindow
            cont1=1;
            while cont1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if TutorialNotes
                    Instructions={'ALL DATA IMAGE ENHANCEMENT SETTINGS';...
                            'Filter_Enhanced (1/0), EnhanceFilterSigma_um and EnhanceFilterSize_um: can help clean up the data a little before contrasting to provide a better contrast enhancement or to suppress active AZs whose activity may throw off the registration if too strong';...
                            'These next settings will be used by the Zach_enhanceContrastForDemon.m function to enhance contrast (actually used both before and after biasing).'
                            'StretchLimParams Low and High(0-1): allow you to adjust the effective normalized contrast values for the image';...
                            'weinerParams: these are set in pixel sizes and should be both modified together and used by the weiner2.m function which is a "2-D adaptive noise-removal filter" used in Zach_enhanceContrastForDemon.m';...
                            'openParams (px disk Radius): used by imopen.m function within Zach_enhanceContrastForDemon.m';...
                            'MaskSplitPercentage (0-1) and MaskSplitDilate (px): will help alter the bouton region used for biasing by performing an imdilate with a box of the size indicated';...
                            'Bias_Region (1/0) ,BiasRatios, BiasRatioDiv, BiasProportion: are all settings that allow you to use the bouton region to help bias the contrast enhancement. This way only the relevant sectors should be strongly enhanced while outside your region will be suppressed';...
                            };
                    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                        TutorialNotes=0;
                    end
                end
                
                if length(TestFrames)>1
                    TestFramesString=[mat2str(TestFrames)];
                elseif length(TestFrames)==1
                    TestFramesString=['[',mat2str(TestFrames),']'];
                else
                    TestFramesString=['[]'];
                end
                prompt = {  'Filter_Enhanced (1/0):','EnhanceFilterSigma_um:','EnhanceFilterSize_um:',...
                            'StretchLimParams Low(0-1):','StretchLimParams High(0-1):',...
                            'weinerParams 1 (px; match 2):','weinerParams 2 (px; match 1):','openParams (px disk Radius):',...
                            'MaskSplitPercentage (0-1):','MaskSplitDilate (px):',...
                            'Bias_Region (1/0):','BiasRatios:','BiasRatioDiv:','BiasProportion:',...
                            };
                dlg_title = ['Define REFERENCE IMAGE Contrast Enhancements'];
                num_lines = 1;
                def = {     num2str(RegEnhancement.Filter_Enhanced),num2str(RegEnhancement.EnhanceFilterSigma_um),num2str(RegEnhancement.EnhanceFilterSize_um),...
                            num2str(RegEnhancement.StretchLimParams(1)),num2str(RegEnhancement.StretchLimParams(2)),...
                            num2str(RegEnhancement.weinerParams(1)),num2str(RegEnhancement.weinerParams(2)),num2str(RegEnhancement.openParams),...
                            num2str(RegEnhancement.MaskSplitPercentage),num2str(RegEnhancement.MaskSplitDilate),...
                            num2str(RegEnhancement.Bias_Region),num2str(RegEnhancement.BiasRatios),...
                            num2str(RegEnhancement.BiasRatioDiv),num2str(RegEnhancement.BiasProportion),...
                            };
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);
                RegEnhancement.Filter_Enhanced=        str2num(answer{1});
                RegEnhancement.EnhanceFilterSigma_um=  str2num(answer{2});
                RegEnhancement.EnhanceFilterSize_um=   str2num(answer{3});

                RegEnhancement.StretchLimParams(1)=    str2num(answer{4});
                RegEnhancement.StretchLimParams(2)=    str2num(answer{5});
                RegEnhancement.weinerParams(1)=        str2num(answer{6});
                RegEnhancement.weinerParams(2)=        str2num(answer{7});
                RegEnhancement.openParams=             str2num(answer{8});

                RegEnhancement.MaskSplitPercentage=    str2num(answer{9});
                RegEnhancement.MaskSplitDilate=        str2num(answer{10});

                RegEnhancement.Bias_Region=            str2num(answer{11});
                RegEnhancement.BiasRatios=             str2num(answer{12});
                RegEnhancement.BiasRatioDiv=           str2num(answer{13});
                RegEnhancement.BiasProportion=         str2num(answer{14});

                RegEnhancement.EnhanceFilterSigma_px=...
                    RegEnhancement.EnhanceFilterSigma_um/ImagingInfo.PixelSize;
                RegEnhancement.EnhanceFilterSize_px=...
                    ceil(RegEnhancement.EnhanceFilterSize_um/ImagingInfo.PixelSize);
                if rem(RegEnhancement.EnhanceFilterSize_px,2)==0
                    RegEnhancement.EnhanceFilterSize_px=RegEnhancement.EnhanceFilterSize_px+1;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Set up DemonReg.Padding and Masking regions
                AllBoutonsRegionPerim=bwperim(AllBoutonsRegion);
                [BorderY BorderX] = find(AllBoutonsRegionPerim);
                AllBoutonsRegion_Mask=ones(size(AllBoutonsRegion));
                AllBoutonsRegion_Padded = padarray(AllBoutonsRegion,[DemonReg.Padding DemonReg.Padding],0);
                AllBoutonsRegion_Mask_Padded = padarray(AllBoutonsRegion_Mask,[DemonReg.Padding DemonReg.Padding],1);
                for j=1:RegEnhancement.BiasRatios
                    Temp=imdilate(AllBoutonsRegion,ones(j*RegEnhancement.BiasRatioDiv));
                    AllBoutonsRegion_Mask=AllBoutonsRegion_Mask+Temp;
                    Temp=imdilate(AllBoutonsRegion_Padded,ones(j*RegEnhancement.BiasRatioDiv));
                    AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded+Temp;
                end
                AllBoutonsRegion_Mask=AllBoutonsRegion_Mask/max(AllBoutonsRegion_Mask(:));
                AllBoutonsRegion_Mask=AllBoutonsRegion_Mask*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
                AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded/max(AllBoutonsRegion_Mask_Padded(:));
                AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
                AllBoutonsRegion_Mask_Crop=imcrop(AllBoutonsRegion_Mask,Crop_Props.BoundingBox);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for t=1:length(TestFrames)
                    disp(['Testing Frame #',num2str(TestFrames(t))])
                    TestImage=ImageArray(:,:,TestFrames(t));
    %                 %Determine Value to use for filling Pad area
    %                 if DemonReg.PadValue_Method==1
    %                     TestImage_Pad_Value=median(TestImage(:));
    %                 elseif DemonReg.PadValue_Method==2
    %                     TestImage_Pad_Value=mean(TestImage(:));
    %                 elseif DemonReg.PadValue_Method==3
    %                     TestImage_Pad_Value=min(TestImage(:));
    %                 else
    %                     TestImage_Pad_Value=0;
    %                 end
    %                 %Pad Border
    %                 TestImage_Padded = padarray(TestImage,[DemonReg.Padding DemonReg.Padding],TestImage_Pad_Value);
    %                 %Smooth pad interface border
    %                 BorderAdjust1=zeros(size(AllBoutonsRegion_Mask_Padded));
    %                 BorderAdjust1(1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,1)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,2)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2)=1;
    %                 BorderAdjust2=zeros(size(AllBoutonsRegion_Mask_Padded));
    %                 BorderAdjust2(1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,1)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,2)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2)=1;
    %                 BorderAdjust=BorderAdjust1+BorderAdjust2;
    %                 BorderAdjust(BorderAdjust==0)=1;
    %                 BorderAdjust(BorderAdjust==2)=0;
    %                 TestImage_Padded= roifilt2(fspecial('disk', 10),double(TestImage_Padded),logical(BorderAdjust));
    %                 %Enhance once to set up ROIs
    %                 if RegEnhancement.Filter_Enhanced
    %                     Temp_TestImage_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TestImage_Padded), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_um,  RegEnhancement.EnhanceFilterSigma_um)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                 else
    %                     Temp_TestImage_Enhanced=Zach_enhanceContrastForDemon(uint16(TestImage_Padded),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                 end
    % 
    %                 TestImage_Enhanced_Mask=Temp_TestImage_Enhanced;
    %                 TestImage_Enhanced_Mask(TestImage_Enhanced_Mask<RegEnhancement.MaskSplitPercentage*max(Temp_TestImage_Enhanced(:)))=0;
    %                 TestImage_Enhanced_Mask(TestImage_Enhanced_Mask>=RegEnhancement.MaskSplitPercentage*max(Temp_TestImage_Enhanced(:)))=1;
    %                 TestImage_Enhanced_Mask=imdilate(TestImage_Enhanced_Mask,ones(RegEnhancement.MaskSplitDilate));
    %                 %Pick Mask that overlaps with AllBoutonsRegion
    %                 [~,NumRegions] = bwlabel(AllBoutonsRegion_Padded);
    %                 AllBoutounsRegion_Padded_ROIs=bwconncomp(AllBoutonsRegion_Padded);
    %                 AllBoutounsRegion_Padded_ROIs_RegionProps = regionprops(AllBoutounsRegion_Padded_ROIs,'PixelList');
    %                 TestImage_Enhanced_Mask_MatchedROI=zeros(size(TestImage_Enhanced_Mask));
    %                 for z=1:NumRegions
    %                     cont=1;
    %                     k=1;
    %                     while cont
    %                          TempROI = bwselect(TestImage_Enhanced_Mask, AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2));
    %                          if any(TempROI(:)>0)
    %                              TestImage_Enhanced_Mask_MatchedROI=TestImage_Enhanced_Mask_MatchedROI+TempROI;
    %                              cont=0;
    %                          elseif k>=size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
    %                              cont=0;
    %                          else
    %                              k=k+1;
    %                          end
    %                     end
    %                 end
    %                 %Set up Bias with the new ROIs
    %                 TestImage_Enhanced_Mask_MatchedROI_Biased=ones(size(TestImage_Enhanced_Mask_MatchedROI));
    %                 for j=1:RegEnhancement.BiasRatios
    %                     Temp=imdilate(TestImage_Enhanced_Mask_MatchedROI,ones(j*RegEnhancement.BiasRatioDiv));
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased=TestImage_Enhanced_Mask_MatchedROI_Biased+Temp;
    %                 end
    %                 clear Temp
    %                 TestImage_Enhanced_Mask_MatchedROI_Biased=TestImage_Enhanced_Mask_MatchedROI_Biased/max(TestImage_Enhanced_Mask_MatchedROI_Biased(:));
    %                 TestImage_Enhanced_Mask_MatchedROI_Biased=TestImage_Enhanced_Mask_MatchedROI_Biased*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
    %                 %use the dilated region for filtereing anything outside the regions
    %                 TestImage_Enhanced_Mask_MatchedROI_Biased_Mask=TestImage_Enhanced_Mask_MatchedROI_Biased;
    %                 TestImage_Enhanced_Mask_MatchedROI_Biased_Mask(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask==min(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask(:)))=0;
    %                 TestImage_Enhanced_Mask_MatchedROI_Biased_Mask=logical(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask);
    %                 %Apply bias
    %                 if RegEnhancement.Bias_Region
    %                     TestImage_Padded_Biased=double(TestImage_Padded).*double(TestImage_Enhanced_Mask_MatchedROI_Biased);
    %                 else
    %                     TestImage_Padded_Biased=TestImage_Padded;
    %                 end
    %                 %filter all pixels outside of the region
    %                 TestImage_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(TestImage_Padded_Biased),~logical(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask));
    %                 if RegEnhancement.Filter_Enhanced
    %                     TestImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TestImage_Padded_Masked_Filtered), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_um,  RegEnhancement.EnhanceFilterSigma_um)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                 else
    %                     TestImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(uint16(TestImage_Padded_Masked_Filtered),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                 end             
    %                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 FigureSize=[size(TestImage_Padded,2)*3,size(TestImage_Padded,1)*2];
    %                 if FigureSize(2)>ScreenSize(4)-150
    %                     ExportScalarModifier=(ScreenSize(4)-150)/FigureSize(2);
    %                     FigureSize=round(FigureSize*ExportScalarModifier);
    %                 end
    %                 if FigureSize(1)>ScreenSize(3)
    %                     ExportScalarModifier=ScreenSize(3)/FigureSize(1);
    %                     FigureSize=round(FigureSize*ExportScalarModifier);
    %                 end
    %                 %%%%%%%%%%%
    %                 figure('name',[StackSaveName,' ','TestFrame ',num2str(TestFrames(t))])
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,1,[0,0],[0,0],[0,0])
    %                 imagesc(TestImage)
    %                 axis equal tight
    %                 colormap('jet')
    %                 hold on
    %                 text(size(TestImage,2)*0.01,size(TestImage,1)*0.05,[StackSaveName,' ','TestFrame ',num2str(TestFrames(t))],'fontsize',12,'color','w','interpreter','none')
    %                 plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionBorderLines)
    %                     plot(EnhanceRegionBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,2,[0,0],[0,0],[0,0])
    %                 imagesc(TestImage_Padded)
    %                 axis equal tight
    %                 colormap('jet')
    %                 hold on
    %                 text(size(TestImage_Padded,2)*0.01,size(TestImage_Padded,1)*0.05,['TestFrame ',num2str(TestFrames(t)),' Padded and EdgeFixed'],'fontsize',12,'color','w')
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionPaddedBorderLines)
    %                     plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,3,[0,0],[0,0],[0,0])
    %                 imagesc(TestImage_Padded_Masked_Filtered)
    %                 axis equal tight
    %                 colormap('jet'),
    %                 hold on
    %                 text(size(TestImage_Padded,2)*0.01,size(TestImage_Padded,1)*0.05,['TestFrame ',num2str(TestFrames(t)),' Masked and Filtered'],'fontsize',12,'color','w')
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionPaddedBorderLines)
    %                     plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 subtightplot(2,3,4,[0,0],[0,0],[0,0])
    %                 imagesc(TestImage_Padded_Masked_Filtered_Enhanced)
    %                 axis equal tight
    %                 colormap('jet')
    %                 hold on
    %                 text(size(TestImage_Padded,2)*0.01,size(TestImage_Padded,1)*0.05,['TestFrame ',num2str(TestFrames(t)),' Final Enhanced'],'fontsize',12,'color','w')
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                 plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                 for j=1:length(EnhanceRegionPaddedBorderLines)
    %                     plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                         EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                         ':','color','w','linewidth',0.5)
    %                 end
    %                 set(gca,'xtick',[],'ytick',[]);
    %                 %%%%%%%%%%%
    %                 if ~isempty(PREVIOUS_TestImage_Padded_Masked_Filtered_Enhanced)
    %                     subtightplot(2,3,5,[0,0],[0,0],[0,0])
    %                     imagesc(PREVIOUS_TestImage_Padded_Masked_Filtered_Enhanced(:,:,t))
    %                     axis equal tight
    %                     colormap('jet')
    %                     hold on
    %                     text(size(TestImage_Padded,2)*0.01,size(TestImage_Padded,1)*0.05,['PREVIOUS TestFrame ',num2str(TestFrames(t)),' Final Enhanced'],'fontsize',12,'color','w')
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
    %                     plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
    %                     for j=1:length(EnhanceRegionPaddedBorderLines)
    %                         plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
    %                             EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
    %                             ':','color','w','linewidth',0.5)
    %                     end
    %                     set(gca,'xtick',[],'ytick',[]);
    %                 end
    %                 %%%%%%%%%%%%%%%%%%%%%%
    %                 set(gcf,'position',[0 50,FigureSize])
    %                 drawnow
    %                 clear BorderAdjust BorderAdjust1 BorderAdjust2
                    if ~isempty(PREVIOUS_TestImage_Padded_Masked_Filtered_Enhanced)
                        FigureSize=[size(ReferenceImage_Padded,2)*1,size(ReferenceImage_Padded,1)*1];
                        if FigureSize(2)>ScreenSize(4)-150
                            ExportScalarModifier=(ScreenSize(4)-150)/FigureSize(2);
                            FigureSize=round(FigureSize*ExportScalarModifier);
                        end
                        if FigureSize(1)>ScreenSize(3)
                            ExportScalarModifier=ScreenSize(3)/FigureSize(1);
                            FigureSize=round(FigureSize*ExportScalarModifier);
                        end
                        FigureSize1=[size(ReferenceImage_Padded,2)*3,size(ReferenceImage_Padded,1)*2];
                        if FigureSize1(2)>ScreenSize(4)-150
                            ExportScalarModifier=(ScreenSize(4)-150)/FigureSize1(2);
                            FigureSize1=round(FigureSize1*ExportScalarModifier);
                        end
                        if FigureSize1(1)>ScreenSize(3)
                            ExportScalarModifier=ScreenSize(3)/FigureSize1(1);
                            FigureSize1=round(FigureSize1*ExportScalarModifier);
                        end
                        subtightplot(1,1,1,[0,0],[0,0],[0,0])
                        imagesc(PREVIOUS_TestImage_Padded_Masked_Filtered_Enhanced(:,:,t))
                        axis equal tight
                        colormap('jet')
                        hold on
                        text(size(TestImage_Padded,2)*0.01,size(TestImage_Padded,1)*0.05,['PREVIOUS TestFrame ',num2str(TestFrames(t)),' Final Enhanced'],'fontsize',12,'color','w')
                        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
                        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                        plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                        for j=1:length(EnhanceRegionPaddedBorderLines)
                            plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
                                EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
                                ':','color','m','linewidth',0.5)
                        end
                        set(gca,'xtick',[],'ytick',[]);
                        set(gcf,'position',[FigureSize1(1), 80,FigureSize/2])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%
                    [TestImage_Padded,TestImage_Padded_Masked_Filtered_Enhanced]=...
                        RegistrationImageEnhancement(TestImage,...
                        AllBoutonsRegion_Padded,AllBoutonsRegion_Mask_Padded,EnhanceRegionBorderLines,...
                        Crop_Props,DemonReg,RegEnhancement,[StackSaveName,' ','TestFrame ',num2str(TestFrames(t))],[],1,0);
                    %%%%%%%%%%%%%%%%%%%%%%
                    FigureSize=[size(TestImage_Padded,2)*2,size(TestImage_Padded,1)*2];
                    if FigureSize(2)>ScreenSize(4)-150
                        ExportScalarModifier=(ScreenSize(4)-150)/FigureSize(2);
                        FigureSize=round(FigureSize*ExportScalarModifier);
                    end
                    if FigureSize(1)>ScreenSize(3)
                        ExportScalarModifier=ScreenSize(3)/FigureSize(1);
                        FigureSize=round(FigureSize*ExportScalarModifier);
                    end
                    %%%%%%%%%%%
                    figure('name',[StackSaveName,' ','TestFrame ',num2str(TestFrames(t))])
                    subtightplot(2,2,1,[0,0],[0,0],[0,0])
                    imagesc(ReferenceImage)
                    axis equal tight
                    colormap('jet')
                    hold on
                    text(size(TestImage,2)*0.01,size(TestImage,1)*0.05,['REFERENCE Image'],'fontsize',12,'color','w')
                    plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
                    plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                    for j=1:length(EnhanceRegionBorderLines)
                        plot(EnhanceRegionBorderLines{j}.BorderLine(:,2),...
                            EnhanceRegionBorderLines{j}.BorderLine(:,1),...
                            ':','color','m','linewidth',0.5)
                    end
                    set(gca,'xtick',[],'ytick',[]);
                    %%%%%%%%%%%
                    subtightplot(2,2,3,[0,0],[0,0],[0,0])
                    imagesc(ReferenceImage_Padded_Masked_Filtered_Enhanced)
                    axis equal tight
                    colormap('jet')
                    hold on
                    text(size(ReferenceImage_Padded,2)*0.01,size(ReferenceImage_Padded,1)*0.05,['REFERENCE Final Enhanced'],'fontsize',12,'color','w')
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                    for j=1:length(EnhanceRegionPaddedBorderLines)
                        plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
                            EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
                            ':','color','m','linewidth',0.5)
                    end
                    set(gca,'xtick',[],'ytick',[]);
                    %%%%%%%%%%%
                    subtightplot(2,2,2,[0,0],[0,0],[0,0])
                    imagesc(TestImage)
                    axis equal tight
                    colormap('jet')
                    hold on
                    text(size(TestImage,2)*0.01,size(TestImage,1)*0.05,[StackSaveName,' ','TestFrame ',num2str(TestFrames(t))],'fontsize',12,'color','w','interpreter','none')
                    plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
                    plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                    for j=1:length(EnhanceRegionBorderLines)
                        plot(EnhanceRegionBorderLines{j}.BorderLine(:,2),...
                            EnhanceRegionBorderLines{j}.BorderLine(:,1),...
                            ':','color','m','linewidth',0.5)
                    end
                    set(gca,'xtick',[],'ytick',[]);
                    %%%%%%%%%%%
                    subtightplot(2,2,4,[0,0],[0,0],[0,0])
                    imagesc(TestImage_Padded_Masked_Filtered_Enhanced)
                    axis equal tight
                    colormap('jet')
                    hold on
                    text(size(TestImage_Padded,2)*0.01,size(TestImage_Padded,1)*0.05,['TestFrame ',num2str(TestFrames(t)),' Final Enhanced'],'fontsize',12,'color','w')
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                    plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                    for j=1:length(EnhanceRegionPaddedBorderLines)
                        plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
                            EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
                            ':','color','m','linewidth',0.5)
                    end
                    set(gca,'xtick',[],'ytick',[]);
                    %%%%%%%%%%%%%%%%%%%%%%
                    set(gcf,'position',[FigureSize(1)/4 50,FigureSize])
                    drawnow
                    clear BorderAdjust BorderAdjust1 BorderAdjust2
                    PREVIOUS_TestImage_Padded_Masked_Filtered_Enhanced(:,:,t)=TestImage_Padded_Masked_Filtered_Enhanced;
                end
                cont1=InputWithVerification('Enter <1> to fix params: ',{[],1},0);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TestSettings=questdlg('Do you want to test enhancement settings on whole stack:?','Test Enhancement?','Test','Skip','Skip');
            if strcmp(TestSettings,'Test')
                TestSettings2=questdlg('Are you Sure??? this can take a very long time if a large dataset','Test Enhancement?','Test','Skip','Skip');
                if strcmp(TestSettings2,'Test')
                    disp('Applying Contrast...')
                    warning('Depending on how many frames this can take a very long time...')
                    ImageArray=uint16(ImageArray);

                    TestImage = ImageArray(:,:,1);
                    TestStack=uint16(zeros(size(TestImage,1),size(TestImage,2),size(ImageArray,3)));
                    TestStack=padarray(TestStack,[DemonReg.Padding DemonReg.Padding],0);
                    Temp_Crop_Props=Crop_Props;
                    Temp_FilterSize=RegistrationSettings.FilterSize_px;
                    Temp_FilterSigma=RegistrationSettings.FilterSigma_px;

                    parfor ImageNumber=1:1
                    end
                    if ~any(strfind(OS,'MACI64'))
                        ppm = ParforProgMon('Contrasting and Enhancing Image Number: ', size(ImageArray,3), 1, 1000, 80);
                    end
                    parfor ImageNumber=1:size(ImageArray,3)
                        %progressbar(IndexNumber/LastIndexNumber)
                        TestImage = ImageArray(:,:,ImageNumber);
    %                     %Determine Value to use for filling Pad area
    %                     if DemonReg.PadValue_Method==1
    %                         TestImage_Pad_Value=median(TestImage(:));
    %                     elseif DemonReg.PadValue_Method==2
    %                         TestImage_Pad_Value=mean(TestImage(:));
    %                     elseif DemonReg.PadValue_Method==3
    %                         TestImage_Pad_Value=min(TestImage(:));
    %                     else
    %                         TestImage_Pad_Value=0;
    %                     end
    %                     %Pad Border
    %                     TestImage_Padded = padarray(TestImage,[DemonReg.Padding DemonReg.Padding],TestImage_Pad_Value);
    %                     %Smooth pad interface border
    %                     BorderAdjust1=zeros(size(AllBoutonsRegion_Mask_Padded));
    %                     BorderAdjust1(1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,1)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,2)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2)=1;
    %                     BorderAdjust2=zeros(size(AllBoutonsRegion_Mask_Padded));
    %                     BorderAdjust2(1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,1)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,2)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2)=1;
    %                     BorderAdjust=BorderAdjust1+BorderAdjust2;
    %                     BorderAdjust(BorderAdjust==0)=1;
    %                     BorderAdjust(BorderAdjust==2)=0;
    %                     TestImage_Padded= roifilt2(fspecial('disk', 10),double(TestImage_Padded),logical(BorderAdjust));
    %                     %Enhance once to set up ROIs
    %                     if RegEnhancement.Filter_Enhanced
    %                         Temp_TestImage_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TestImage_Padded), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_um,  RegEnhancement.EnhanceFilterSigma_um)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                     else
    %                         Temp_TestImage_Enhanced=Zach_enhanceContrastForDemon(uint16(TestImage_Padded),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                     end
    % 
    %                     TestImage_Enhanced_Mask=Temp_TestImage_Enhanced;
    %                     TestImage_Enhanced_Mask(TestImage_Enhanced_Mask<RegEnhancement.MaskSplitPercentage*max(Temp_TestImage_Enhanced(:)))=0;
    %                     TestImage_Enhanced_Mask(TestImage_Enhanced_Mask>=RegEnhancement.MaskSplitPercentage*max(Temp_TestImage_Enhanced(:)))=1;
    %                     TestImage_Enhanced_Mask=imdilate(TestImage_Enhanced_Mask,ones(RegEnhancement.MaskSplitDilate));
    %                     %Pick Mask that overlaps with AllBoutonsRegion
    %                     [~,NumRegions] = bwlabel(AllBoutonsRegion_Padded);
    %                     AllBoutounsRegion_Padded_ROIs=bwconncomp(AllBoutonsRegion_Padded);
    %                     AllBoutounsRegion_Padded_ROIs_RegionProps = regionprops(AllBoutounsRegion_Padded_ROIs,'PixelList');
    %                     TestImage_Enhanced_Mask_MatchedROI=zeros(size(TestImage_Enhanced_Mask));
    %                     for z=1:NumRegions
    %                         cont=1;
    %                         k=1;
    %                         while cont&&k<size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
    %                              TempROI = bwselect(TestImage_Enhanced_Mask, AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2));
    %                              if any(TempROI(:)>0)
    %                                  TestImage_Enhanced_Mask_MatchedROI=TestImage_Enhanced_Mask_MatchedROI+TempROI;
    %                                  cont=0;
    %                              elseif k>=size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
    %                                  cont=0;
    %                              else
    %                                  k=k+1;
    %                              end
    %                         end
    %                     end
    %                     %Set up Bias with the new ROIs
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased=ones(size(TestImage_Enhanced_Mask_MatchedROI));
    %                     for j=1:RegEnhancement.BiasRatios
    %                         Temp=imdilate(TestImage_Enhanced_Mask_MatchedROI,ones(j*RegEnhancement.BiasRatioDiv));
    %                         TestImage_Enhanced_Mask_MatchedROI_Biased=TestImage_Enhanced_Mask_MatchedROI_Biased+Temp;
    %                     end
    %                     Temp=[];
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased=TestImage_Enhanced_Mask_MatchedROI_Biased/max(TestImage_Enhanced_Mask_MatchedROI_Biased(:));
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased=TestImage_Enhanced_Mask_MatchedROI_Biased*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
    %                     %use the dilated region for filtereing anything outside the regions
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased_Mask=TestImage_Enhanced_Mask_MatchedROI_Biased;
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased_Mask(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask==min(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask(:)))=0;
    %                     TestImage_Enhanced_Mask_MatchedROI_Biased_Mask=logical(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask);
    %                     %Apply bias
    %                     if RegEnhancement.Bias_Region
    %                         TestImage_Padded_Biased=double(TestImage_Padded).*double(TestImage_Enhanced_Mask_MatchedROI_Biased);
    %                     else
    %                         TestImage_Padded_Biased=TestImage_Padded;
    %                     end
    %                     %filter all pixels outside of the region
    %                     TestImage_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(TestImage_Padded_Biased),~logical(TestImage_Enhanced_Mask_MatchedROI_Biased_Mask));
    %                     if RegEnhancement.Filter_Enhanced
    %                         TestImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TestImage_Padded_Masked_Filtered), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_um,  RegEnhancement.EnhanceFilterSigma_um)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                     else
    %                         TestImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(uint16(TestImage_Padded_Masked_Filtered),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    %                     end             
                        %%%%%%%%%%%%%%%%%%%%%%
                        [~,TestImage_Padded_Masked_Filtered_Enhanced]=...
                            RegistrationImageEnhancement(TestImage,...
                            AllBoutonsRegion_Padded,AllBoutonsRegion_Mask_Padded,EnhanceRegionBorderLines,...
                            Crop_Props,DemonReg,RegEnhancement,[],[],1,0);
                        %%%%%%%%%%%%%%%%%%%%%%
                        TestStack(:,:,ImageNumber)=uint16(TestImage_Padded_Masked_Filtered_Enhanced);
                        if ~any(strfind(OS,'MACI64'))
                            ppm.increment();
                        end

                    end
                    disp('Finished Enhancing Data!')

                    TestStackInterval=10;
                    TestStack_Reduced=uint16(zeros(size(TestStack,1),size(TestStack,2),size(ImageArray,3)/10));
                    Count=0;
                    for ImageNumber=1:size(ImageArray,3)
                        if rem(ImageNumber,TestStackInterval)==0
                            Count=Count+1;
                            TestStack_Reduced(:,:,Count)=TestStack(:,:,ImageNumber);
                        end

                    end

                    PlayBackStack=1;
                    while PlayBackStack
                        PlayBackChoice=questdlg('Play Whole stack or Reduced Stack?','Playback Option?','Whole','Reduced','Whole');
                        switch PlayBackChoice
                            case 'Whole'
                                AutoPlaybackNew(TestStack,1,0.0001,[0 MaxStack(TestStack)],'jet')
                            case 'Reduced'
                                AutoPlaybackNew(TestStack_Reduced,1,0.0001,[0 MaxStack(TestStack)],'jet')
                        end
                        RepeatPlayBackChoice=questdlg('Repeat Playback?','Repeat Playback?','Continue','Repeat','Continue');
                        switch RepeatPlayBackChoice
                            case 'Continue'
                                PlayBackStack=0;
                            case 'Repeat'
                                PlayBackStack=1;
                        end
                    end
                    clear TestStack TestStack_Reduced
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GoodSettings=questdlg('Are you happy with the contrast enhancmenet settings or do you want to redo?','Redo Settings?','Good','Redo','Good');
            switch GoodSettings
                case 'Good'
                    SettingUp=0;
                case 'Redo'
                    SettingUp=1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Demon Settings
        SettingUp=1;
        while SettingUp&&(RegistrationSettings.RegistrationMethod==2||RegistrationSettings.RegistrationMethod==3)
            %Demon Mask To Exlude Areas from Registration
            close all
            figure('name',[StackSaveName,' ',''])
            subtightplot(1,1,1,[0,0],[0,0],[0,0]),imagesc(ReferenceImage_Padded_Masked_Filtered_Enhanced), axis equal tight,colormap('jet'),title('Final Enhanced Ref Image'), drawnow, pause(0.1)
            if ~isempty(DemonReg.DemonMask)
               TempMaskImage=ReferenceImage_Padded;
               TempMaskImage((DemonReg.DemonMask))=0;
               figure('name',[StackSaveName,' ',''])
               imshow(TempMaskImage,[])
            else
               warning('Demon Mask Empty...')
            end
            AddDemonMask=questdlg('Do you want to add or adjust current demon mask?','Demon Mask?','Add/Adjust','Remove','Skip','Skip');
            switch AddDemonMask
                case 'Add/Adjust'
                    cont1=1;
                    while cont1
                        figure('name',[StackSaveName,' ',''])
                        subtightplot(1,1,1,[0,0],[0,0],[0,0]),...
                            imagesc(ReferenceImage_Padded_Masked_Filtered_Enhanced)
                        axis equal tight
                        colormap('jet'),title('Final Enhanced Ref Image'),
                        hold on
                        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'--','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);
                        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'--','color','w','LineWidth',0.5); 
                        for j=1:length(EnhanceRegionPaddedBorderLines)
                            plot(EnhanceRegionPaddedBorderLines{j}.BorderLine(:,2),...
                                EnhanceRegionPaddedBorderLines{j}.BorderLine(:,1),...
                                ':','color','w','linewidth',0.5)
                        end
                        set(gcf,'units','normalized','position',[0,0.25,0.7,0.65])
                        drawnow
                        DemonReg.DemonMask = roipoly;
                        TempMaskImage=ReferenceImage_Padded;
                        TempMaskImage((DemonReg.DemonMask))=0;
                        figure('name',[StackSaveName,' ',''])
                        imshow(TempMaskImage,[])
                        commandwindow
                        cont1=InputWithVerification('Enter <1> to Adjust Demon Mask or <ENTER> to save: ',{[],1},0);
                    end

                case 'Remove'
                    DemonReg.DemonMask=[];
    %             %Set up DemonReg.Padding and Masking regions
    %             AllBoutonsRegionPerim=bwperim(AllBoutonsRegion);
    %             [BorderY BorderX] = find(AllBoutonsRegionPerim);
    %             AllBoutonsRegion_Mask=ones(size(AllBoutonsRegion));
    %             AllBoutonsRegion_Padded = padarray(AllBoutonsRegion,[DemonReg.Padding DemonReg.Padding],0);
    %             AllBoutonsRegion_Mask_Padded = padarray(AllBoutonsRegion_Mask,[DemonReg.Padding DemonReg.Padding],1);
    %             for j=1:RefRegEnhancement.BiasRatios
    %                     Temp=imdilate(AllBoutonsRegion,ones(j*RefRegEnhancement.BiasRatioDiv));
    %                     AllBoutonsRegion_Mask=AllBoutonsRegion_Mask+Temp;
    %                     Temp=imdilate(AllBoutonsRegion_Padded,ones(j*RefRegEnhancement.BiasRatioDiv));
    %                     AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded+Temp;
    %             end
    %             AllBoutonsRegion_Mask=AllBoutonsRegion_Mask/max(AllBoutonsRegion_Mask(:));
    %             AllBoutonsRegion_Mask=AllBoutonsRegion_Mask*RefRegEnhancement.BiasProportion+(1-RefRegEnhancement.BiasProportion);
    %             AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded/max(AllBoutonsRegion_Mask_Padded(:));
    %             AllBoutonsRegion_Mask_Padded=AllBoutonsRegion_Mask_Padded*RefRegEnhancement.BiasProportion+(1-RefRegEnhancement.BiasProportion);
    %             AllBoutonsRegion_Mask_Crop=imcrop(AllBoutonsRegion_Mask,Crop_Props.BoundingBox);
    % 
    %             %Determine Value to use for filling Pad area
    %             if DemonReg.PadValue_Method==1
    %                 ReferenceImage_Pad_Value=median(ReferenceImage(:));
    %             elseif DemonReg.PadValue_Method==2
    %                 ReferenceImage_Pad_Value=mean(ReferenceImage(:));
    %             elseif DemonReg.PadValue_Method==3
    %                 ReferenceImage_Pad_Value=min(ReferenceImage(:));
    %             else
    %                 ReferenceImage_Pad_Value=0;
    %             end
    %             %Pad Border
    %             ReferenceImage_Padded = padarray(ReferenceImage,[DemonReg.Padding DemonReg.Padding],ReferenceImage_Pad_Value);
    %             %Smooth pad interface border
    %             BorderAdjust1=zeros(size(AllBoutonsRegion_Mask_Padded));
    %             BorderAdjust1(1+DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,1)-DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,2)-DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2)=1;
    %             BorderAdjust2=zeros(size(AllBoutonsRegion_Mask_Padded));
    %             BorderAdjust2(1+DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,1)-DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding+RefRegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,2)-DemonReg.Padding-RefRegEnhancement.BorderAdjustSize/2)=1;
    %             BorderAdjust=BorderAdjust1+BorderAdjust2;
    %             BorderAdjust(BorderAdjust==0)=1;
    %             BorderAdjust(BorderAdjust==2)=0;
    %             ReferenceImage_Padded= roifilt2(fspecial('disk', 10),double(ReferenceImage_Padded),logical(BorderAdjust));
    %             %Enhance once to set up ROIs
    %             if RefRegEnhancement.Filter_Enhanced
    %                 Temp_ReferenceImage_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(ReferenceImage_Padded), fspecial('gaussian', RefRegEnhancement.EnhanceFilterSize_um,  RefRegEnhancement.EnhanceFilterSigma_um)),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             else
    %                 Temp_ReferenceImage_Enhanced=Zach_enhanceContrastForDemon(uint16(ReferenceImage_Padded),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             end
    % 
    %             ReferenceImage_Enhanced_Mask=Temp_ReferenceImage_Enhanced;
    %             ReferenceImage_Enhanced_Mask(ReferenceImage_Enhanced_Mask<RefRegEnhancement.MaskSplitPercentage*max(Temp_ReferenceImage_Enhanced(:)))=0;
    %             ReferenceImage_Enhanced_Mask(ReferenceImage_Enhanced_Mask>=RefRegEnhancement.MaskSplitPercentage*max(Temp_ReferenceImage_Enhanced(:)))=1;
    %             ReferenceImage_Enhanced_Mask=imdilate(ReferenceImage_Enhanced_Mask,ones(RefRegEnhancement.MaskSplitDilate));
    %             %Pick Mask that overlaps with AllBoutonsRegion
    %             [~,NumRegions] = bwlabel(AllBoutonsRegion_Padded);
    %             AllBoutounsRegion_Padded_ROIs=bwconncomp(AllBoutonsRegion_Padded);
    %             AllBoutounsRegion_Padded_ROIs_RegionProps = regionprops(AllBoutounsRegion_Padded_ROIs,'PixelList');
    %             ReferenceImage_Enhanced_Mask_MatchedROI=zeros(size(ReferenceImage_Enhanced_Mask));
    %             for z=1:NumRegions
    %                 cont=1;
    %                 k=1;
    %                 while cont
    %                      TempROI = bwselect(ReferenceImage_Enhanced_Mask, AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2));
    %                      if any(TempROI(:)>0)
    %                          ReferenceImage_Enhanced_Mask_MatchedROI=ReferenceImage_Enhanced_Mask_MatchedROI+TempROI;
    %                          cont=0;
    %                      elseif k>=size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
    %                          cont=0;
    %                      else
    %                          k=k+1;
    %                      end
    %                 end
    %             end
    %             %Set up Bias with the new ROIs
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ones(size(ReferenceImage_Enhanced_Mask_MatchedROI));
    %             for j=1:RefRegEnhancement.BiasRatios
    %                 Temp=imdilate(ReferenceImage_Enhanced_Mask_MatchedROI,ones(j*RefRegEnhancement.BiasRatioDiv));
    %                 ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ReferenceImage_Enhanced_Mask_MatchedROI_Biased+Temp;
    %             end
    %             clear Temp
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ReferenceImage_Enhanced_Mask_MatchedROI_Biased/max(ReferenceImage_Enhanced_Mask_MatchedROI_Biased(:));
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased=ReferenceImage_Enhanced_Mask_MatchedROI_Biased*RefRegEnhancement.BiasProportion+(1-RefRegEnhancement.BiasProportion);
    %             %use the dilated region for filtereing anything outside the regions
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask=ReferenceImage_Enhanced_Mask_MatchedROI_Biased;
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask==min(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask(:)))=0;
    %             ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask=logical(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask);
    %             %Apply bias
    %             if RefRegEnhancement.Bias_Region
    %                 ReferenceImage_Padded_Biased=double(ReferenceImage_Padded).*double(ReferenceImage_Enhanced_Mask_MatchedROI_Biased);
    %             else
    %                 ReferenceImage_Padded_Biased=ReferenceImage_Padded;
    %             end
    %             %filter all pixels outside of the region
    %             ReferenceImage_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(ReferenceImage_Padded_Biased),~logical(ReferenceImage_Enhanced_Mask_MatchedROI_Biased_Mask));
    %             if RefRegEnhancement.Filter_Enhanced
    %                 ReferenceImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(ReferenceImage_Padded_Masked_Filtered), fspecial('gaussian', RefRegEnhancement.EnhanceFilterSize_um,  RefRegEnhancement.EnhanceFilterSigma_um)),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             else
    %                 ReferenceImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(uint16(ReferenceImage_Padded_Masked_Filtered),RefRegEnhancement.weinerParams,RefRegEnhancement.openParams,RefRegEnhancement.StretchLimParams);
    %             end
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            end
            close all
            if ~isempty(DemonReg.DemonMask)
                TempMaskImage=ReferenceImage_Padded;
                TempMaskImage((DemonReg.DemonMask))=0;
                figure('name',[StackSaveName,' ',''])
                imshow(TempMaskImage,[])
            else
                warning('Demon Mask Empty...')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Demon Algorithm Settings
            cont1=1;
            while cont1
                if TutorialNotes
                    Instructions={'Demons registration algorithm settings Part 1/2';...
                        'Most of these settings are used by the imregdemons.m/imregdemons_ZN.m functions so see them for more details';...
                        'PyramidLevels and Iterations: must be set together, with PyramidLevels being the length of the Iterations vector. What this does is set the number of refinement iterations that are peformed at each "resolution" with the algorithm starting with a lower resoltion verion image and moving to progressively higher and higher resoltions. Thus you can use more iterations with the earlier, lower res, pyramid levels. If things arent moving as much you can also use lower values for iterations to speed up Demons Registration';...
                        'AccumulatedFieldSmoothing: from imregdemons.m: "AccumulatedFieldSmoothing: Standard deviation of the Gaussian smoothing applied to regularize the accumulated field at each iteration. This parameter controls the amount of diffusion-like regularization. Larger values will result in more smooth output displacement fields. Smaller values will result in more localized deformation in the output displacement field. AccumulatedFieldSmoothing is typically in the range [0.5, 3.0].When multiple PyramidLevels are used, the standard deviation used in Gaussian smoothing remains the same at each pyramid level." Typically with NMJ data this value should be between 4 and 6 but again actually changes based on the resolution of the data and I havent fixed to correct for changes in pixel size so adjust carefully';...
                        'SmoothDemon and DemonSmoothSize: turn on and set the parameters for the temporal filtering that can be performed on the output displacement field to prevent frame-by-frame jitter. To aply a temporal filter I extract the Displacement field vector for each pixel and construct a trace for each pixel and apply a smoothing filter to this trace prior to reconstructing the Displacement field array. SmoothDemon if not 0 needs to refer to the number of progressive smooth opterations performed on each pixels temporal demon field vector while DemonSmoothSize will set the width of the smoothing filter kernel (use ODD values) for each iteration';...
                        'IntermediateCropPadding: A smaller padding window that is used after Demon reg when I run another round of DFT registration to remove any remaining jitters in the data';...
                        'BoutonRefinement: Can perform additional registration on smaller user-defined bouton regions after the main registration to correct for really big problems. This requires that you add sub-bouton regions in the initial intake NMJ region selection.';...
                        'BorderBufferPixelSize: When BoutonRefinement is active This adds buffer zone (10x10 works well most of the time) to boutons to avoid FFT artifacts, may cause problems with ROI too close to borders';...
                        'CONTINUED...';...
                    };
                    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                        TutorialNotes=0;
                    end
                    Instructions={'Demons registration algorithm settings Part 2/2';...
                        'DynamicSmoothing: Can disable the temporal smoothing filter when the the NMJ moves a lot between imaging episodes. These jumps often occur when moving the stage between episodes to keep the NMJ in approx the same location. When you make a big jump somtimes there can be artifacts when smoothing the transformations in temporal space.  Alternatively if the NMJ is drifiting quickly you may want to alllow the registration to be more sensitive to these changes and allow it to track without having to fight against the smoothing filter. So if the corase registration detects a large movement it will remove the temporal smoothing for those frame/episodes. These movements are detected by the derivative of the DeltaX and DeltaY shifts during coarese registration being greater than the DynamicSmoothingDerivThreshold';...
                        'CarryOver_DemonField_Smoothing: To promote consistency in registration between episodes where we may have made small adjustments to focus or NMJ position within the imaging window it can be helpful to transfer a few registered frames (CarryOverFrames) from the end of the previous episode onto the beginning of each subsequent episode. This essentially seeds the registration of an episode with more registered data. Since my method is sensitive to temporal changes at each pixel this can help restrain the registrations';...
                        'CircularFilter: Similar to the CarryOver CarryOver_DemonField_Smoothing when performing the Demon temporal filters I can translate some frames from the beginning of the movie to the end to prevent smoothing edge artifacts when the smoothing filter kernel does not fully engage (i.e. less than half kernel width of frames from the beginning or end)';...
                        'CoarseTranslation: Helpful to run this regardless of the registration method as it will help correct a lot of the large movements before running DFT and Demons';...
                        'CoarseTranslationMode: will perform Coarse_Reg either on ALL images (select 0) or the first image of each episode (select 1). This does not have to be consistent with the imaging method however.';...
                        'FastSmoothing and PixelBlockSize can allow you to greatly speed up the temporal demons smoothing as it is extremely computationally intense and hard to parellize. With this method the data is broken into smaller blocks of pixels that can be processed in parellel. If you end up this far into the tutorial notes please send me an email (newmanza@gmail.com) saying so as I have a prize for you.'...                    
                    };
                    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                        TutorialNotes=0;
                    end
                end
                
                
                
                
                if DemonReg.PyramidLevels>1
                    DemonIterationString=mat2str(DemonReg.Iterations);
                else
                    DemonIterationString=[mat2str(DemonReg.Iterations)];
                end
                if length(DemonReg.DemonSmoothSize)>1
                    DemonSmoothString=mat2str(DemonReg.DemonSmoothSize);
                else
                    DemonSmoothString=['[',num2str(DemonReg.DemonSmoothSize),']'];
                end        
%                 if AdvancedMode
                    prompt = {'PyramidLevels (1-10): ',...
                            'Iterations ([vector]): ',...
                            'AccumulatedFieldSmoothing (px): ',...
                            'SmoothDemon (ex: 0,1,2,3): ',...
                            'DemonSmoothSize ([vector]): ',...
                            'IntermediateCropPadding (px): ',...
                            'BoutonRefinement (1/0): ',...
                            'BorderBufferPixelSize (px): ',...
                            'DynamicSmoothing (1/0): ',...
                            'DynamicSmoothingDerivThreshold (derivative val)',...
                            'CarryOver_DemonField_Smoothing (1/0): ',...
                            'CarryOverFrames (#frames): ',...
                            'CircularFilter (1/0): ',...
                            'CoarseTranslation (1/0): ',...
                            'CoarseTranslationMode (0=ALL or 1=FirstFrame)',...
                            'FastSmoothing (1/0 REC 1)): ',...
                            'PixelBlockSize (#px): '...
                            };
                    dlg_title = ['Define Demon Settings'];
                    num_lines = 1;
                    def = {num2str(DemonReg.PyramidLevels),DemonIterationString,num2str(DemonReg.AccumulatedFieldSmoothing),num2str(DemonReg.SmoothDemon),DemonSmoothString,...
                                num2str(DemonReg.IntermediateCropPadding),num2str(DemonReg.BoutonRefinement),num2str(DemonReg.BorderBufferPixelSize),...
                                num2str(DemonReg.DynamicSmoothing),num2str(DemonReg.DynamicSmoothingDerivThreshold),...
                                num2str(DemonReg.CarryOver_DemonField_Smoothing),num2str(DemonReg.CarryOverFrames),num2str(DemonReg.CircularFilter),...
                                num2str(DemonReg.CoarseTranslation),num2str(DemonReg.CoarseTranslationMode),...
                                num2str(DemonReg.FastSmoothing),num2str(DemonReg.PixelBlockSize)};
                    answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);

                    disp('Updated Settings: ')
                    DemonReg.PyramidLevels=                  str2num(answer{1});
                    DemonReg.Iterations=                     String2Array2(answer{2});
                    DemonReg.AccumulatedFieldSmoothing=      str2num(answer{3});
                    DemonReg.SmoothDemon=                    str2num(answer{4});
                    DemonReg.DemonSmoothSize=                String2Array2(answer{5});
                    DemonReg.IntermediateCropPadding=        str2num(answer{6});
                    DemonReg.BoutonRefinement=               str2num(answer{7});
                    DemonReg.BorderBufferPixelSize=          str2num(answer{8});
                    DemonReg.DynamicSmoothing=               str2num(answer{9});
                    DemonReg.DynamicSmoothingDerivThreshold= str2num(answer{10});
                    DemonReg.CarryOver_DemonField_Smoothing= str2num(answer{11});
                    DemonReg.CarryOverFrames=                str2num(answer{12});
                    DemonReg.CircularFilter=                 str2num(answer{13});
                    DemonReg.CoarseTranslation=              str2num(answer{14});
                    DemonReg.CoarseTranslationMode=          str2num(answer{15});
                    DemonReg.FastSmoothing=                  str2num(answer{16});
                    DemonReg.PixelBlockSize=                 str2num(answer{17});

%                 else
%                     prompt = {'PyramidLevels: ','Iterations: ','AccumulatedFieldSmoothing: ','SmoothDemon: ','DemonSmoothSize: ',...
%                             'DynamicSmoothing: ','DynamicSmoothingDerivThreshold',...
%                             'CarryOver_DemonField_Smoothing: ','CarryOverFrames: '};
%                     dlg_title = ['Define Demon Settings'];
%                     num_lines = 1;
%                     def = {num2str(DemonReg.PyramidLevels),DemonIterationString,num2str(DemonReg.AccumulatedFieldSmoothing),num2str(DemonReg.SmoothDemon),DemonSmoothString,...
%                                 num2str(DemonReg.DynamicSmoothing),num2str(DemonReg.DynamicSmoothingDerivThreshold),...
%                                 num2str(DemonReg.CarryOver_DemonField_Smoothing),num2str(DemonReg.CarryOverFrames)};
%                     answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);
% 
%                     disp('Updated Settings: ')
%                     DemonReg.PyramidLevels=                  str2num(answer{1});
%                     DemonReg.Iterations=                     String2Array2(answer{2});
%                     DemonReg.AccumulatedFieldSmoothing=      str2num(answer{3});
%                     DemonReg.SmoothDemon=                    str2num(answer{4});
%                     DemonReg.DemonSmoothSize=                String2Array2(answer{5});
%                     DemonReg.DynamicSmoothing=               str2num(answer{6});
%                     DemonReg.DynamicSmoothingDerivThreshold= str2num(answer{7});
%                     DemonReg.CarryOver_DemonField_Smoothing= str2num(answer{8});
%                     DemonReg.CarryOverFrames=                str2num(answer{9});
%                 end
                commandwindow
                if length(DemonReg.DemonSmoothSize)~=DemonReg.SmoothDemon
                    warning('DemonSmoothSize and DemonReg.SmoothDemon need to be compatible')
                    cont1=1;
                else
                    GoodSettings=questdlg('Adjust Demon Parameters?','Adjust Demon Parameters?','Good','Redo','Good');
                    switch GoodSettings
                        case 'Good'
                            cont1=0;
                        case 'Redo'
                            cont1=1;
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('====================================================================================\n')
            if DemonReg.DynamicSmoothing
                warning('NOTE: Dynamic Smoothing Engaged!')
                warning('Make sure to check the flagged indices!')
            end
            disp('Key Settings:')
            disp(['Padding = ',num2str(DemonReg.Padding)])
            disp(['PyramidLevels = ',num2str(DemonReg.PyramidLevels)])
            fprintf('Iterations = [')
            for i=1:length(DemonReg.Iterations)
                fprintf([num2str(DemonReg.Iterations(i)),' '])
            end
            fprintf('\b]\n')
            disp(['AccumulatedFieldSmoothing = ',num2str(DemonReg.AccumulatedFieldSmoothing)])
            disp(['SmoothDemon = ',num2str(DemonReg.SmoothDemon)])
            if DemonReg.SmoothDemon
                fprintf('DemonSmoothSize = [')
                for i=1:length(DemonReg.DemonSmoothSize)
                    fprintf([num2str(DemonReg.DemonSmoothSize(i)),' '])
                end
                fprintf('\b]\n')
            end
            disp(['MaskSplitPercentage = ',num2str(RegEnhancement.MaskSplitPercentage)])
            disp(['StretchLimParams = [',num2str(RegEnhancement.StretchLimParams(1)),' ',num2str(RegEnhancement.StretchLimParams(2)),']'])
            disp(['DynamicSmoothing = ',num2str(DemonReg.DynamicSmoothing)])
            disp(['DynamicSmoothingDerivThreshold = ',num2str(DemonReg.DynamicSmoothingDerivThreshold)])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GoodSettings=questdlg('Are you happy with the Demon settings or do you want to redo?','Redo Settings?','Good','Redo','Good');
            switch GoodSettings
                case 'Good'
                    SettingUp=0;
                case 'Redo'
                    SettingUp=1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        GoodRegistrationSettings=questdlg('Are you happy with the ALL Registration settings or do you want to redo?','Redo Settings?','Good','Redo','Good');
        switch GoodRegistrationSettings
            case 'Good'
                SettingUpRegistration=0;
            case 'Redo'
                SettingUpRegistration=1;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('====================================================================================\n')
    disp(['Finished Registration Setup for: ',StackSaveName])
    close all
    fprintf('====================================================================================\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end