function NMJ_Region_Selector(StatusFig,StackSaveName,BoutonSelectionDisplayImages, dilateSize, min_pixels, fudgeFactor,StackFileName_PeakArray,ImagesPerSequence, PeakImage, DeltaX_First, DeltaY_First,AllBoutonsRegion1)
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end
    pwd;
    currentFolder = pwd;
    [upperPath, deepestFolder] = fileparts(currentFolder);

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
    
    ImageOption=1;
    PeakMeanCount=3;
    BoutonSelectionDisplayImage=BoutonSelectionDisplayImages(:,:,ImageOption);
    if size(BoutonSelectionDisplayImage,1)*size(BoutonSelectionDisplayImage,2)>7000000
        warning('Large File Settings Engaged...')
        LargeFile=1;
        LargeFileDilate=11;
    elseif size(BoutonSelectionDisplayImage,1)*size(BoutonSelectionDisplayImage,2)<7000000&&...
            size(BoutonSelectionDisplayImage,1)*size(BoutonSelectionDisplayImage,2)>5000000
        warning('Medium Large File Settings Engaged...')
        LargeFile=1;
        LargeFileDilate=5;
    elseif size(BoutonSelectionDisplayImage,1)*size(BoutonSelectionDisplayImage,2)<5000000&&...
            size(BoutonSelectionDisplayImage,1)*size(BoutonSelectionDisplayImage,2)>3000000
        warning('Medium File Settings Engaged...')
        LargeFile=1;
        LargeFileDilate=1;
    else
        LargeFile=0;
    end
    %AllBoutonsRegion1=zeros(size(BoutonSelectionDisplayImage));
    Contrast=[0,max(BoutonSelectionDisplayImage(:))*0.8];
    AlphaLevel=0.5;
    IndexNumbers=1:5;        
    %initialize figure
    NMJ_Region_Selector_Figure=figure;
    set(NMJ_Region_Selector_Figure,'units','normalized','position',[0 0 1 1],'name',StackSaveName)
    subtightplot(1,1,1)
    %imagesc(BoutonSelectionDisplayImage),axis equal tight,caxis(ColorLimits),colormap gray
    %imshow(mat2gray(BoutonSelectionDisplayImage,double(Contrast)),[])
    AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
    if LargeFile==1
        AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
    elseif LargeFile==2
        AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
    end
    DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
    imshow(DisplayImage,[])
    set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NumImageOptions=size(BoutonSelectionDisplayImages,3);
    ImageOptionList=[];
    for i=1:NumImageOptions
        ImageOptionList{i}=num2str(i);
    end
    Image_Selection = uicontrol('Style', 'popup',...
        'String', ImageOptionList,...
        'units','normalized',...
        'Position', [0.01 0.96 0.04 0.03],...
        'Callback', @Select_Image);
    ImageText = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.01 0.93 0.05 0.03],...
        'String','Switch Images Here');
    
    if strfind(OS,'PC')
        % Create Contrast Sliders
        BasalHighSld = uicontrol('Style', 'slider',...
            'Min',0,'Max',2^16-1,'Value',Contrast(2),...
            'SliderStep',[1000/(2^16- 1),5000/(2^16- 1)],...
            'units','normalized',...
            'Position', [0.99,0.21 0.01 0.3],...
            'Callback', @Basal_HighContrast_callback);
        BasalHightxt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.99,0.195 0.01 0.015],...
            'String','H');
        BasalLowSld = uicontrol('Style', 'slider',...
            'Min',0,'Max',2^16-1,'Value',Contrast(1),...
            'SliderStep',[1000/(2^16- 1),5000/(2^16- 1)],...
            'units','normalized',...
            'Position', [0.98,0.21 0.01 0.3],...
            'Callback', @Basal_LowContrast_callback);
        BasalLowtxt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.98,0.195 0.01 0.015],...
            'String','L');
    else
       % Create Contrast Sliders
        BasalHighSld = uicontrol('Style', 'slider',...
            'Min',0,'Max',2^16-1,'Value',Contrast(2),...
            'SliderStep',[1000/(2^16- 1),5000/(2^16- 1)],...
            'units','normalized',...
            'Position', [0.95,0.21 0.05 0.3],...
            'Callback', @Basal_HighContrast_callback);
        BasalHightxt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.99,0.195 0.01 0.015],...
            'String','H');
        BasalLowSld = uicontrol('Style', 'slider',...
            'Min',0,'Max',2^16-1,'Value',Contrast(1),...
            'SliderStep',[1000/(2^16- 1),5000/(2^16- 1)],...
            'units','normalized',...
            'Position', [0.94,0.21 0.05 0.3],...
            'Callback', @Basal_LowContrast_callback);
        BasalLowtxt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.98,0.195 0.01 0.015],...
            'String','L');     
    end
    %Create Buttons
     btn0 = uicontrol('Style', 'pushbutton', 'String', 'Edit Image',...
        'units','normalized',...
        'Position', [0.01 0.9 0.07 0.03],...
        'Callback', @EditImage);     
     btn1 = uicontrol('Style', 'pushbutton', 'String', 'Find Basal',...
        'units','normalized',...
        'Position', [0.93 0.95 0.07 0.03],...
        'Callback', @Find_Base_callback);     
     btn2 = uicontrol('Style', 'pushbutton', 'String', 'Find Peak',...
        'units','normalized',...
        'Position', [0.93 0.91 0.07 0.03],...
        'Callback', @Find_Peak_callback);     
     btn3 = uicontrol('Style', 'pushbutton', 'String', 'Select Keep',...
        'units','normalized',...
        'Position', [0.93 0.87 0.07 0.03],...
        'Callback', @Select_Keep_callback);  
     btn4 = uicontrol('Style', 'pushbutton', 'String', 'Add Region',...
        'units','normalized',...
        'Position', [0.93 0.83 0.07 0.03],...
        'Callback', @Add_Region_callback);  
     btn5 = uicontrol('Style', 'pushbutton', 'String', 'Remove Region',...
        'units','normalized',...
        'Position', [0.93 0.79 0.07 0.03],...
        'Callback', @Remove_Region_callback);      
     btn6 = uicontrol('Style', 'pushbutton', 'String', 'Expand Region',...
        'units','normalized',...
        'Position', [0.93 0.75 0.07 0.03],...
        'Callback', @Expand_Region_callback);
     btn7 = uicontrol('Style', 'pushbutton', 'String', 'Contract Region',...
        'units','normalized',...
        'Position', [0.93 0.71 0.07 0.03],...
        'Callback', @Contract_Region_callback);
     btn8 = uicontrol('Style', 'radiobutton', 'String', 'Overlay Peaks',...
        'units','normalized',...
        'Position', [0.93 0.67 0.07 0.03],...
        'Callback', @Overlay_Peaks_callback);
    btn9 = uicontrol('Style', 'pushbutton', 'String', 'EXPORT',...
        'units','normalized',...
        'Position', [0.93 0.1 0.07 0.03],...
        'Callback', @Export_callback);
    
    dilateSize_Ctl = uicontrol('Style', 'edit', 'string',num2str(dilateSize),...
        'units','normalized',...
        'Position', [0.98 0.63 0.02 0.02]);      
    dilateSize_btn = uicontrol('Style', 'pushbutton', 'String', 'dilateSize>',...
        'units','normalized',...
        'Position', [0.945 0.63 0.035 0.025],...
        'Callback', @Change_dilateSize_callback); 
    min_pixels_Ctl = uicontrol('Style', 'edit', 'string',num2str(min_pixels),...
        'units','normalized',...
        'Position', [0.98 0.60 0.02 0.02]);      
    min_pixels_btn = uicontrol('Style', 'pushbutton', 'String', 'min_pixels>',...
        'units','normalized',...
        'Position', [0.945 0.60 0.035 0.025],...
        'Callback', @Change_min_pixels_callback); 
    fudgeFactor_Ctl = uicontrol('Style', 'edit', 'string',num2str(fudgeFactor),...
        'units','normalized',...
        'Position', [0.98 0.57 0.02 0.02]);      
    fudgeFactor_btn = uicontrol('Style', 'pushbutton', 'String', 'fudgeFactor>',...
        'units','normalized',...
        'Position', [0.945 0.57 0.035 0.025],...
        'Callback', @Change_fudgeFactor_callback); 


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function EditImage(src,eventdata,arg1)
        fprintf('Editing Image...')
        figure(NMJ_Region_Selector_Figure);
        txt=text(20,20,'Select Region to remove from image...','color','y','fontsize',20);
        TempROI=roipoly;
        BoutonSelectionDisplayImage(TempROI)=0;
        clear TempROI
        delete(txt)
        figure(NMJ_Region_Selector_Figure);
        subtightplot(1,1,1)
        %imagesc(BoutonSelectionDisplayImage),axis equal tight,caxis(ColorLimits),colormap gray
        %imshow(mat2gray(BoutonSelectionDisplayImage,double(Contrast)),[])
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        fprintf('Finished!')
    end
    
    function Select_Image(src,eventdata,arg1)
        disp('Switching Images...')
        ImageOptionNew=get(Image_Selection,'value');
        if ImageOptionNew~=ImageOption
            ImageOption=ImageOptionNew;
            BoutonSelectionDisplayImage=BoutonSelectionDisplayImages(:,:,ImageOption);
            figure(NMJ_Region_Selector_Figure);
            subtightplot(1,1,1)
            %imagesc(BoutonSelectionDisplayImage),axis equal tight,caxis(ColorLimits),colormap gray
            %imshow(mat2gray(BoutonSelectionDisplayImage,double(Contrast)),[])
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            if LargeFile
                AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
            end
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
            set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        end
    end
    
    function PeakDisplayImage=Peak_Image_Averaging
        if ischar(StackFileName_PeakArray)
            for i=1:length(IndexNumbers)
               TempImage = ReadGoodImages(StackFileName, ((IndexNumbers(i)-1)*ImagesPerSequence+PeakImage));
               TempImage = imfilter(TempImage, fspecial('gaussian', 11, 1)); %original 7 and 0.8/0.7
               TempStack(:,:,i)=TranslateImage(TempImage, DeltaY_First(IndexNumbers(i)), DeltaX_First(IndexNumbers(i)));
            end
            PeakDisplayImage = mean(TempStack,PeakMeanCount);clear TempStack
        else
            PeakDisplayImage = mean(StackFileName_PeakArray,PeakMeanCount);clear TempStack
        end
    end
    function TempPeakDF_ImageArray_Max=Peak_DF_Max
        for i=1:length(IndexNumbers)
           TempImage = ReadGoodImages(StackFileName, ((IndexNumbers(i)-1)*ImagesPerSequence+1));
           TempImage = imfilter(TempImage, fspecial('gaussian', 11, 1)); %original 7 and 0.8/0.7
           TempBaseImage=TranslateImage(TempImage, DeltaY_First(IndexNumbers(i)), DeltaX_First(IndexNumbers(i)));
           TempImage = imfilter(TempImage, fspecial('gaussian', 11, 1)); %original 7 and 0.8/0.7
           TempImage = ReadGoodImages(StackFileName, ((IndexNumbers(i)-1)*ImagesPerSequence+PeakImage));
           TempPeakImage=TranslateImage(TempImage, DeltaY_First(IndexNumbers(i)), DeltaX_First(IndexNumbers(i)));
           TempPeakDF_ImageArray(:,:,i)=(double(TempPeakImage)-double(TempBaseImage));%./double(TempBaseImage);
           clear TempPeakImage TempBaseImage TempImage
        end
        TempPeakDF_ImageArray_Max = max(TempPeakDF_ImageArray,[],3);clear TempPeakDF_ImageArray
    end
    function AllBoutonsRegion1 = AddRegion1(AllBoutonsRegion1) % draw a region, this region will be added to the logical image
        Region1 = roipoly; % draw a region on the current figure
        AllBoutonsRegion1 = AllBoutonsRegion1 | Region1; %Add Region
    end

    function AllBoutonsRegion1 = RemoveRegion1(AllBoutonsRegion1) % draw a region, this region will be removed from the logical image
        Region1 = roipoly; % draw a region on the current figure
        Region1 = imcomplement(Region1);
        AllBoutonsRegion1=AllBoutonsRegion1 .* Region1; % remove the region from AllRegions    
    end
    function Basal_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=Contrast(1)
            warning('Not possible')
            set(src,'Value',Contrast(2))
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            if LargeFile
                AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
            end
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        else
            Contrast(2)=temp;clear temp
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            if LargeFile
                AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
            end
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        end
    end
    function Basal_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if Contrast(2)<=temp
            warning('Not possible')
            set(src,'Value',Contrast(1))
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            if LargeFile
                AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
            end
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        else
            Contrast(1)=temp;clear temp
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            if LargeFile
                AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
            end
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        end
    end
    function Overlay_Peaks_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp
            TempDeltaF=Peak_DF_Max;
            DF_ColorMax=max(TempDeltaF(:))*0.7;
            TempDeltaF(TempDeltaF<0)=0;
            C=jet(256);
            L = size(C,1);
            TempDeltaF(TempDeltaF>=DF_ColorMax)=DF_ColorMax;
            TempDeltaF(TempDeltaF<=0)=0;
            TempDeltaF_rgb = round(interp1(linspace(0,DF_ColorMax,L),1:L,TempDeltaF));
            TempDeltaF_rgb = reshape(C(TempDeltaF_rgb,:),[size(TempDeltaF_rgb) 3]); 
            hold on
            %h=imagesc(TempPeakDF_ImageArray_Max,[0,max(TempPeakDF_ImageArray_Max(:))*0.5]);
            h = imshow( TempDeltaF_rgb,[]);
            colormap jet;
            set(h, 'AlphaData', AlphaLevel);  
            hold off
        else
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            if LargeFile
                AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
            end
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        end
    end
    function Find_Base_callback(src,eventdata,arg1)
        AllBoutonsRegion1 = FindRegionsOneImage(BoutonSelectionDisplayImage, dilateSize, min_pixels, fudgeFactor);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Find_Peak_callback(src,eventdata,arg1)
        PeakDisplayImage=Peak_Image_Averaging;
        AllBoutonsRegion1 = FindRegionsOneImage(PeakDisplayImage, dilateSize, min_pixels, fudgeFactor);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Select_Keep_callback(src,eventdata,arg1)
        hold on
        h=imshow(AllBoutonsRegion1,[]);
        hold on;text(10, 10, 'Select Regions to Keep (<Enter> to finish selection)','color','y','FontSize',16');hold off
        set(h, 'AlphaData', AlphaLevel);  
        AllBoutonsRegion1 = bwselect;
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Add_Region_callback(src,eventdata,arg1)
        hold on;text(10, 10, 'Select Region to add (connect dots to finish)','color','y','FontSize',16');hold off
        AllBoutonsRegion1 = AddRegion1(AllBoutonsRegion1);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Remove_Region_callback(src,eventdata,arg1)
        hold on;text(10, 10, 'Select Region to remove (connect dots to finish)','color','y','FontSize',16');hold off
        AllBoutonsRegion1 = RemoveRegion1(AllBoutonsRegion1);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end

    function Expand_Region_callback(src,eventdata,arg1)
        AllBoutonsRegion1Perim_Thick = bwperim(AllBoutonsRegion1,8);
        AllBoutonsRegion1Perim_Thick=imdilate(AllBoutonsRegion1Perim_Thick,ones(3));
        AllBoutonsRegion1=AllBoutonsRegion1+AllBoutonsRegion1Perim_Thick;clear AllBoutonsRegion1Perim_Thick
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Contract_Region_callback(src,eventdata,arg1)
        AllBoutonsRegion1Perim_Thick = bwperim(AllBoutonsRegion1,8);
        AllBoutonsRegion1Perim_Thick=imdilate(AllBoutonsRegion1Perim_Thick,ones(3));
        AllBoutonsRegion1(AllBoutonsRegion1Perim_Thick)=0;clear AllBoutonsRegion1Perim_Thick
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        if LargeFile
            AllBoutonsRegion1Perim = imdilate(AllBoutonsRegion1Perim, ones(LargeFileDilate));
        end
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Change_dilateSize_callback(src,eventdata,arg1)
        dilateSize=str2num(get(dilateSize_Ctl,'String'));
        set(dilateSize_Ctl,'Value',dilateSize)
    end
    function Change_min_pixels_callback(src,eventdata,arg1)
        min_pixels=str2num(get(min_pixels_Ctl,'String'));
        set(min_pixels_Ctl,'Value',min_pixels)
    end
    function Change_fudgeFactor_callback(src,eventdata,arg1)
        fudgeFactor=str2num(get(fudgeFactor_Ctl,'String'));
        set(fudgeFactor_Ctl,'Value',fudgeFactor)
    end


    function Export_callback(src,eventdata,arg1)
        global ALLBOUTONSREGION1
        ALLBOUTONSREGION1=AllBoutonsRegion1;
        close(NMJ_Region_Selector_Figure)
    end
end
