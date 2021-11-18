function [ContrastLow,ContrastHigh]=ManualContrastAdjust(InputImage,ColorCode,ColorScalar)

        Image=InputImage*ColorScalar;
        
        TempContrastLow=0;
        TempContrastHigh=max(Image(:));
        cMap=UniversalColorMap(ColorCode,TempContrastLow,TempContrastHigh);

        NewContrast=1;
        GoodContrast=1;
        while GoodContrast==1   
            if NewContrast==1
                TempImage=Image;
                SavePixel(1)=TempImage(1,1);
                SavePixel(2)=TempImage(1,2);
                TempImage(1,1)=TempContrastLow;
                TempImage(1,2)=TempContrastHigh;
                TempHandle=figure();
                warning off;
                imshow(TempImage, [],'border','tight');
                colormap(cMap);
                warning on;
                set(TempHandle,'units','normalized','position',[0.6,0.05,0.5 0.85])
                TempContrastHandle = imcontrast(TempHandle);
                TempImage(1,1)=SavePixel(1);
                TempImage(1,2)=SavePixel(2);
                %BringAllToFront();
                figure(TempHandle);
                set(TempHandle,'units','normalized','position',[0,0.05,0.5 0.85])
                cont=InputWithVerification('Adjust image contrast and press enter to continue (NOTE: do not click "Adjust Data")',{[]},0);
                try
                    close(TempContrastHandle);
                catch
                    warning('Missing figure!')
                end
                TempCData = get(gca, 'CLim');
                ContrastLow=round(TempCData(1));
                ContrastHigh=round(TempCData(2));
                if ContrastLow<0
                    warning on
                    warning('Low contrast is less than zero fixing!!!')
                    warning('Low contrast is less than zero fixing!!!')
                    warning('Low contrast is less than zero fixing!!!')
                    warning('Low contrast is less than zero fixing!!!')
                    ContrastLow=0;
                end
                clear TempCData
                try
                    close(TempHandle);
                catch
                    warning('Missing figure!')
                end
                clear TempImage
                clear SavePixel
            end
            
            
            [~,Image_Color,~]=...
                Adjust_Contrast_and_Color(Image,TempContrastLow,TempContrastHigh,ColorCode,1);

            [Image_Contrasted,Image_Contrasted_Color,cMap_Contrasted]=...
                Adjust_Contrast_and_Color(Image,ContrastLow,ContrastHigh,ColorCode,1);
            
            Height=size(Image,1);
            Width=size(Image,2);
            BeforeAfterImage=zeros(Height,2*Width,3);
            BeforeAfterImage(:,1:Width,:)=Image_Color;
            BeforeAfterImage(:,Width+1:Width*2,:)=Image_Contrasted_Color;
            TempHandle=figure(); 
            warning off;
            imshow(double(BeforeAfterImage), [],'border','tight');
            colormap(cMap); warning on; hold on;
            text(Width*0.05, Height*0.05, strcat('Auto Contrast'),'color','y','FontSize',12');
            text(Width*0.05+Width, Height*0.05, strcat('Low: ',num2str(ContrastLow),' High: ',num2str(ContrastHigh)),'color','y','FontSize',12');
            set(TempHandle,'units','normalized','position',[0,0.05,0.5 0.85])
            hold off;
            GoodContrast=InputWithVerification('Enter 1 to repeat the contrasting of this channel: ',{1,[]},0);
            close all
            if GoodContrast==1
                NewContrast=1;
            end
        end
        disp(strcat('Contrast Levels Low: ',num2str(ContrastLow),' and High: ',num2str(ContrastHigh)))


end


