function [Image_Contrasted,cMap_Contrasted,Image_Contrasted_Color,cMap_Contrasted_Color,ContrastHigh,ContrastLow,cMap]=...
    ImageContraster(RawImage,Label,ContrastHigh,ContrastLow,ChannelColor,BitDepth,TurboMode)

%jheapcl
% RawImage=BrpImage_Crop;
% Label=[];
% ContrastHigh=[];
% ContrastLow=[];
% BitDepth=16;
% ChannelColor='m';
% TurboMode=0;

PauseInterval=60;


ScreenSize=get(0,'ScreenSize');
NewContrast=0;
if isempty(ChannelColor)
    ChannelColor='w';
end
if isempty(ContrastHigh)
    ContrastHigh=max(RawImage(:));
    NewContrast=1;
end
if isempty(ContrastLow)
    ContrastLow=min(RawImage(:));
    NewContrast=1;
end
if isempty(BitDepth)
    BitDepth=16;
end
if isempty(Label)
    Label='Image';
end
if isempty(TurboMode)
    TurboMode='Image';
end
if ischar(ChannelColor)
    cMap=makeColorMap(ColorDefinitions('k'),ColorDefinitions(ChannelColor),2^BitDepth);
else
    cMap=makeColorMap(ColorDefinitions('k'),ChannelColor,2^BitDepth);
end

GoodContrast=1;
while GoodContrast==1   
    if NewContrast==1
        TempImage=RawImage;
        SavePixel(1)=TempImage(1,1);SavePixel(2)=TempImage(1,2);
        TempImage(1,1)=0;TempImage(1,2)=2^BitDepth-1;
        TempHandle=figure(); imshow(TempImage, [0,2^BitDepth-1]); title(Label);TempFigPosition=get(gcf,'OuterPosition');
        %set(gcf, 'Position', [0,ScreenSize(4),TempFigPosition(3),TempFigPosition(4)]);clear TempFigPosition;
        TempContrastHandle = imcontrast(TempHandle);
        TempImage(1,1)=SavePixel(1);TempImage(1,2)=SavePixel(2);
        BringAllToFront();figure(TempHandle);
        disp(['Note: will pause for ',num2str(PauseInterval),'s for selection of conrast range....'])
        disp('Wait for prompt to refresh to continue...')
        pause(30);
        cont=InputWithVerification('Adjust image contrast and press enter to continue (NOTE: do not click "Adjust Data")',{[]},0);
        close(TempContrastHandle);
        TempCData = get(gca, 'CLim');
        ContrastLow=round(TempCData(1));
        ContrastHigh=round(TempCData(2));
        clear TempCData
        close(TempHandle);
        clear TempImage
        clear SavePixel
    end
    
    %Make New Colormaps
    if ischar(ChannelColor)
        cMap_Color=makeColorMap(ColorDefinitions('k'),ColorDefinitions(ChannelColor),ContrastHigh-ContrastLow);
    else
        cMap_Color=makeColorMap(ColorDefinitions('k'),ChannelColor,ContrastHigh-ContrastLow);
    end
    FullcMap_Gray=0:1:2^BitDepth-1;
    cMap_Contrasted=zeros(size(cMap,1),1);
    cMap_Contrasted_Color=zeros(size(cMap));
    ContrastDiff=1/(ContrastHigh-ContrastLow);
    CurrentValue=ContrastDiff;
    Counter=1;
    for i=1:size(cMap,1)
        if i<=ContrastLow
            cMap_Contrasted_Color(i,:)=cMap(1,:);
            cMap_Contrasted(i)=0;
        elseif i>=ContrastHigh
            cMap_Contrasted_Color(i,:)=cMap(size(cMap,1),:);
            cMap_Contrasted(i)=2^16-1;
        else
            cMap_Contrasted_Color(i,:)=cMap_Color(Counter,:);
            CurrentValue=CurrentValue+ContrastDiff;
            cMap_Contrasted(i)=CurrentValue*(2^BitDepth-2);
            Counter=Counter+1;
        end
    end
    
    %remap values to new colormap
    cMap_Contrasted=uint16(cMap_Contrasted);
    Image_Contrasted=zeros(size(RawImage));
    for i=1:size(RawImage,1)
        for j=1:size(RawImage,2)
            if RawImage(i,j)~=0
                Image_Contrasted(i,j)=cMap_Contrasted(RawImage(i,j));
                Image_Contrasted_Color(i,j,:)=cMap_Contrasted_Color(RawImage(i,j),:);
            end
        end
    end    

    ImageHistXvalues=0:100:2^BitDepth-1;
    ImageHistogram=histc(RawImage(:),[ImageHistXvalues]);
    ImageHistogram_Norm=ImageHistogram/max(ImageHistogram);
    
    ContrastedImageHistogram=histc(Image_Contrasted(:),[ImageHistXvalues]);
    ContrastedImageHistogram_Norm=ContrastedImageHistogram/max(ContrastedImageHistogram);
    
    
    TempHandle=figure();
    freezeColors
    subtightplot(2,3,1,[],[],[]);
    imshow(RawImage, []); hold on;title('Raw'); hold off;freezeColors
    subtightplot(2,3,4,[],[],[]);
    imshow(RawImage, []); hold on; colormap(cMap); title('Raw Color');hold off;freezeColors
    subtightplot(2,3,2,[],[],[]);
    imshow(Image_Contrasted, [0 2^BitDepth]); hold on; title('Contrasted');hold off;freezeColors
    subtightplot(2,3,5,[],[],[]);
    imshow(Image_Contrasted_Color, []); hold on; title('Contrasted Color');hold off;freezeColors
    subtightplot(2,3,3,[],[],[])
    [haxes,hline1,hline2] = plotyy(ImageHistXvalues,ImageHistogram_Norm,[1:length(cMap_Contrasted)],cMap_Contrasted);hold on, xlabel('Old Grayscale'), ylabel('New Grayscale'),plot([ContrastLow,ContrastLow],[0,2^BitDepth],'color','r'), plot([ContrastHigh,ContrastHigh],[0,2^BitDepth],'color','r');hold off;
    subtightplot(2,3,6,[],[],[])
    plot(ImageHistXvalues,ContrastedImageHistogram_Norm,'color','k','LineWidth',1);xlim([0,2^BitDepth]);
%     TempFigPosition=get(TempHandle,'OuterPosition');set(gcf, 'Position', [0,ScreenSize(4),TempFigPosition(3)*3,TempFigPosition(4)*2]);clear TempFigPosition;
%     set(TempHandle,'units','normalized','location',[0.05,0.05,0.5,0.5])
    if TurboMode
        GoodContrast=[];
    else
        GoodContrast=InputWithVerification('Enter 1 to repeat the contrasting of this channel: ',{1,[]});
    end
    close(TempHandle);
    if GoodContrast==1
        NewContrast=1;
    end
end
disp(strcat(Label,' Contrast Levels Low: ',num2str(ContrastLow),' and High: ',num2str(ContrastHigh)))
%jheapcl

end