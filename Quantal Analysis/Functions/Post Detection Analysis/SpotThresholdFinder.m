%this function will return a threshold value for a minimum number of spots
%at a single pixel that have been filtered the same way that the maps have
%to determine a lower limit for RF selection

function Threshold=SpotThresholdFinder(NumEvents,NumRecordings,FilterSize,FilterSigma)
    
    SpotTestImage=zeros(20,20);
    SpotTestImage(11,11)=NumEvents/NumRecordings;
    SpotTestImage_Filt = imfilter(SpotTestImage, fspecial('gaussian', FilterSize, FilterSigma));
    Threshold=max(max(SpotTestImage_Filt));



% 
% 
% 
% 
% %limits of spot placement
% SpotTestImage=zeros(20,20,5);
% for i=1:size(SpotTestImage,3)
%     SpotTestImage(11,11,i)=i/size(ImageArray_Max,3);
%     SpotTestImage_Filt(:,:,i) = imfilter(SpotTestImage(:,:,i), fspecial('gaussian', ProbFilterSize, ProbFilterSigma));
% end
% 
% TempFig=figure('name','Spot Tests for single events');
% hold all
% set(gcf, 'color', 'white');
% for i=1:size(SpotTestImage,3)
%     subplot(3,size(SpotTestImage,3),i);
%     imagesc(SpotTestImage_Filt(:,:,i));axis equal tight;colorbar;title(['Max:',num2str(max(max(SpotTestImage_Filt(:,:,i))))]);set(gca,'XTick', []); set(gca,'YTick', []);text(2,2,[num2str(i),' P',num2str(i/size(ImageArray_Max,3))]);
% end
% for i=1:size(SpotTestImage,3)
%     subplot(3,size(SpotTestImage,3),i+size(SpotTestImage,3));
%     imagesc(SpotTestImage_Filt(:,:,i),[0,max(max(OneImage_WithStim_Max_Sharp_Prob_Filt))]);axis equal tight;colorbar;title([num2str(i),'Events Contrast'],'interpreter','none');set(gca,'XTick', []); set(gca,'YTick', []);text(2,2,[num2str(i),' P',num2str(i/size(ImageArray_Max,3))]);
% end
% for i=1:size(SpotTestImage,3)
%     subplot(3,size(SpotTestImage,3),i+size(SpotTestImage,3)*2);
%     imagesc(SpotTestImage_Filt(:,:,i),[0,max(max(OneImage_WithStim_Max_Sharp_Prob_Filt_Baseline))]);axis equal tight;colorbar;title([num2str(i),'Events Base Contrast'],'interpreter','none');set(gca,'XTick', []); set(gca,'YTick', []);text(2,2,[num2str(i),' P',num2str(i/size(ImageArray_Max,3))]);
% end
% 
% hold off
% set(gcf, 'Position', [30,30,1000,1000]);
% set(gcf,'units','centimeters');
% set(gcf,'papersize',[10,10]);
% set(gcf,'paperposition',[0,0,10,10]);


end

