function General_Region_Selector(ID_Name,SelectionDisplayImage, SelectionRegion, SelectionRegion_BorderLines, Additional_Markers,Additional_BorderLines)
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

    if ret ~= 0
       if ispc
          compName = getenv('COMPUTERNAME');
       else      
          compName = getenv('HOSTNAME');      
       end
    end
    compName = lower(compName);
    compName=cellstr(compName);
    compName=compName{1};
    
RegionBorders = zeros(size(SelectionDisplayImage,1),size(SelectionDisplayImage,2),'logical');


RegionCount = 0;
ActiveSelection=0;
RegionArray=[];
Contrast=[0,max(SelectionDisplayImage(:))*0.8];
SelectionRegionPerim = bwperim(SelectionRegion);
DisplayImage = imoverlay(mat2gray(SelectionDisplayImage,double(Contrast)), SelectionRegionPerim, [1 1 0]); % [0 1 1] = color
AlphaLevel=0.5;   
%initialize figure
Region_Selector_Figure=figure;
set(Region_Selector_Figure,'units','normalized','position',[0 0 1 1],'name',ID_Name)
subtightplot(1,1,1)
%imagesc(SelectionDisplayImage),axis equal tight,caxis(ColorLimits),colormap gray
imshow(DisplayImage,[])
set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
hold on
if ~isempty(SelectionRegion_BorderLines)
    for b=1:length(SelectionRegion_BorderLines)
        plot(SelectionRegion_BorderLines(b).Line(:,2),...
            SelectionRegion_BorderLines(b).Line(:,1),...
            '-','color',SelectionRegion_BorderLines(b).Color,'linewidth',1)
    end
end
if ~isempty(Additional_BorderLines)
    for b=1:length(Additional_BorderLines)
        plot(Additional_BorderLines(b).Line(:,2),...
            Additional_BorderLines(b).Line(:,1),...
            '-','color',Additional_BorderLines(b).Color,'linewidth',1)
    end
end
if ~isempty(Additional_Markers)
    for b=1:length(Additional_Markers)
        plot(Additional_Markers(b).Coord(1),...
            Additional_Markers(b).Coord(2),...
            Additional_Markers(b).MarkerStyle,'color',Additional_Markers(b).Color,...
            'MarkerSize',Additional_Markers(b).MarkerSize)
    end
