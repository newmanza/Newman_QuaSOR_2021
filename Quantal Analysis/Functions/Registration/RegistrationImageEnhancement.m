function [Image_Padded,Image_Padded_Masked_Filtered_Enhanced]=...
        RegistrationImageEnhancement(Image,AllBoutonsRegion_Padded,AllBoutonsRegion_Mask_Padded,BorderLine,Crop_Props,DemonReg,RegEnhancement,Title,FigureSaveDir,FigDisplay,SaveOption)
          
    %Determine Value to use for filling Pad area
    if DemonReg.PadValue_Method==1
        Image_Pad_Value=median(Image(:));
    elseif DemonReg.PadValue_Method==2
        Image_Pad_Value=mean(Image(:));
    elseif DemonReg.PadValue_Method==3
        Image_Pad_Value=min(Image(:));
    else
        Image_Pad_Value=0;
    end
    %Pad Border
    Image_Padded = padarray(Image,[DemonReg.Padding DemonReg.Padding],Image_Pad_Value);
    %Smooth pad interface border
    BorderAdjust1=zeros(size(AllBoutonsRegion_Mask_Padded));
    BorderAdjust1(1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,1)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,2)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2)=1;
    BorderAdjust2=zeros(size(AllBoutonsRegion_Mask_Padded));
    BorderAdjust2(1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,1)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,2)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2)=1;
    BorderAdjust=BorderAdjust1+BorderAdjust2;
    BorderAdjust(BorderAdjust==0)=1;
    BorderAdjust(BorderAdjust==2)=0;
    Image_Padded= roifilt2(fspecial('disk', 10),double(Image_Padded),logical(BorderAdjust));
    %Enhance once to set up ROIs
    if RegEnhancement.Filter_Enhanced
        Temp_Image_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(Image_Padded), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_px,  RegEnhancement.EnhanceFilterSigma_px)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    else
        Temp_Image_Enhanced=Zach_enhanceContrastForDemon(uint16(Image_Padded),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
    end
    Image_Enhanced_Mask=Temp_Image_Enhanced;
    Image_Enhanced_Mask(Image_Enhanced_Mask<RegEnhancement.MaskSplitPercentage*max(Temp_Image_Enhanced(:)))=0;
    Image_Enhanced_Mask(Image_Enhanced_Mask>=RegEnhancement.MaskSplitPercentage*max(Temp_Image_Enhanced(:)))=1;
    Image_Enhanced_Mask=imdilate(Image_Enhanced_Mask,ones(RegEnhancement.MaskSplitDilate));
    %Pick Mask that overlaps with AllBoutonsRegion
    [~,NumRegions] = bwlabel(AllBoutonsRegion_Padded);
    AllBoutounsRegion_Padded_ROIs=bwconncomp(AllBoutonsRegion_Padded);
    AllBoutounsRegion_Padded_ROIs_RegionProps = regionprops(AllBoutounsRegion_Padded_ROIs,'PixelList');
    Image_Enhanced_Mask_MatchedROI=zeros(size(Image_Enhanced_Mask));
    for z=1:NumRegions
        cont=1;
        k=1;
        while cont
             TempROI = bwselect(Image_Enhanced_Mask, AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2));
             if any(TempROI(:)>0)
                 Image_Enhanced_Mask_MatchedROI=Image_Enhanced_Mask_MatchedROI+TempROI;
                 cont=0;
             elseif k>=size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
                 cont=0;
             else
                 k=k+1;
             end
        end
    end
    %Set up Bias with the new ROIs
    Image_Enhanced_Mask_MatchedROI_Biased=ones(size(Image_Enhanced_Mask_MatchedROI));
    for j=1:RegEnhancement.BiasRatios
        Temp=imdilate(Image_Enhanced_Mask_MatchedROI,ones(j*RegEnhancement.BiasRatioDiv));
        Image_Enhanced_Mask_MatchedROI_Biased=Image_Enhanced_Mask_MatchedROI_Biased+Temp;
    end
    Image_Enhanced_Mask_MatchedROI_Biased=Image_Enhanced_Mask_MatchedROI_Biased/max(Image_Enhanced_Mask_MatchedROI_Biased(:));
    Image_Enhanced_Mask_MatchedROI_Biased=Image_Enhanced_Mask_MatchedROI_Biased*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
    %use the dilated region for filtereing anything outside the regions
    LowerCutoff=min(Image_Enhanced_Mask_MatchedROI_Biased(:));
    Image_Enhanced_Mask_MatchedROI_Biased=imfilter(Image_Enhanced_Mask_MatchedROI_Biased,fspecial('gaussian', RegEnhancement.EnhanceFilterSize_px,  RegEnhancement.EnhanceFilterSigma_px));
    Image_Enhanced_Mask_MatchedROI_Biased_Mask=Image_Enhanced_Mask_MatchedROI_Biased;
    Image_Enhanced_Mask_MatchedROI_Biased_Mask(Image_Enhanced_Mask_MatchedROI_Biased_Mask<=(LowerCutoff+0.01))=0;
    Image_Enhanced_Mask_MatchedROI_Biased_Mask=logical(Image_Enhanced_Mask_MatchedROI_Biased_Mask);
    %Apply bias
    if RegEnhancement.Bias_Region
        Image_Padded_Biased=double(Image_Padded).*double(Image_Enhanced_Mask_MatchedROI_Biased);
    else
        Image_Padded_Biased=Image_Padded;
    end
    %filter all pixels outside of the region
    Image_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(Image_Padded_Biased),~logical(Image_Enhanced_Mask_MatchedROI_Biased_Mask));
    Image_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(Image_Padded_Masked_Filtered), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_px,  RegEnhancement.EnhanceFilterSigma_px)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);

    if FigDisplay
        FigName=[Title,' Image Enhancements'];
        figure('name',FigName)
        subtightplot(2,2,1,[0.05,0.05])
        imagesc(Image)
        axis equal tight
        colorbar
        colormap('jet')
        title('Orig Ref Image')
        title([Title,' Orig'],'Interpreter','none'),
        hold on
        plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)],'-','color','w','LineWidth',0.5);plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);
        plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);plot([Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5); 
        for j=1:length(BorderLine)
            plot(BorderLine{j}.BorderLine(:,2),...
                BorderLine{j}.BorderLine(:,1),...
                ':','color','m','linewidth',1)
        end
        subtightplot(2,2,2,[0.05,0.05]),imagesc(Image_Padded)
        axis equal tight
        colorbar
        colormap('jet')
        title(['Padded EdgeFixed'],'Interpreter','none'),
        hold on
        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'-','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);
        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5); 
        for j=1:length(BorderLine)
            plot(DemonReg.Padding+BorderLine{j}.BorderLine(:,2),...
                DemonReg.Padding+BorderLine{j}.BorderLine(:,1),...
                ':','color','m','linewidth',1)
        end
        subtightplot(2,2,3,[0.05,0.05])
        imagesc(Image_Padded_Masked_Filtered)
        axis equal tight
        colorbar
        colormap('jet')
        title(['Masked Filtered'],'Interpreter','none'),
        hold on
        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'-','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);
        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5); 
        for j=1:length(BorderLine)
            plot(DemonReg.Padding+BorderLine{j}.BorderLine(:,2),...
                DemonReg.Padding+BorderLine{j}.BorderLine(:,1),...
                ':','color','m','linewidth',1)
        end
        subtightplot(2,2,4,[0.05,0.05])
        imagesc(Image_Padded_Masked_Filtered_Enhanced)
        axis equal tight
        colorbar
        colormap('jet')
        title(['Final Enhanced'],'Interpreter','none'),
        hold on
        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)],'-','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);
        plot([DemonReg.Padding+Crop_Props.BoundingBox(1),DemonReg.Padding+Crop_Props.BoundingBox(1)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5);plot([DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),DemonReg.Padding+Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[DemonReg.Padding+Crop_Props.BoundingBox(2),DemonReg.Padding+Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','w','LineWidth',0.5); 
        for j=1:length(BorderLine)
            plot(DemonReg.Padding+BorderLine{j}.BorderLine(:,2),...
                DemonReg.Padding+BorderLine{j}.BorderLine(:,1),...
                ':','color','m','linewidth',1)
        end
        set(gcf,'units','pixels','position',[0,50,800,800])
        drawnow
        if SaveOption
            fprintf(['Saving: ',FigName,'...'])
            Full_Export_Fig(gcf,gca,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
            fprintf('Finished!\n')
        end
    end
                
end