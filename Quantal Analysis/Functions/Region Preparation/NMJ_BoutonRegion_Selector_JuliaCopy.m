function NMJ_BoutonRegion_Selector_JuliaCopy(StackSaveName,BoutonSelectionDisplayImage, AllBoutonsRegion1,BorderLines)
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
    
BoutonBorders = zeros(size(BoutonSelectionDisplayImage));


BoutonCount = 0;
ActiveSelection=0;
BoutonArray1=[];
Contrast=[0,max(BoutonSelectionDisplayImage(:))*0.8];
AllBoutonsRegion1Perim = bwperim(AllBoutonsRegion1);
DisplayImage = imoverlay(mat2gray(BoutonSelectionDisplayImage,double(Contrast)), AllBoutonsRegion1Perim, [1 1 0]); % [0 1 1] = color
AlphaLevel=0.5;   
%initialize figure
NMJ_BoutonRegion_Selector_Figure=figure;
set(NMJ_BoutonRegion_Selector_Figure,'units','normalized','position',[0 0 1 1],'name',StackSaveName)
subtightplot(1,1,1)
%imagesc(BoutonSelectionDisplayImage),axis equal tight,caxis(ColorLimits),colormap gray
imshow(DisplayImage,[])
set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
hold on
if ~isempty(BorderLines)
    for b=1:length(BorderLines)
        plot(BorderLines(b).Line(:,2),...
            BorderLines(b).Line(:,1),...
            '-','color',BorderLines(b).Color,'linewidth',1)
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
        'Callback', @AddBoutons_callback);     
    % Create field for deleting one bouton
    index = uicontrol('Style', 'edit', 'string',num2str(0),...
        'units','normalized',...
        'Position', [0.93 0.90 0.07 0.03]);     
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Delete ^',...
        'units','normalized',...
        'Position', [0.93 0.85 0.07 0.03],...
        'Callback', @DeleteBouton_callback);
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
      
%     function BoutonPlotter(BoutonArray1)

  
%         
%     end
    function BoutonArray1 = AddBoutons(BoutonArray1,AllBoutonsRegion1) % draw a region, this region will be added to the logical image
        hold on;
        Txt1=text(10, 10, sprintf('Select boutons from distal to proximal for branch %d. Create empty ROI to move to next branch',j),'color','y','FontSize',12');
        cont = 1;     
        while cont
            ActiveSelection=1;
            BoutonRegion = roipoly;
            cont = any(BoutonRegion(:));
            BoutonRegion = BoutonRegion & AllBoutonsRegion1; % BoutonRegion will be the selected region x AllBoutonsRegion1
            BoutonPerim = bwperim(BoutonRegion);
            [BorderY BorderX] = find(BoutonPerim);
            TempBoutonRegion = zeros(size(BoutonSelectionDisplayImage));
            TempBoutonRegion(BoutonRegion) = 1;
            if cont
                BoutonCount = BoutonCount + 1;
                 BoutonArray1(BoutonCount).ImageArea = TempBoutonRegion;
                 BoutonArray1(BoutonCount).TempBoutonRegionPerim=BoutonPerim;
                 BoutonArray1(BoutonCount).TempBorderX=BorderX;
                 BoutonArray1(BoutonCount).TempBorderY=BorderY;
                 hold on
                plot(BoutonArray1(BoutonCount).TempBorderX, BoutonArray1(BoutonCount).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                text(mean(BoutonArray1(BoutonCount).TempBorderX),mean(BoutonArray1(BoutonCount).TempBorderY),num2str(BoutonCount),'color','m','FontSize',30)
                hold off
            end
        end
        clear cont TempBoutonRegion;
        delete(Txt1)
        hold off;
        ActiveSelection=0;
    end


    function BoutonArray1 = RemoveBouton(BoutonArray1,BoutonNumberToDelete)
        cla
        NumBoutons=size(BoutonArray1,2);
        imshow(DisplayImage,[])
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        BoutonCount=0;
        for i=1:NumBoutons
            if i==BoutonNumberToDelete
            else
                BoutonCount=BoutonCount+1;
                NewBoutonArray(BoutonCount)=BoutonArray1(i);

                hold on
                plot(NewBoutonArray(BoutonCount).TempBorderX, NewBoutonArray(BoutonCount).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                text(mean(NewBoutonArray(BoutonCount).TempBorderX),mean(NewBoutonArray(BoutonCount).TempBorderY),num2str(BoutonCount),'color','m','FontSize',30)
                hold off
            end
        end
        BoutonArray1=NewBoutonArray;
        clear NewBoutonArray BoutonNumberToDelete
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

    function AddBoutons_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            BoutonArray1 = AddBoutons(BoutonArray1,AllBoutonsRegion1);
        end
    end
    function DeleteBouton_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            BoutonNumberToDelete=str2num(get(index,'String'));
            BoutonArray1 = RemoveBouton(BoutonArray1,BoutonNumberToDelete);
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
                AllBoutonsImage=zeros(size(BoutonSelectionDisplayImage));
                for i=1:size(BoutonArray1,2)
                    AllBoutonsImage=AllBoutonsImage+BoutonArray1(i).ImageArea;
                end
                TestImage=AllBoutonsImage;
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
                clear AllBoutonsImage TestImage TestImage_RGB
            else
                cla
                imshow(DisplayImage,[])
                set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                for i=1:size(BoutonArray1,2)
                    hold on
                    plot(BoutonArray1(i).TempBorderX, BoutonArray1(i).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                    text(mean(BoutonArray1(i).TempBorderX),mean(BoutonArray1(i).TempBorderY),num2str(i),'color','m','FontSize',30)
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
                AllBoutonsImage=zeros(size(BoutonSelectionDisplayImage));
                for i=1:size(BoutonArray1,2)
                    AllBoutonsImage=AllBoutonsImage+BoutonArray1(i).ImageArea;
                end
                AllBoutonsImage=logical(AllBoutonsImage);
                TestImage=AllBoutonsImage+AllBoutonsRegion1;
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
                clear AllBoutonsImage TestImage TestImage_RGB
            else
                cla
                imshow(DisplayImage,[])
                set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                for i=1:size(BoutonArray1,2)
                    hold on
                    plot(BoutonArray1(i).TempBorderX, BoutonArray1(i).TempBorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
                    text(mean(BoutonArray1(i).TempBorderX),mean(BoutonArray1(i).TempBorderY),num2str(i),'color','m','FontSize',30)
                    hold off
                end
            end
        end
    end

    function Export_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            global BOUTONARRAY1
            BOUTONARRAY1=BoutonArray1;
            close(NMJ_BoutonRegion_Selector_Figure)
        end
    end
    commandwindow
end