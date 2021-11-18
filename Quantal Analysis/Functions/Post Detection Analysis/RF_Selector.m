
function RF_Selector(StackSaveName,DefaultRFSize)
    global FINISHED_SELECTING_RFS
    FINISHED_SELECTING_RFS=0;
    disp(['Loading maps for: ',StackSaveName]);
    disp(['Default RF size: ',num2str(DefaultRFSize)])
    fprintf('Loading Data.');
    pause(0.01);
    if exist([StackSaveName '_Probs.mat']);
        load([StackSaveName '_Probs.mat'],'SingleRF_Struct','se');
        LastRFNumber=length(SingleRF_Struct);
    else
        se=ones(DefaultRFSize);
        SingleRF_Struct=[];
        LastRFNumber=length(SingleRF_Struct);
    end
    load([StackSaveName '_First'], 'GoodImages', 'ImagesPerSequence', 'StackFileName','FilterSize','FilterSigma');
    load([StackSaveName '_ScaleBar'],'ScaleBar');
    load([StackSaveName '_GFPs_1'], 'AllBoutonsRegion');
    AllBoutonsRegionPerim = bwperim(AllBoutonsRegion);
    fprintf('.');pause(0.01);
    load([StackSaveName '_Results1'], 'ProbFilterSigma','ProbFilterSize');
    fprintf('.');pause(0.01);
    load([StackSaveName '_Results1'], 'OneImage_WithStim_Max_Sharp_Prob', 'OneImage_WithStim_Max_Sharp_Prob_Filt','OneImage_WithStim_Max_Sharp_Prob_Filt_LocalMax','LocalMaximaCoordinates','ProbFilterSigma','ProbFilterSize','OneImage_MaxProbLocations');
    fprintf('.');pause(0.01);
    load([StackSaveName '_Results1'], 'OneImage_WithStim_Max_Sharp_Prob_Baseline','OneImage_WithStim_Max_Sharp_Prob_Filt_LocalMax_Baseline','LocalMaximaCoordinates_Baseline','OneImage_MaxProbLocations_Baseline');
    fprintf('.');pause(0.01);
    DefaultSinglePixelSize=3;
    if exist([StackSaveName '_Pixel_Results.mat']);
        load([StackSaveName '_Pixel_Results'],'SinglePixelData');
        fprintf('.');pause(0.01);
        for i=1:length(SinglePixelData)
            if SinglePixelData(i).size==DefaultSinglePixelSize
                OneImage_AllPixel_ProbMap=SinglePixelData(i).OneImage_AllPixel_ProbMap;
                OneImage_AllPixel_ProbMap(isnan(OneImage_AllPixel_ProbMap))=0;
            end
        end
        clear SinglePixelData
    else
        OneImage_AllPixel_ProbMap=zeros(size(OneImage_WithStim_Max_Sharp_Prob));
        fprintf('.');pause(0.01);
    end
    fprintf('.');pause(0.01);
    load([StackSaveName '_BoutonArray'], 'BoutonArray');
    load([StackSaveName '_GFPs_1'],'Crop_Props');
    ReferenceImage=ReadGoodImages(StackFileName, 1);
    ReferenceImage=imfilter(ReferenceImage, fspecial('gaussian', FilterSize, FilterSigma));
    ReferenceImage=imcrop(ReferenceImage,Crop_Props.BoundingBox);
    for i=1:length(BoutonArray)
        BoutonArray(i).ImageAreaCrop = logical(imcrop(BoutonArray(i).ImageArea, Crop_Props.BoundingBox));
        BoutonArray(i).BoutonPerimCrop = bwperim(BoutonArray(i).ImageAreaCrop);    
        [BoutonArray(i).BorderYCrop BoutonArray(i).BorderXCrop] = find(BoutonArray(i).BoutonPerimCrop); 
    end
    save([StackSaveName '_BoutonArray'], 'BoutonArray','-append');
    fprintf('.');pause(0.01);
    % %Probability map all indicies
     OneImage_WithStim_Max_Sharp_Prob_Filt = imfilter(OneImage_WithStim_Max_Sharp_Prob, fspecial('gaussian', ProbFilterSize, ProbFilterSigma));
     fprintf('.');pause(0.01);
    % %probability map baseline only
     OneImage_WithStim_Max_Sharp_Prob_Filt_Baseline = imfilter(OneImage_WithStim_Max_Sharp_Prob_Baseline, fspecial('gaussian', ProbFilterSize, ProbFilterSigma));
    fprintf('.');pause(0.01);
     %probability map difference
    OneImage_WithStim_Max_Sharp_Prob_Filt_Delta=OneImage_WithStim_Max_Sharp_Prob_Filt-OneImage_WithStim_Max_Sharp_Prob_Filt_Baseline;
    NumberLocalMaxima=size(LocalMaximaCoordinates,1);
    NumberLocalMaxima_Baseline=size(LocalMaximaCoordinates_Baseline,1);
    fprintf('.');pause(0.01);
    PrContrast=[0,max(OneImage_WithStim_Max_Sharp_Prob_Filt(:))*0.8];
    DeltaPrContrast=[max(abs(OneImage_WithStim_Max_Sharp_Prob_Filt_Delta(:)))*-.8,max(abs(OneImage_WithStim_Max_Sharp_Prob_Filt_Delta(:)))*0.8];
    ReferenceContrast=[0,max(ReferenceImage(:))*0.8];
    SinglePixelPrContrast=[0,max(OneImage_AllPixel_ProbMap(:))*0.8];
    AlphaLevel=0.5;
    fprintf('.');pause(0.01);
    fprintf('\n')
    if exist([StackSaveName '_Probs.mat']);
        warning('Already found RFs, loading previous locations...');
    end
    if ~exist([StackSaveName '_Pixel_Results.mat']);
        warning('Missing Single Pixel Data...')
    end
    ZerosImage = zeros(size(OneImage_WithStim_Max_Sharp_Prob_Filt_Baseline));
    ZoomRegion_Props.BoundingBox=[1,1,size(OneImage_WithStim_Max_Sharp_Prob_Filt,2),size(OneImage_WithStim_Max_Sharp_Prob_Filt,1)];
    Plots=[];
    TextLabels=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize figure
    Map2Display=1;
    ActiveSelection=0;
    CurrentMap='Sharp Filt';
    AlignmentBoutonBorders=1;
    LocalMax=0;
    LocalBaseMax=0;
    RF_Choices=1;
    RF_Selector_Figure=figure;
    set(RF_Selector_Figure,'units','normalized','position',[0 0 1 1],'name',[StackSaveName, 'Current Map: ',CurrentMap,' #RFs: ',num2str(LastRFNumber)])
    subtightplot(1,1,1)
    MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Create pop-up menu
     popup1 = uicontrol('Style', 'popup',...
           'String', {'Sharp Filt','Sharp','Sharp Filt Base','Sharp Base','Delta','Single','F_0'},...
            'units','normalized',...
            'Position', [0.95 0.97 0.05 0.03],...
           'Callback', @setmap);
     % Create field for changing RF size
     index1 = uicontrol('Style', 'edit', 'string',num2str(size(se,1)),...
        'units','normalized',...
        'Position', [0.02 0.97 0.02 0.03]);     
     btn2 = uicontrol('Style', 'pushbutton', 'String', 'RF>',...
        'units','normalized',...
        'Position', [0 0.97 0.02 0.03],...
        'Callback', @EditRFSize_callback);
     btn1 = uicontrol('Style', 'togglebutton', 'String', 'Bout',...
        'units','normalized',...
        'value',AlignmentBoutonBorders,...
        'Position', [0.97 0.94 0.03 0.03],...
        'Callback', @AddBoutons_callback);  
     btn2 = uicontrol('Style', 'togglebutton', 'String', 'Max',...
        'units','normalized',...
        'value',LocalMax,...
        'Position', [0.97 0.91 0.03 0.03],...
        'Callback', @AddMax_callback);         
     btn3 = uicontrol('Style', 'togglebutton', 'String', 'MaxB',...
        'units','normalized',...
        'value',LocalBaseMax,...
        'Position', [0.97 0.88 0.03 0.03],...
        'Callback', @AddMaxBase_callback);         
     btn4 = uicontrol('Style', 'togglebutton', 'String', 'RF',...
        'units','normalized',...
        'value',RF_Choices,...
        'Position', [0.97 0.85 0.03 0.03],...
        'Callback', @AddRFDisplay_callback);  
     btn5 = uicontrol('Style', 'togglebutton', 'String', 'Zoom',...
        'units','normalized',...
        'value',0,...
        'Position', [0.92 0.97 0.03 0.03],...
        'Callback', @Zoom_callback);
     btn6 = uicontrol('Style', 'pushbutton', 'String', 'Add',...
        'units','normalized',...
        'Position', [0 0.94 0.03 0.03],...
        'Callback', @AddRFs_callback);     
    % Create field for deleting one bouton
    index2 = uicontrol('Style', 'edit', 'string',num2str(0),...
        'units','normalized',...
        'Position', [0 0.91 0.02 0.03]);     
    btn7 = uicontrol('Style', 'pushbutton', 'String', 'Delete^',...
        'units','normalized',...
        'Position', [0 0.88 0.03 0.03],...
        'Callback', @DeleteRFs_callback);
    btn8 = uicontrol('Style', 'radiobutton', 'String', 'Check',...
        'units','normalized',...
        'Position', [0 0.85 0.05 0.03],...
        'Callback', @CheckRegions_callback);
    btn9 = uicontrol('Style', 'pushbutton', 'String', 'DELETE All!',...
        'units','normalized',...
        'Position', [0.04 0.97 0.05 0.03],...
        'Callback', @DeleteALLRFs_callback);
