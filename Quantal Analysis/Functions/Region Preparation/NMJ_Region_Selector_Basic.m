function NMJ_Region_Selector_Basic(BoutonSelectionDisplayImage, dilateSize, min_pixels, fudgeFactor,AllBoutonsRegion1)
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


%AllBoutonsRegion1=zeros(size(BoutonSelectionDisplayImage));
Contrast=[0,max(BoutonSelectionDisplayImage(:))*0.8];
AlphaLevel=0.5;
IndexNumbers=1:5;        
%initialize figure
NMJ_Region_Selector_Figure=figure;
set(NMJ_Region_Selector_Figure,'units','normalized','position',[0 0 1 1])
subtightplot(1,1,1)
%imagesc(BoutonSelectionDisplayImage),axis equal tight,caxis(ColorLimits),colormap gray
%imshow(mat2gray(BoutonSelectionDisplayImage,double(Contrast)),[])
AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
imshow(DisplayImage,[])

set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
     btn1 = uicontrol('Style', 'pushbutton', 'String', 'Find Region',...
        'units','normalized',...
        'Position', [0.93 0.95 0.07 0.03],...
        'Callback', @Find_Base_callback);     
     btn3 = uicontrol('Style', 'pushbutton', 'String', 'Select Keep',...
        'units','normalized',...
        'Position', [0.93 0.85 0.07 0.03],...
        'Callback', @Select_Keep_callback);  
     btn4 = uicontrol('Style', 'pushbutton', 'String', 'Add Region',...
        'units','normalized',...
        'Position', [0.93 0.80 0.07 0.03],...
        'Callback', @Add_Region_callback);  
     btn5 = uicontrol('Style', 'pushbutton', 'String', 'Remove Region',...
        'units','normalized',...
        'Position', [0.93 0.75 0.07 0.03],...
        'Callback', @Remove_Region_callback);      
     btn6 = uicontrol('Style', 'pushbutton', 'String', 'Expand Region',...
        'units','normalized',...
        'Position', [0.93 0.70 0.07 0.03],...
        'Callback', @Expand_Region_callback);
     btn7 = uicontrol('Style', 'pushbutton', 'String', 'Contract Region',...
        'units','normalized',...
        'Position', [0.93 0.65 0.07 0.03],...
        'Callback', @Contract_Region_callback);
    btn9 = uicontrol('Style', 'pushbutton', 'String', 'EXPORT',...
        'units','normalized',...
        'Position', [0.93 0.1 0.07 0.03],...
        'Callback', @Export_callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        else
            Contrast(2)=temp;clear temp
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
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
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        else
            Contrast(1)=temp;clear temp
            cla
            AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
            DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        end
    end
    function Find_Base_callback(src,eventdata,arg1)
        AllBoutonsRegion1 = FindRegionsOneImage(BoutonSelectionDisplayImage, dilateSize, min_pixels, fudgeFactor);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
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
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Add_Region_callback(src,eventdata,arg1)
        hold on;text(10, 10, 'Select Region to add (connect dots to finish)','color','y','FontSize',16');hold off
        AllBoutonsRegion1 = AddRegion1(AllBoutonsRegion1);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Remove_Region_callback(src,eventdata,arg1)
        hold on;text(10, 10, 'Select Region to remove (connect dots to finish)','color','y','FontSize',16');hold off
        AllBoutonsRegion1 = RemoveRegion1(AllBoutonsRegion1);
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Expand_Region_callback(src,eventdata,arg1)
        AllBoutonsRegion1Perim_Thick = bwperim(AllBoutonsRegion1,8);
        AllBoutonsRegion1Perim_Thick=imdilate(AllBoutonsRegion1Perim_Thick,ones(3));
        AllBoutonsRegion1=AllBoutonsRegion1+AllBoutonsRegion1Perim_Thick;clear AllBoutonsRegion1Perim_Thick
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Contract_Region_callback(src,eventdata,arg1)
        AllBoutonsRegion1Perim_Thick = bwperim(AllBoutonsRegion1,8);
        AllBoutonsRegion1Perim_Thick=imdilate(AllBoutonsRegion1Perim_Thick,ones(3));
        AllBoutonsRegion1(AllBoutonsRegion1Perim_Thick)=0;clear AllBoutonsRegion1Perim_Thick
        cla
        AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
        DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
        imshow(DisplayImage,[])
    end
    function Export_callback(src,eventdata,arg1)
        global ALLBOUTONSREGION_EXPORT
        ALLBOUTONSREGION_EXPORT=AllBoutonsRegion1;
        close(NMJ_Region_Selector_Figure)
    end
end
