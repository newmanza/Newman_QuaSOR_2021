function [AlignmentParams]=ChannelAlignment(FileName) 

%Written by Zach Newman newmanza@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Still to do/fix:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,~,~,~,~,~,ScratchDir]=BatchStartup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Script
RunProgram=1;
while RunProgram==1
    jheapcl
    warning off
    %dbstop if error
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning off all
    ScreenSize=get(0,'ScreenSize');
    currentFolder = cd;
    [upperPath, deepestFolder] = fileparts(currentFolder);
    if currentFolder(length(currentFolder))~=dc
        currentFolder=[currentFolder,dc];
    end
    [ret, compName] = system('hostname');   
    if ret ~= 0,
       if ispc
          compName = getenv('COMPUTERNAME');
       else      
          compName = getenv('HOSTNAME');      
       end
    end
    compName = lower(compName);
    compName=cellstr(compName);
    compName=compName{1};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GET FILE IF NOT IN FUNCTION CALL
    if ~exist('')
        [FileName,currentFolder]=uigetfile({'*.tif;*.lsm;*.czi', 'All SUPPORTED IMAGE Files (*.tif *.lsm *.czi)'});
    elseif isempty(FileName)
        [FileName,currentFolder]=uigetfile({'*.tif;*.lsm;*.czi', 'All SUPPORTED IMAGE Files (*.tif *.lsm *.czi)'});
    end
    cd(currentFolder)
    [upperPath, deepestFolder] = fileparts(currentFolder);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Test for file extension
    FileType=0; %1 .tif 2 .lsm 3 .czi
    if ~strcmp(FileName(length(FileName)-3),'.')
        if exist(strcat(FileName,'.tif'))
            FileName=strcat(FileName,'.tif');
            DataID=FileName(1:length(FileName)-4);
            FileType=1;
        elseif exist(strcat(FileName,'.lsm'))
            FileName=strcat(FileName,'.lsm');
            DataID=FileName(1:length(FileName)-4);
            FileType=2;
        elseif exist(strcat(FileName,'.czi'))
            FileName=strcat(FileName,'.czi');
            DataID=FileName(1:length(FileName)-4);
            FileType=3;
        else
            error('Incompatible file type or file not found!')
        end
    else
        if exist(FileName)
            if any(strfind(FileName,'.tif'))
                FileType=1;
            elseif any(strfind(FileName,'.lsm'))
                FileType=2;
            elseif any(strfind(FileName,'.czi'))
                FileType=3;
            else
                error('Incompatible file type!')
            end    
            DataID=FileName(1:length(FileName)-4);
        else
            error('FILE NOT FOUND!')
        end
    end
    FileID=DataID;
    SaveID=DataID;
    if ~exist([cd,dc,FileName],'file')
        Beeper(10,0.1);
        disp(['FILE NOT FOUND: ',FileName])
        disp('Terminating script')
        return;return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('==============================================')
    disp('==============================================')
    disp('==============================================')
    disp(['Starting Processing on ',FileName])
    if FileType==1
        disp('Using settings for .tif file import!')
    elseif FileType==2
        disp('Using settings for .lsm file import!')
    elseif FileType==3
        disp('Using settings for .czi file import!')
    end
    disp('==============================================')
    disp('==============================================')
    disp('==============================================')
    FinalSaveDir=strcat(currentFolder,FileID,' Alignment');
    if ~exist(FinalSaveDir)
        mkdir(FinalSaveDir);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Load Data

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if FileType==1
        error('Not currently set up to use .tif file...')
    elseif FileType==2
        error('Not currently set up to use .lsm file...')
    elseif FileType==3
        disp('Importing .CZI File...')
        
        [ImageArray,MetaData]=CZI_Importer(FileName);
        size(ImageArray)
        
    else
        error('File not .lsm .tif or .czi')

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CHECK DATA
    %display stacks for both channels separately
    clear ImageData
    close all
    MetaData.ChannelLabels=[];
    for c=1:MetaData.SizeC
        MetaData.ChannelLabels{c}=[MetaData.Channels{c},' ',MetaData.Dyes{c},' ',num2str(MetaData.WLEx{c})];
        if MetaData.WLEx{c}==405
            MetaData.ChannelColors{c}='m';
        elseif MetaData.WLEx{c}==488
            MetaData.ChannelColors{c}='g';
        elseif MetaData.WLEx{c}==561
            MetaData.ChannelColors{c}='c';
        elseif MetaData.WLEx{c}==633
            MetaData.ChannelColors{c}='r';
        else
            MetaData.ChannelColors{c}='w';
        end
        MetaData.ChannelColorCodes{c}=ColorDefinitions(MetaData.ChannelColors{c});
        
    end
    figure,
    set(gcf,'units','pixels','position',[50,50,(MetaData.SizeC)*MetaData.SizeX/2,MetaData.SizeY/2])
    for c=1:MetaData.SizeC
        TempStack=ImageArray(:,:,:,c);
        ImageData.Channel(c).ImageArray_Pre=TempStack;
        ImageData.Channel(c).MaxProj_Pre=max(TempStack,[],3);
        ImageData.Channel(c).MaxProj_Max=max(ImageData.Channel(c).MaxProj_Pre(:));
        subtightplot(1,MetaData.SizeC,c,[0,0],[0,0],[0,0])
        imagesc(ImageData.Channel(c).MaxProj_Pre)
        clear TempStack
        hold on
        text(50,50,MetaData.ChannelLabels{c},'color','w','fontsize',8)
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis equal tight
        pause(0.1)
    end
    figure,
    set(gcf,'units','pixels','position',[50,50,(MetaData.SizeC)*MetaData.SizeX/2,MetaData.SizeY/2])
    for c=1:MetaData.SizeC
        [~,ImageData.Channel(c).MaxProj_Pre_Color,~]=Adjust_Contrast_and_Color(ImageData.Channel(c).MaxProj_Pre,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
        subtightplot(1,MetaData.SizeC,c,[0,0],[0,0],[0,0])
        imshow(ImageData.Channel(c).MaxProj_Pre_Color,[])
        hold on
        text(50,50,MetaData.ChannelLabels{c},'color','w','fontsize',8)
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        pause(0.1)
    end
    ImageData.Merge_AllChannel_MaxProj_Pre_Color=zeros(MetaData.SizeY,MetaData.SizeX,3);
    for c=1:MetaData.SizeC
        ImageData.Merge_AllChannel_MaxProj_Pre_Color=ImageData.Merge_AllChannel_MaxProj_Pre_Color+ImageData.Channel(c).MaxProj_Pre_Color;
    end
    figure,
    set(gcf,'units','pixels','position',[50,50,MetaData.SizeX/2,MetaData.SizeY/2])
    imshow(ImageData.Merge_AllChannel_MaxProj_Pre_Color,[],'border','tight')
    hold on
    text(50,50,'Merge Pre','color','w','fontsize',8)
    ImageData.Merge_AllChannel_Stack_Pre=zeros(MetaData.SizeY,MetaData.SizeX,3,MetaData.SizeZ);
    for c=1:MetaData.SizeC
        TempStack=ImageArray(:,:,:,c);
        ImageData.Channel(c).ImageArray_Pre=TempStack;
        for z=1:MetaData.SizeZ
            TempImage=TempStack(:,:,z);
            [~,TempImageColor,~]=Adjust_Contrast_and_Color(TempImage,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
            TempMerge=ImageData.Merge_AllChannel_Stack_Pre(:,:,:,z);
            TempMerge=TempMerge+TempImageColor;
            ImageData.Merge_AllChannel_Stack_Pre(:,:,:,z)=TempMerge+TempImageColor;
            clear TempMerge TempImageColor
        end
    end
    Zach_a_Stack_Viewer(ImageData.Merge_AllChannel_Stack_Pre);
    
    cont=input('Press any key to proceed to bead tagging: ');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    KeepCalculating=1;
    while KeepCalculating
    
        close all
        ReferenceChannel=2;
        BoxSize=40;
        TranslationInterpolation='cubic';
        disp('=============================================')
        disp('Enter in the required information...')
        disp('NOTE: Options for Interpolation include:')
        disp('nearest')
        disp('linear')
        disp('cubic')
        disp('Type exact or wont work!')
        disp('=============================================')
        prompt = {'Reference Channel','BeadBoxSize (px)','Interpolation'};
        dlg_title = 'Alignment Params';
        num_lines = 1;
        def = {num2str(ReferenceChannel),num2str(BoxSize),TranslationInterpolation};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ReferenceChannel=str2num(answer{1});
        BoxSize=str2num(answer{2});
        TranslationInterpolation=answer{3};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Select well isolated bead...')
        disp('<ENTER> when finished')
        figure,
        clear BeadStruct
        BeadCount=0;
        KeepAddingBeads=1;
        imshow(ImageData.Merge_AllChannel_MaxProj_Pre_Color,[],'border','tight')
        while KeepAddingBeads
           TempCoord=ginput_w(1);
           if ~isempty(TempCoord)

                BeadCount=BeadCount+1;
                BeadStruct(BeadCount).Coord=TempCoord;
                BeadStruct(BeadCount).Box=[BeadStruct(BeadCount).Coord(1)-round(BoxSize/2),...
                                           BeadStruct(BeadCount).Coord(2)-round(BoxSize/2),...
                                           BoxSize,BoxSize];
                BeadStruct(BeadCount).XData=[round(BeadStruct(BeadCount).Coord(1))-round(BoxSize/2):...
                                             round(BeadStruct(BeadCount).Coord(1))-round(BoxSize/2)+BoxSize];
                BeadStruct(BeadCount).YData=[round(BeadStruct(BeadCount).Coord(2))-round(BoxSize/2):...
                                             round(BeadStruct(BeadCount).Coord(2))-round(BoxSize/2)+BoxSize];
                hold on
                PlotBox(BeadStruct(BeadCount).Box,'-','y',0.5,num2str(BeadCount),8,'y')
           else
                KeepAddingBeads=0;
           end

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
        disp('=====================================')
        disp('=====================================')
        disp('=====================================')
        disp('Finding All peak coordinates...')
        for Bead=1:BeadCount

            TempProj_Pre=zeros(BoxSize+1,BoxSize+1,3);
            TempMergeStack_Pre=zeros(BoxSize+1,BoxSize+1,3,MetaData.SizeZ);
            for c=1:MetaData.SizeC
                TempStack=ImageArray(BeadStruct(Bead).YData,BeadStruct(Bead).XData,:,c);
                BeadStruct(Bead).Channel(c).ImageArray_Pre=TempStack;
                BeadStruct(Bead).Channel(c).MaxProj_Pre=max(TempStack,[],3);
                for z=1:MetaData.SizeZ
                    TempImage=TempStack(:,:,z);
                    [~,TempImageColor,~]=Adjust_Contrast_and_Color(TempImage,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                    TempMerge=TempMergeStack_Pre(:,:,:,z);
                    TempMerge=TempMerge+TempImageColor;
                    TempMergeStack_Pre(:,:,:,z)=TempMerge+TempImageColor;
                    clear TempMerge TempImageColor
                end
                TempStackProj=max(TempStack,[],3);
                [~,TempStackProjColor,~]=Adjust_Contrast_and_Color(TempStackProj,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                TempProj_Pre=TempProj_Pre+TempStackProjColor;
            end
            BeadStruct(Bead).Pre_Align_All_Channels_Stack=TempMergeStack_Pre;
            BeadStruct(Bead).Pre_Align_All_Channels_MaxProj=TempProj_Pre;
            clear TempStackProj TempMergeStack_Pre
            TempColorStack=zeros(BoxSize+1,BoxSize+1,3,MetaData.SizeZ);
            for c=1:MetaData.SizeC
                TempStack=ImageArray(BeadStruct(Bead).YData,BeadStruct(Bead).XData,:,c);
                for z=1:MetaData.SizeZ
                    [~,TempColorImage,~]=Adjust_Contrast_and_Color(TempStack(:,:,z),0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                    TempMerge=TempColorStack(:,:,:,z);
                    TempMerge=TempMerge+TempColorImage;
                    TempColorStack(:,:,:,z)=TempMerge;
                    clear TempMerge TempColorImage
                end
                %Zach_a_Stack_Viewer(TempStack)
                %fprintf(['Finding Maxima for Bead ',num2str(Bead),' Channel ',num2str(c),'...'])
                TempMaxStack=imregionalmax(TempStack,26);
                clear x y z MaxPos
                [y,x,z]=ind2sub(size(TempMaxStack),find(TempMaxStack));
                MaxPos=[y,x,z];
                clear Maxima
                for i=1:size(MaxPos,1)
                    Maxima(i)=TempStack(MaxPos(i,1),MaxPos(i,2),MaxPos(i,3));
                end
                clear x y z
                %Zach_a_Stack_Viewer(TempMaxStack)
                [Maxima_Max,Maxima_Pos]=max(Maxima);
                BeadStruct(Bead).Channel(c).PeakCoord=[MaxPos(Maxima_Pos,1),MaxPos(Maxima_Pos,2),MaxPos(Maxima_Pos,3)];
                BeadStruct(Bead).Channel(c).PeakVal=Maxima_Max;

                clear TempMaxStack TempStack Maxima MaxPos Maxima_Max Maxima_Pos x y z
                %fprintf([num2str(BeadStruct(Bead).Channel(c).PeakCoord),'\n'])
            end
            %Zach_a_Stack_Viewer(TempColorStack)

            clear TempColorStack

        end
        fprintf('Finished!\n')
        disp('=====================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Calculating Average Offsets...')
        clear AlignmentParams
        AlignmentParams.ReferenceChannel=ReferenceChannel;
        AlignmentParams.TranslationInterpolation=TranslationInterpolation;
        AlignmentParams.ScaleX=MetaData.ScaleX;
        AlignmentParams.ScaleY=MetaData.ScaleY;
        AlignmentParams.ScaleZ=MetaData.ScaleZ;
        AlignmentParams.WLEx=MetaData.WLEx;
        AlignmentParams.WLEm=MetaData.WLEm;
        AlignmentParams.Channels=MetaData.Channels;
        AlignmentParams.Dyes=MetaData.Dyes;
        AlignmentParams.ChannelLabels=MetaData.ChannelLabels;
        for c=1:MetaData.SizeC
            AlignmentParams.Channel_Corrections(c).Labels=...
                MetaData.ChannelLabels{c};

            AlignmentParams.Channel_Corrections(c).All_DeltaX=[];
            AlignmentParams.Channel_Corrections(c).All_DeltaY=[];
            AlignmentParams.Channel_Corrections(c).All_DeltaZ=[];
            for Bead=1:BeadCount
                BeadStruct(Bead).Channel(c).DeltaX=BeadStruct(Bead).Channel(ReferenceChannel).PeakCoord(2)-BeadStruct(Bead).Channel(c).PeakCoord(2);
                BeadStruct(Bead).Channel(c).DeltaY=BeadStruct(Bead).Channel(ReferenceChannel).PeakCoord(1)-BeadStruct(Bead).Channel(c).PeakCoord(1);
                BeadStruct(Bead).Channel(c).DeltaZ=BeadStruct(Bead).Channel(ReferenceChannel).PeakCoord(3)-BeadStruct(Bead).Channel(c).PeakCoord(3);
                AlignmentParams.Channel_Corrections(c).All_DeltaX=[AlignmentParams.Channel_Corrections(c).All_DeltaX,BeadStruct(Bead).Channel(c).DeltaX];
                AlignmentParams.Channel_Corrections(c).All_DeltaY=[AlignmentParams.Channel_Corrections(c).All_DeltaY,BeadStruct(Bead).Channel(c).DeltaY];
                AlignmentParams.Channel_Corrections(c).All_DeltaZ=[AlignmentParams.Channel_Corrections(c).All_DeltaZ,BeadStruct(Bead).Channel(c).DeltaZ];
            end
            [AlignmentParams.Channel_Corrections(c).DeltaX.Mean,AlignmentParams.Channel_Corrections(c).DeltaX.STD,AlignmentParams.Channel_Corrections(c).DeltaX.SEM,~]=Mean_STD_SEM(AlignmentParams.Channel_Corrections(c).All_DeltaX);
            [AlignmentParams.Channel_Corrections(c).DeltaY.Mean,AlignmentParams.Channel_Corrections(c).DeltaY.STD,AlignmentParams.Channel_Corrections(c).DeltaY.SEM,~]=Mean_STD_SEM(AlignmentParams.Channel_Corrections(c).All_DeltaY);
            [AlignmentParams.Channel_Corrections(c).DeltaZ.Mean,AlignmentParams.Channel_Corrections(c).DeltaZ.STD,AlignmentParams.Channel_Corrections(c).DeltaZ.SEM,~]=Mean_STD_SEM(AlignmentParams.Channel_Corrections(c).All_DeltaZ);

        end
        fprintf('Finished!\n')
        disp('=====================================')
        disp('Average Bead Corrections: ')
        for c=1:MetaData.SizeC
            disp([AlignmentParams.Channel_Corrections(c).Labels,...
                ' X ',num2str(AlignmentParams.Channel_Corrections(c).DeltaX.Mean),...
                ' Y ',num2str(AlignmentParams.Channel_Corrections(c).DeltaY.Mean),...
                ' Z ',num2str(AlignmentParams.Channel_Corrections(c).DeltaZ.Mean)])
        end
        disp('=====================================')
        fprintf('Testing Corrections...')
        fprintf('On Beads First...')
        for Bead=1:BeadCount
            TempProj_Post=zeros(BoxSize+1,BoxSize+1,3);
            TempMergeStack_Post=zeros(BoxSize+1,BoxSize+1,3,MetaData.SizeZ);
            for c=1:MetaData.SizeC
                TempStack=ImageArray(BeadStruct(Bead).YData,BeadStruct(Bead).XData,:,c);
                TempStack_Corr=zeros(size(TempStack));
                TempStackProj=max(TempStack,[],3);
                [~,TempStackProjColor,~]=Adjust_Contrast_and_Color(TempStackProj,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                TempProj_Pre=TempProj_Pre+TempStackProjColor;

    %             for z=1:MetaData.SizeZ
    %                 TempImage=TempStack(:,:,z);
    %                 z1=(z-round(AlignmentParams.Channel_Corrections(c).DeltaZ.Mean));
    %                 if z1<=MetaData.SizeZ&&z1>0
    %                     TempStack_Corr(:,:,z1)=imtranslate(TempImage,...
    %                     [AlignmentParams.Channel_Corrections(c).DeltaX.Mean,AlignmentParams.Channel_Corrections(c).DeltaY.Mean],TranslationInterpolation,'FillValues',0);
    %                 end
    %             end
    %             
                TempStack_Corr=imtranslate(TempStack,...
                    [AlignmentParams.Channel_Corrections(c).DeltaX.Mean,...
                    AlignmentParams.Channel_Corrections(c).DeltaY.Mean,...
                    AlignmentParams.Channel_Corrections(c).DeltaZ.Mean],...
                    TranslationInterpolation,'FillValues',0);

                BeadStruct(Bead).Channel(c).ImageArray_Pre=TempStack_Corr;
                BeadStruct(Bead).Channel(c).MaxProj_Post=max(TempStack_Corr,[],3);

                for z=1:MetaData.SizeZ
                    TempImage=TempStack_Corr(:,:,z);
                    [~,TempImageColor,~]=Adjust_Contrast_and_Color(TempImage,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                    TempMerge=TempMergeStack_Post(:,:,:,z);
                    TempMerge=TempMerge+TempImageColor;
                    TempMergeStack_Post(:,:,:,z)=TempMerge+TempImageColor;
                    clear TempMerge TempImageColor
                end
                TempStackProj=max(TempStack_Corr,[],3);
                [~,TempStackProjColor,~]=Adjust_Contrast_and_Color(TempStackProj,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                TempProj_Post=TempProj_Post+TempStackProjColor;
                clear TempStack_Corr TempStackProjColor TempStack
            end
            BeadStruct(Bead).Post_Align_All_Channels_Stack=TempMergeStack_Post;
            BeadStruct(Bead).Post_Align_All_Channels_MaxProj=TempProj_Post;
        end
        fprintf('and now on whole image...')
        ImageData.Merge_AllChannel_MaxProj_Post_Color=zeros(size(ImageData.Merge_AllChannel_MaxProj_Pre_Color));
        ImageData.Merge_AllChannel_Stack_Post=zeros(size(ImageData.Merge_AllChannel_Stack_Pre));
        for c=1:MetaData.SizeC
            TempStack=ImageArray(:,:,:,c);

            TempStack_Corr=imtranslate(TempStack,...
                [AlignmentParams.Channel_Corrections(c).DeltaX.Mean,...
                AlignmentParams.Channel_Corrections(c).DeltaY.Mean,...
                AlignmentParams.Channel_Corrections(c).DeltaZ.Mean],...
                TranslationInterpolation,'FillValues',0);

            ImageData.Channel(c).ImageArray_Post=TempStack_Corr;
            ImageData.Channel(c).MaxProj_Post=max(TempStack_Corr,[],3);
            [~,ImageData.Channel(c).MaxProj_Post_Color,~]=Adjust_Contrast_and_Color(ImageData.Channel(c).MaxProj_Post,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
            ImageData.Merge_AllChannel_MaxProj_Post_Color=ImageData.Merge_AllChannel_MaxProj_Post_Color+ImageData.Channel(c).MaxProj_Post_Color;
            for z=1:MetaData.SizeZ
                TempImage=TempStack_Corr(:,:,z);
                [~,TempImageColor,~]=Adjust_Contrast_and_Color(TempImage,0,ImageData.Channel(c).MaxProj_Max,MetaData.ChannelColorCodes{c},1);
                TempMerge=ImageData.Merge_AllChannel_Stack_Post(:,:,:,z);
                TempMerge=TempMerge+TempImageColor;
                ImageData.Merge_AllChannel_Stack_Post(:,:,:,z)=TempMerge+TempImageColor;
                clear TempMerge TempImageColor
            end
            
            clear TempStack_Corr TempStackProjColor TempStack

        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FigScalar=5;
        close all
        fprintf('Displaying all bead corrections...')
        for Bead=1:BeadCount
            figure,
            set(gcf,'units','pixels','position',[50,50,(MetaData.SizeC+1)*(BoxSize+1)*FigScalar,(2)*(BoxSize+1)*FigScalar])
            PanelCount=1;
            subtightplot(2,MetaData.SizeC+1,PanelCount,[0,0],[0,0],[0,0])
            imshow(BeadStruct(Bead).Pre_Align_All_Channels_MaxProj,[],'border','tight')
            hold on
            text(BoxSize/10,BoxSize/10,['Bead ',num2str(Bead),' Pre'],'color','w','fontsize',10)
            for c=1:MetaData.SizeC
                PanelCount=PanelCount+1;
                subtightplot(2,MetaData.SizeC+1,PanelCount,[0,0],[0,0],[0,0])
                imshow(BeadStruct(Bead).Channel(c).MaxProj_Pre,[],'border','tight')
                hold on
                plot(BeadStruct(Bead).Channel(c).PeakCoord(2),BeadStruct(Bead).Channel(c).PeakCoord(1),'*','markersize',12,'color',MetaData.ChannelColors{c})
            end
            PanelCount=PanelCount+1;
            subtightplot(2,MetaData.SizeC+1,PanelCount,[0,0],[0,0],[0,0])
            imshow(BeadStruct(Bead).Post_Align_All_Channels_MaxProj,[],'border','tight')
            hold on
            text(BoxSize/10,BoxSize/10,['Bead ',num2str(Bead),' Post'],'color','w','fontsize',10)
            for c=1:MetaData.SizeC
                PanelCount=PanelCount+1;
                subtightplot(2,MetaData.SizeC+1,PanelCount,[0,0],[0,0],[0,0])
                imshow(BeadStruct(Bead).Channel(c).MaxProj_Post,[],'border','tight')
                hold on
                plot(BeadStruct(Bead).Channel(c).PeakCoord(2)+AlignmentParams.Channel_Corrections(c).DeltaX.Mean,...
                    BeadStruct(Bead).Channel(c).PeakCoord(1)+AlignmentParams.Channel_Corrections(c).DeltaY.Mean,...
                    '*','markersize',12,'color',MetaData.ChannelColors{c})
            end
            pause(0.1)
        end
        fprintf('And Whole Image...')
        figure,
        set(gcf,'units','pixels','position',[50,50,MetaData.SizeX,MetaData.SizeY/2])
        subtightplot(1,2,1,[0,0],[0,0],[0,0])
        imshow(ImageData.Merge_AllChannel_MaxProj_Pre_Color,[],'border','tight')
        hold on
        text(50,50,'Merge Pre','color','w','fontsize',12)
        subtightplot(1,2,2,[0,0],[0,0],[0,0])
        imshow(ImageData.Merge_AllChannel_MaxProj_Post_Color,[],'border','tight')
        hold on
        text(50,50,'Merge Post','color','w','fontsize',12)
        fprintf('Finished!\n')
        
        Zach_a_Stack_Viewer(horzcat(ImageData.Merge_AllChannel_Stack_Pre,ImageData.Merge_AllChannel_Stack_Post));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        KeepCalculating=InputWithVerification('Enter 1 to Redo alignment: ',{1,[]},0);
        if isempty(KeepCalculating)
            KeepCalculating=0;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Saving all data...')
    save([FinalSaveDir,dc,FileID,' All Alignment Data.mat'],...
    	'ImageData','BeadStruct','MetaData','AlignmentParams')
    imwrite(double(ImageData.Merge_AllChannel_MaxProj_Pre_Color),[FinalSaveDir,dc,FileID,' Pre Alignment Max Proj Color Merge.tif']);
    imwrite(double(ImageData.Merge_AllChannel_MaxProj_Post_Color),[FinalSaveDir,dc,FileID,' Post Alignment Max Proj Color Merge.tif']);
    fprintf('Finished!\n')
    fprintf('Saving AlignmentParams...')
    save([FinalSaveDir,dc,FileID,' AlignmentParams.mat'],...
    	'AlignmentParams')
    fprintf('Finished!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning on
    close all
    dbclear all
    jheapcl
    RunProgram=0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