% Create Contrast Sliders
    PrHighSld = uicontrol('Style', 'slider',...
        'Min',0,'Max',0.3,'Value',PrContrast(2),...
        'SliderStep',[0.01,0.05],...
        'units','normalized',...
        'Position', [0.95,0.70 0.05 0.15],...
        'Callback', @Pr_HighContrast_callback);
    PrHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.985,0.68 0.015 0.015],...
        'String','Pr');
    PrHighSld2 = uicontrol('Style', 'slider',...
        'Min',0,'Max',DeltaPrContrast(2),'Value',DeltaPrContrast(2),...
        'SliderStep',[0.1,0.5],...
        'units','normalized',...
        'Position', [0.95,0.52 0.05 0.15],...
        'Callback', @DeltaPr_HighContrast_callback);
    PrHightxt2 = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.985,0.50 0.015 0.015],...
        'String','D');
    PrHighSld3 = uicontrol('Style', 'slider',...
        'Min',0,'Max',1,'Value',SinglePixelPrContrast(2),...
        'SliderStep',[0.05,0.1],...
        'units','normalized',...
        'Position', [0.95,0.34 0.05 0.15],...
        'Callback', @SinglePixelPr_HighContrast_callback);
    PrHightxt3 = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.985,0.32 0.015 0.015],...
        'String','SP');    
    btn10 = uicontrol('Style', 'pushbutton', 'String', 'OVERLAP',...
        'units','normalized',...
        'Position', [0.96 0.03 0.04 0.03],...
        'Callback', @OverlapFixer_callback);
    btn0 = uicontrol('Style', 'pushbutton', 'String', 'EXPORT',...
        'units','normalized',...
        'Position', [0.96 0 0.04 0.03],...
        'Callback', @Export_callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function MapDisplay(BackgroundChoice, OverlayChoices,ZoomRegion_Props)
        LastRFNumber = length(SingleRF_Struct);
        set(RF_Selector_Figure,'name',[StackSaveName, 'Current Map: ',CurrentMap,' #RFs: ',num2str(LastRFNumber)])

        hold on
        if BackgroundChoice==1
            imagesc(OneImage_WithStim_Max_Sharp_Prob_Filt,PrContrast)
            colormap('jet')
        elseif BackgroundChoice==2
            imagesc(OneImage_WithStim_Max_Sharp_Prob,PrContrast)
            colormap('jet')
        elseif BackgroundChoice==3
            imagesc(OneImage_WithStim_Max_Sharp_Prob_Filt_Baseline,PrContrast)
            colormap('jet')
        elseif BackgroundChoice==4
            imagesc(OneImage_WithStim_Max_Sharp_Prob_Baseline,PrContrast)
            colormap('jet')
        elseif BackgroundChoice==5
            imagesc(OneImage_WithStim_Max_Sharp_Prob_Filt_Delta,DeltaPrContrast)
            colormap('jet')
        elseif BackgroundChoice==6
            imagesc(OneImage_AllPixel_ProbMap,SinglePixelPrContrast)
            colormap('jet')
        elseif BackgroundChoice==7
            imagesc(ReferenceImage,ReferenceContrast)
            colormap('gray')
        end
        hcb=colorbar;
        if BackgroundChoice==1
            set(hcb,'YTick',[0 PrContrast(2)]);
        elseif BackgroundChoice==2
            set(hcb,'YTick',[0 PrContrast(2)]);
        elseif BackgroundChoice==3
            set(hcb,'YTick',[0 PrContrast(2)]);
        elseif BackgroundChoice==4
            set(hcb,'YTick',[0 PrContrast(2)]);
        elseif BackgroundChoice==5
            set(hcb,'YTick',[DeltaPrContrast(1),DeltaPrContrast(2)]);
        elseif BackgroundChoice==6
            set(hcb,'YTick',[0 SinglePixelPrContrast(2)]);
        elseif BackgroundChoice==7
            set(hcb,'YTick',[0 ReferenceContrast(2)]);
        end
        [BorderY BorderX] = find(AllBoutonsRegionPerim);
        plot(BorderX, BorderY,['s',ScaleBar.Color], 'MarkerFaceColor', ScaleBar.Color, 'MarkerSize', 2);
        if OverlayChoices(1)
            for i=1:size(BoutonArray,2);
                plot(BoutonArray(i).BorderXCrop, BoutonArray(i).BorderYCrop, 'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
            end
        end
        if OverlayChoices(2)
            for Spots=1:NumberLocalMaxima
                plot(LocalMaximaCoordinates(Spots,1), LocalMaximaCoordinates(Spots,2), 'sk', 'MarkerFaceColor', 'm', 'MarkerSize', 8);
            end 
        end        
        if OverlayChoices(3)
            for Spots=1:NumberLocalMaxima_Baseline
                plot(LocalMaximaCoordinates_Baseline(Spots,1), LocalMaximaCoordinates_Baseline(Spots,2), 'sk', 'MarkerFaceColor', 'y', 'MarkerSize', 5);
            end   
        end              
        if OverlayChoices(4)
            AddRFMask;
        end
        axis equal tight
        set(gca,'YDir','reverse')
        set(gcf, 'color', 'white');
        set(gca,'XTick', []); 
        set(gca,'YTick', []);
        plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
        ylim([ZoomRegion_Props.BoundingBox(2),ZoomRegion_Props.BoundingBox(2)+ZoomRegion_Props.BoundingBox(4)])
        xlim([ZoomRegion_Props.BoundingBox(1),ZoomRegion_Props.BoundingBox(1)+ZoomRegion_Props.BoundingBox(3)])
        hold off
    end
    function Zoom_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            ZoomIn = get(src,'Value');    
        end
        if ZoomIn
            drawnow;
            ZoomRegion = roipoly;
            ZoomRegion_Props = regionprops(double(ZoomRegion), 'BoundingBox');clear ZoomRegion
            for RFNum=1:length(SingleRF_Struct)
                set(Plots(RFNum),'linewidth', 3);
                set(TextLabels(RFNum),'fontsize',20);
            end
        else
            ZoomRegion_Props.BoundingBox=[1,1,size(OneImage_WithStim_Max_Sharp_Prob_Filt,2),size(OneImage_WithStim_Max_Sharp_Prob_Filt,1)];
            for RFNum=1:length(SingleRF_Struct)
                set(Plots(RFNum),'linewidth', 1);
                set(TextLabels(RFNum),'fontsize',10);
            end
        end
        cla
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function Pr_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=PrContrast(1)
            warning('Not possible')
            set(src,'Value',Contrast(2))
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        else
            PrContrast(2)=temp;clear temp
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        end
    end
    function DeltaPr_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=DeltaPrContrast(1)
            warning('Not possible')
            set(src,'Value',DeltaPrContrast(2))
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        else
            DeltaPrContrast(2)=temp;clear temp
            DeltaPrContrast(1)=DeltaPrContrast(2)*-1;
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        end
    end
    function SinglePixelPr_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=SinglePixelPrContrast(1)
            warning('Not possible')
            set(src,'Value',SinglePixelPrContrast(2))
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        else
            SinglePixelPrContrast(2)=temp;clear temp
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        end
    end

    function AddRFMask
        RFBorderTemplate1=ones(size(se,1)+2);
        ZerosImage = zeros(size(OneImage_WithStim_Max_Sharp_Prob_Filt_Baseline));
        for RFNum=1:length(SingleRF_Struct)
            %AllLocations(SingleRF_Struct(RFNum).row,SingleRF_Struct(RFNum).col)=1;
            if ~SingleRF_Struct(RFNum).Adjusted
                BorderMaskImage = ZerosImage;
                BorderMaskImage(SingleRF_Struct(RFNum).row, SingleRF_Struct(RFNum).col) = 1;
                BorderMaskImage = imdilate(BorderMaskImage, RFBorderTemplate1);
                SingleRF_Struct(RFNum).RFBorder = bwperim(BorderMaskImage);
                [SingleRF_Struct(RFNum).RFBorderY SingleRF_Struct(RFNum).RFBorderX] = find(SingleRF_Struct(RFNum).RFBorder);
            %             plot(SingleRF_Struct(RFNum).RFBorderX, SingleRF_Struct(RFNum).RFBorderY,'sw', 'MarkerFaceColor', 'w', 'MarkerSize', 2);
            %             
                BorderMaskImage = ZerosImage;
                BorderMaskImage(SingleRF_Struct(RFNum).row, SingleRF_Struct(RFNum).col) = 1;
                BorderMaskImage = imdilate(BorderMaskImage, se);
                %AllMasks=AllMasks+BorderMaskImage;
                SingleRF_Struct(RFNum).RF_Mask=BorderMaskImage;
                SingleRF_Struct(RFNum).RF_BorderLine.BorderLine=[];
                [B,L] = bwboundaries(BorderMaskImage,'noholes');
                for k = 1:length(B{1})
                    if B{1}(k,1)<SingleRF_Struct(RFNum).row
                        SingleRF_Struct(RFNum).RF_BorderLine.BorderLine(k,1) = B{1}(k,1)-0.5;
                    else
                        SingleRF_Struct(RFNum).RF_BorderLine.BorderLine(k,1) = B{1}(k,1)+0.5;
                    end
                    if B{1}(k,2)<SingleRF_Struct(RFNum).col
                        SingleRF_Struct(RFNum).RF_BorderLine.BorderLine(k,2) = B{1}(k,2)-0.5;
                    else
                        SingleRF_Struct(RFNum).RF_BorderLine.BorderLine(k,2) = B{1}(k,2)+0.5;
                    end
                end
            end
        end
        hold on
        for RFNum=1:length(SingleRF_Struct)
            Plots(RFNum)=plot(SingleRF_Struct(RFNum).RF_BorderLine.BorderLine(:,2), SingleRF_Struct(RFNum).RF_BorderLine.BorderLine(:,1), '-' , 'color', 'w','linewidth', 1);
            TextLabels(RFNum)=text(SingleRF_Struct(RFNum).col,SingleRF_Struct(RFNum).row,num2str(RFNum),'fontsize',10,'color','w','fontweight','bold');
        end
%         RFBorderTemplate=ones(size(se)+2);
%         AllRFBorders=ZerosImage;
%         LastRFNumber=size(SingleRF_Struct);
%         for RFNumber=1:LastRFNumber
%             BorderMaskImage = ZerosImage;
%             BorderMaskImage(SingleRF_Struct(RFNumber).row, SingleRF_Struct(RFNumber).col) = 1;
%             BorderMaskImage = imdilate(BorderMaskImage, RFBorderTemplate);
%             RFBorder = bwperim(BorderMaskImage);
%             AllRFBorders=AllRFBorders+RFBorder;
%         end
%         [RFBorderY RFBorderX] = find(AllRFBorders);
%         plot(RFBorderX, RFBorderY,'sw', 'MarkerFaceColor', 'w', 'MarkerSize', 1);
    end
    function setmap(source,event)
        Map2Display = source.Value;
        TempList = source.String;
        set(RF_Selector_Figure,'name',[StackSaveName, 'Current Map: ',TempList{Map2Display}])
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function AddBoutons_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            AlignmentBoutonBorders = get(src,'Value');    
        end
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function AddMax_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            LocalMax = get(src,'Value');    
        end
        cla
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function AddMaxBase_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            LocalBaseMax = get(src,'Value');    
        end
        cla
        TempXLim=xlim;
        TempYLim=ylim;
        ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function AddRFDisplay_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            RF_Choices = get(src,'Value');    
        end
        cla
        TempXLim=xlim;
        TempYLim=ylim;
        ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function EditRFSize_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            temp=str2num(get(index1,'String'));
            set(index1,'String',num2str(temp));
            se=ones(temp);
            cla
            TempXLim=xlim;
            TempYLim=ylim;
            ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        end
    end
    function AddRFs_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            AddRFs;
        end
    end
    function DeleteRFs_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            RF2Delete=str2num(get(index2,'String'));
            RemoveRF(RF2Delete);
            set(index2,'String',num2str(0));
        end
    end
    function DeleteALLRFs_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
        cla
        TempXLim=xlim;
        TempYLim=ylim;
        SingleRF_Struct=[];
        ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        end
    end

    function CheckRegions_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            temp = get(src,'Value');
            if temp
               LastRFNumber=length(SingleRF_Struct);
               OneImage_RFMap=zeros(size(OneImage_WithStim_Max_Sharp_Prob_Filt));
                for RFNumber=1:LastRFNumber    
                    MaskImage = ZerosImage;
                    MaskImage(SingleRF_Struct(RFNumber).row, SingleRF_Struct(RFNumber).col) = 1;
                    MaskImage = imdilate(MaskImage, se);

                    OneImage_OneRF = MaskImage;
                    OneImage_RFMap = OneImage_RFMap + OneImage_OneRF;
                end
                OneImage_RFMap_RGB=zeros(size(OneImage_RFMap,1),size(OneImage_RFMap,2),3);
                for i=1:size(OneImage_RFMap,1)
                    for j=1:size(OneImage_RFMap,2)
                        if OneImage_RFMap(i,j)>1
                            OneImage_RFMap_RGB(i,j,1)=1;OneImage_RFMap_RGB(i,j,2)=0;OneImage_RFMap_RGB(i,j,3)=0;
                        elseif OneImage_RFMap(i,j)==1
                            OneImage_RFMap_RGB(i,j,1)=1;OneImage_RFMap_RGB(i,j,2)=1;OneImage_RFMap_RGB(i,j,3)=1;
                        end
                    end
                end
                cla
                imshow(OneImage_RFMap_RGB)
                colorbar
                hold on
                [BorderY BorderX] = find(AllBoutonsRegionPerim);
                plot(BorderX, BorderY,['sy'], 'MarkerFaceColor', 'y', 'MarkerSize', 2);
                axis equal tight
                set(gca,'YDir','reverse')
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); 
                set(gca,'YTick', []);
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
                ylim([ZoomRegion_Props.BoundingBox(2),ZoomRegion_Props.BoundingBox(2)+ZoomRegion_Props.BoundingBox(4)])
                xlim([ZoomRegion_Props.BoundingBox(1),ZoomRegion_Props.BoundingBox(1)+ZoomRegion_Props.BoundingBox(3)])
                hold off
                for i=1:length(SingleRF_Struct)
                    text(SingleRF_Struct(i).col,SingleRF_Struct(i).row,num2str(i),'fontsize',10,'color','g')
                end    
            else
                cla
                TempXLim=xlim;
                TempYLim=ylim;
                ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
                MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
            end
        end
    end
    function AddRFs
        TempXLim=xlim;
        TempYLim=ylim;
        ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        hold on;
        Txt1=title('Select Multiple RF Centers (<ENTER> finish, <DELETE> remove last)','color','k','FontSize',15');
        ActiveSelection=1;
        RF_Choices=1;
        [SingleRF_col SingleRF_row P] = impixel;
        LastRFNumber = length(SingleRF_Struct);
        for RFNum=1:length(SingleRF_col)
            SingleRF_Struct(RFNum+LastRFNumber).col = SingleRF_col(RFNum);
            SingleRF_Struct(RFNum+LastRFNumber).row = SingleRF_row(RFNum);
            SingleRF_Struct(RFNum+LastRFNumber).Adjusted=0;
        end
        clear SingleRF_col SingleRF_row
        delete(Txt1)
        hold off;
        cla
        TempXLim=xlim;
        TempYLim=ylim;
        ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
        ActiveSelection=0;
    end
    function RemoveRF(RF2Delete)
        LastRFNumber = length(SingleRF_Struct);
        RFCount=0;
        for i=1:LastRFNumber
            if i==RF2Delete
            else
                RFCount=RFCount+1;
                NewSingleRF_Struct(RFCount)=SingleRF_Struct(i);

            end
        end
        SingleRF_Struct=NewSingleRF_Struct;
        clear NewSingleRF_Struct RF2Delete
        cla
        TempXLim=xlim;
        TempYLim=ylim;
        ZoomRegion_Props.BoundingBox=[TempXLim(1),TempYLim(1),ZoomRegion_Props.BoundingBox(3),ZoomRegion_Props.BoundingBox(4)];
        MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],ZoomRegion_Props)
    end
    function OverlapFixer_callback(src,eventdata,arg1)
        OverlapZoomRegionSize=[30,30];
        
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            %Track checked pairs
             fprintf('Checking all RF Pairs');
             fprintf('\n');

             count=0;
             NumTests=0;
            for z=1:length(SingleRF_Struct)
                for y=1+(z-1):length(SingleRF_Struct)
                    count=count+1;
                    if count==1000
                        fprintf('\n');
                        fprintf('.');
                        count=0;
                    elseif rem(count,10)==0
                        fprintf('.');
                    else
                    end

                    if z~=y
                        OverlapTestMask=zeros(size(OneImage_AllPixel_ProbMap));
                        Temp1=OverlapTestMask;
                        Temp1(SingleRF_Struct(z).row, SingleRF_Struct(z).col) = 1;
                        Temp1 = imdilate(Temp1, se);
                        Temp2=OverlapTestMask;
                        Temp2(SingleRF_Struct(y).row, SingleRF_Struct(y).col) = 1;
                        Temp2 = imdilate(Temp2, se);

                        OverlapTestMask=OverlapTestMask+Temp1;
                        OverlapTestMask=OverlapTestMask+Temp2;

                        if any(OverlapTestMask(:)>1)
                            PreviousTest=0;
                            for x=1:NumTests
                                if (z==PairsTested(x,1)&&y==PairsTested(x,2))||(z==PairsTested(x,2)&&y==PairsTested(x,1))
                                    PreviousTest=1;
                                end
                            end
                            if ~PreviousTest
                                cont2=1;
                                while cont2
                                    NumTests=NumTests+1;
                                    PairsTested(NumTests,:)=[z,y];
                                    OverlapCenter = regionprops(logical(OverlapTestMask), 'centroid');
                                    Beeper(5,0.1)
                                    CheckerFigure=figure;
                                    set(CheckerFigure,'units','normalized','position',[.25 .25 .5 .5],'name',['Overlap Between: ',num2str(z),' and ', num2str(y)])
                                    subtightplot(1,1,1)
                                    OverlapZoomRegion_Props.BoundingBox=[round(OverlapCenter.Centroid(1))-round(OverlapZoomRegionSize(1)/2),round(OverlapCenter.Centroid(2))-round(OverlapZoomRegionSize(2)/2),OverlapZoomRegionSize(1),OverlapZoomRegionSize(2)];
                                    MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],OverlapZoomRegion_Props)
                                    Adjust=[];
                                    fprintf('\n');
                                    disp(['Overlap found Between: ',num2str(z),' and ', num2str(y)])
                                    Adjust=input('<Enter> to skip or <1> to adjust: ');
                                    if isempty(Adjust)
                                        cont2=0;
                                        close(CheckerFigure);
                                    else
                                        figure(CheckerFigure)
                                        AdjustRFNum=InputWithVerification('Enter RF Number to adjust: ',{[z],[y]});
                                        close(CheckerFigure);
                                        cont=1;
                                        while cont
                                            SingleRF_Struct(AdjustRFNum).RFBorder=[];
                                            SingleRF_Struct(AdjustRFNum).Adjusted=1;
                                            BorderMaskImage = ZerosImage;
                                            BorderMaskImage(SingleRF_Struct(AdjustRFNum).row, SingleRF_Struct(AdjustRFNum).col) = 1;
                                            BorderMaskImage = imdilate(BorderMaskImage, se);
                                            BorderMaskImage(OverlapTestMask>1)=0;
                                            BorderMaskImage2=imdilate(BorderMaskImage,ones(3));
                                            Border2 = bwperim(BorderMaskImage2);
                                            Test=BorderMaskImage+BorderMaskImage2+Border2;
                                            Test(Test>1)=0;
                                            Border2(logical(Test))=1;
                                            SingleRF_Struct(AdjustRFNum).RFBorder = Border2;
                                            clear Test Border2 BorderMaskImage2
                                            [SingleRF_Struct(AdjustRFNum).RFBorderY SingleRF_Struct(AdjustRFNum).RFBorderX] = find(SingleRF_Struct(AdjustRFNum).RFBorder);
                                            %             plot(SingleRF_Struct(AdjustRFNum).RFBorderX, SingleRF_Struct(AdjustRFNum).RFBorderY,'sw', 'MarkerFaceColor', 'w', 'MarkerSize', 2);
                                            %             
                                            BorderMaskImage = ZerosImage;
                                            BorderMaskImage(SingleRF_Struct(AdjustRFNum).row, SingleRF_Struct(AdjustRFNum).col) = 1;
                                            BorderMaskImage = imdilate(BorderMaskImage, se);
                                            BorderMaskImage(OverlapTestMask>1)=0;
                                            SingleRF_Struct(AdjustRFNum).RF_Mask=BorderMaskImage;
                                            SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine=[];
                                            [B,L] = bwboundaries(BorderMaskImage,'noholes');
                                            for k = 1:length(B{1})
                                                if B{1}(k,1)<SingleRF_Struct(AdjustRFNum).row
                                                    SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,1) = B{1}(k,1)-0.5;
                                                else
                                                    SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,1) = B{1}(k,1)+0.5;
                                                end
                                                if B{1}(k,2)<SingleRF_Struct(AdjustRFNum).col
                                                    SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,2) = B{1}(k,2)-0.5;
                                                else
                                                    SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,2) = B{1}(k,2)+0.5;
                                                end
                                            end


                                            CheckerFigure=figure;
                                            set(CheckerFigure,'units','normalized','position',[.25 .25 .5 .5],'name',['Overlap Between: ',num2str(z),' and ', num2str(y)])
                                            subtightplot(1,1,1)
                                            OverlapZoomRegion_Props.BoundingBox=[round(OverlapCenter.Centroid(1))-round(OverlapZoomRegionSize(1)/2),round(OverlapCenter.Centroid(2))-round(OverlapZoomRegionSize(2)/2),OverlapZoomRegionSize(1),OverlapZoomRegionSize(2)];
                                            MapDisplay(Map2Display, [AlignmentBoutonBorders,LocalMax,LocalBaseMax, RF_Choices],OverlapZoomRegion_Props)
                                            disp(['RF #',num2str(AdjustRFNum),' Mask Reduced from: ',num2str(sum(se(:))),' to ',num2str(sum(SingleRF_Struct(AdjustRFNum).RF_Mask(:))),' Pixels'])

                                            cont2=input('<ENTER> to accept, <1> to reject: ');
                                            if isempty(cont2)
                                                cont=0;
                                            end
                                            if cont2
                                                SingleRF_Struct(AdjustRFNum).Adjusted=0;
                                                RFBorderTemplate1=ones(size(se,1)+2);
                                                SingleRF_Struct(AdjustRFNum).Adjusted=1;
                                                BorderMaskImage = ZerosImage;
                                                BorderMaskImage(SingleRF_Struct(AdjustRFNum).row, SingleRF_Struct(AdjustRFNum).col) = 1;
                                                BorderMaskImage = imdilate(BorderMaskImage, RFBorderTemplate1);
                                                SingleRF_Struct(AdjustRFNum).RFBorder = bwperim(BorderMaskImage);
                                                [SingleRF_Struct(AdjustRFNum).RFBorderY SingleRF_Struct(AdjustRFNum).RFBorderX] = find(SingleRF_Struct(AdjustRFNum).RFBorder);
                                                %             plot(SingleRF_Struct(AdjustRFNum).RFBorderX, SingleRF_Struct(AdjustRFNum).RFBorderY,'sw', 'MarkerFaceColor', 'w', 'MarkerSize', 2);
                                                %             
                                                BorderMaskImage = ZerosImage;
                                                BorderMaskImage(SingleRF_Struct(AdjustRFNum).row, SingleRF_Struct(AdjustRFNum).col) = 1;
                                                BorderMaskImage = imdilate(BorderMaskImage, se);
                                                SingleRF_Struct(AdjustRFNum).RF_Mask=BorderMaskImage;
                                                SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine=[];
                                                [B,L] = bwboundaries(BorderMaskImage,'noholes');
                                                for k = 1:length(B{1})
                                                    if B{1}(k,1)<SingleRF_Struct(AdjustRFNum).row
                                                        SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,1) = B{1}(k,1)-0.5;
                                                    else
                                                        SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,1) = B{1}(k,1)+0.5;
                                                    end
                                                    if B{1}(k,2)<SingleRF_Struct(AdjustRFNum).col
                                                        SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,2) = B{1}(k,2)-0.5;
                                                    else
                                                        SingleRF_Struct(AdjustRFNum).RF_BorderLine.BorderLine(k,2) = B{1}(k,2)+0.5;
                                                    end
                                                end
                                            end
                                            close(CheckerFigure);

                                        end
                                    end

                                end
                                clear OverlapTestMask OverlapZoomRegion_Props OverlapCenter 
                            
                            end
                        end
                    end
                end
            end
                 
            fprintf('\n')  
            disp('Finished Testing All Pairs');
            figure(RF_Selector_Figure)
            clear PairsTested NumTests
        end
        
    end
    function Export_callback(src,eventdata,arg1)
        if ActiveSelection
            warning('Finish Active Selection!')
        else
            global SINGLERF_STRUCT1 
            global SE1
            %global FINISHED_SELECTING_RFS
            FINISHED_SELECTING_RFS=1;
            SINGLERF_STRUCT1=SingleRF_Struct;
            SE1=se;
            close(RF_Selector_Figure)
        end
    end
end