end
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
     btn1 = uicontrol('Style', 'pushbutton', 'String', 'Add',...
        'units','normalized',...
        'Position', [0.93 0.95 0.07 0.03],...
        'Callback', @AddRegion_callback);     
    % Create field for deleting one Region
    index = uicontrol('Style', 'edit', 'string',num2str(0),...
        'units','normalized',...
        'Position', [0.93 0.90 0.07 0.03]);     
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Delete ^',...
        'units','normalized',...
        'Position', [0.93 0.85 0.07 0.03],...
        'Callback', @DeleteRegion_callback);
     btn3 = uicontrol('Style', 'radiobutton', 'String', 'Check Overlap',...
        'units','normalized',...
        'Position', [0.93 0.80 0.07 0.03],...
        'Callback', @CheckRegions_callback);  
     btn4 = uicontrol('Style', 'radiobutton', 'String', 'Check Coverage',...
        'units','normalized',...
        'Position', [0.93 0.75 0.07 0.03],...
        'Callback', @CheckCoverage_callback);  
    btn5 = uicontrol('Style', 'pushbutton', 'String', 'EXPORT',...
        'units','normalized',...
        'Position', [0.93 0.1 0.07 0.03],...
        'Callback', @Export_callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
%     function RegionPlotter(RegionArray)

  
%         
%     end
    function RegionArray = AddRegion(RegionArray,SelectionRegion) % draw a region, this region will be added to the logical image
        hold on;
        Txt1=text(10, 10, sprintf('Select Regions from distal to proximal for branch %d. Create empty ROI to move to next branch',j),'color','y','FontSize',12');
        cont = 1;     
        while cont
            ActiveSelection=1;
            RegionRegion = roipoly;
            cont = any(RegionRegion(:));
            RegionRegion = RegionRegion & SelectionRegion; % RegionRegion will be the selected region x SelectionRegion
            RegionPerim = bwperim(RegionRegion);
            [BorderY BorderX] = find(RegionPerim);
            TempRegionRegion = zeros(size(SelectionDisplayImage,1),size(SelectionDisplayImage,2),'logical');
            TempRegionRegion(RegionRegion) = 1;
            if cont
                RegionCount = RegionCount + 1;
                 RegionArray(RegionCount).ImageArea = TempRegionRegion;
                 RegionArray(RegionCount).TempRegionRegionPerim=RegionPerim;
                 RegionArray(RegionCount).TempBorderX=BorderX;
                 RegionArray(RegionCount).TempBorderY=BorderY;
                 hold on
                plot(RegionArray(RegionCount).TempBorderX, RegionArray(RegionCount).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                text(mean(RegionArray(RegionCount).TempBorderX),mean(RegionArray(RegionCount).TempBorderY),num2str(RegionCount),'color','m','FontSize',30)
                hold off
            end
        end
        clear cont TempRegionRegion;
        delete(Txt1)
        hold off;
        ActiveSelection=0;
    end


    function RegionArray = RemoveRegion(RegionArray,RegionNumberToDelete)
        cla
        NumRegions=size(RegionArray,2);
        imshow(DisplayImage,[])
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        RegionCount=0;
        for i=1:NumRegions
            if i==RegionNumberToDelete
            else
                RegionCount=RegionCount+1;
                NewRegionArray(RegionCount)=RegionArray(i);

                hold on
                plot(NewRegionArray(RegionCount).TempBorderX, NewRegionArray(RegionCount).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                text(mean(NewRegionArray(RegionCount).TempBorderX),mean(NewRegionArray(RegionCount).TempBorderY),num2str(RegionCount),'color','m','FontSize',30)
                hold off
            end
        end
        RegionArray=NewRegionArray;
        clear NewRegionArray RegionNumberToDelete
    end
    function SelectionRegion = RemoveRegion1(SelectionRegion) % draw a region, this region will be removed from the logical image
        Region1 = roipoly; % draw a region on the current figure
        Region1 = imcomplement(Region1);
        SelectionRegion=SelectionRegion .* Region1; % remove the region from AllRegions    
    end
    function Basal_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=Contrast(1)
            warning('Not possible')
            set(src,'Value',Contrast(2))
            cla
            SelectionRegionPerim = bwperim(SelectionRegion);
            DisplayImage = imoverlay(mat2gray(SelectionDisplayImage,double(Contrast)), SelectionRegionPerim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        else
            Contrast(2)=temp;clear temp
            cla
            SelectionRegionPerim = bwperim(SelectionRegion);
            DisplayImage = imoverlay(mat2gray(SelectionDisplayImage,double(Contrast)), SelectionRegionPerim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        end
    end
    function Basal_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if Contrast(2)<=temp
            warning('Not possible')
            set(src,'Value',Contrast(1))
            cla
            SelectionRegionPerim = bwperim(SelectionRegion);
            DisplayImage = imoverlay(mat2gray(SelectionDisplayImage,double(Contrast)), SelectionRegionPerim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        else
            Contrast(1)=temp;clear temp
            cla
            SelectionRegionPerim = bwperim(SelectionRegion);
            DisplayImage = imoverlay(mat2gray(SelectionDisplayImage,double(Contrast)), SelectionRegionPerim, [1 1 0]); % [0 1 1] = color
            imshow(DisplayImage,[])
        end
    end

    function AddRegion_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            RegionArray = AddRegion(RegionArray,SelectionRegion);
        end
    end
    function DeleteRegion_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            RegionNumberToDelete=str2num(get(index,'String'));
            RegionArray = RemoveRegion(RegionArray,RegionNumberToDelete);
            set(index,'String',num2str(0));
        end
    end
    function CheckRegions_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            temp = get(src,'Value');
            if temp
                cla
                AllRegionsImage=zeros(size(SelectionDisplayImage,1),size(SelectionDisplayImage,2),'logical');
                for i=1:size(RegionArray,2)
                    AllRegionsImage=AllRegionsImage+RegionArray(i).ImageArea;
                end
                TestImage=AllRegionsImage;
                TestImage_RGB=zeros(size(TestImage,1),size(TestImage,2),3);
                for i=1:size(TestImage,1)
                    for j=1:size(TestImage,2)
                        if TestImage(i,j)>1
                            TestImage_RGB(i,j,1)=1;TestImage_RGB(i,j,2)=0;TestImage_RGB(i,j,3)=0;
                        elseif TestImage(i,j)==1
                            TestImage_RGB(i,j,1)=1;TestImage_RGB(i,j,2)=1;TestImage_RGB(i,j,3)=1;
                        end
                    end
                end
                imshow(TestImage_RGB)
                clear AllRegionsImage TestImage TestImage_RGB
            else
                cla
                imshow(DisplayImage,[])
                set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                for i=1:size(RegionArray,2)
                    hold on
                    plot(RegionArray(i).TempBorderX, RegionArray(i).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                    text(mean(RegionArray(i).TempBorderX),mean(RegionArray(i).TempBorderY),num2str(i),'color','m','FontSize',30)
                    hold off
                end
            end
        end
    end
    function CheckCoverage_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            temp = get(src,'Value');
            if temp
                cla
                AllRegionsImage=zeros(size(SelectionDisplayImage,1),size(SelectionDisplayImage,2),'logical');
                for i=1:size(RegionArray,2)
                    AllRegionsImage=AllRegionsImage+RegionArray(i).ImageArea;
                end
                AllRegionsImage=logical(AllRegionsImage);
                TestImage=AllRegionsImage+SelectionRegion;
                TestImage_RGB=zeros(size(TestImage,1),size(TestImage,2),3);
                for i=1:size(TestImage,1)
                    for j=1:size(TestImage,2)
                        if TestImage(i,j)>1
                            TestImage_RGB(i,j,1)=1;TestImage_RGB(i,j,2)=1;TestImage_RGB(i,j,3)=1;
                        elseif TestImage(i,j)==1
                            TestImage_RGB(i,j,1)=1;TestImage_RGB(i,j,2)=0;TestImage_RGB(i,j,3)=0;
                        end
                    end
                end
                imshow(TestImage_RGB)
                clear AllRegionsImage TestImage TestImage_RGB
            else
                cla
                imshow(DisplayImage,[])
                set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                for i=1:size(RegionArray,2)
                    hold on
                    plot(RegionArray(i).TempBorderX, RegionArray(i).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                    text(mean(RegionArray(i).TempBorderX),mean(RegionArray(i).TempBorderY),num2str(i),'color','m','FontSize',30)
                    hold off
                end
            end
        end
    end

    function Export_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            global REGIONARRAY
            REGIONARRAY=RegionArray;
            close(Region_Selector_Figure)
        end
    end
    commandwindow
end