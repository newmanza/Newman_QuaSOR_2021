function [EditedPeaks,Edits]=MaxArrayEdit(DeltaGFP, MaxImageArray, Edits, NewEdits)  
%NewEdits=1; start from scratch
%NewEdits=0; only use previous edits and no involvement
%NewEdits=2; apply previous edits but allow further edits

if NewEdits==1
    for i=1:size(DeltaGFP,3)
        Edits(i).EditRegions=[];
        Edits(i).editCount=0;
    end
end

ScreenSize=get(0,'ScreenSize');
EditedPeaks=MaxImageArray;


    

if NewEdits==0
    for i=1:size(DeltaGFP,3)
        if Edits(i).editCount>0;
            for j=1:Edits(i).editCount
                EditedPeaks(:,:,i)=EditedPeaks(:,:,i).*Edits(i).EditRegions(j).DeleteRegion;
            end
        end
    end
end

if NewEdits==2
    for i=1:size(DeltaGFP,3)
        if Edits(i).editCount>0;
            for j=1:Edits(i).editCount
                EditedPeaks(:,:,i)=EditedPeaks(:,:,i).*Edits(i).EditRegions(j).DeleteRegion;
            end
        end
    end
    NewEdits=1;
end

StartIndex=1;
StartIndex=input('What index would you like to jump to? ');
if isempty(StartIndex)
    StartIndex=1;
end

StopAllEdits=0;
if NewEdits==1   
    for i=StartIndex:size(DeltaGFP,3)
        if StopAllEdits==0;
            Temp1=figure(); imshow(DeltaGFP(:,:,i),[], 'InitialMagnification', 300); title(['DeltaGFP Index#:',num2str(i)]); hold on; colormap jet; colorbar;  set(gcf, 'color', 'white'); TempFigPosition1=get(gcf,'OuterPosition');set(gcf, 'Position', [0,ScreenSize(4)-(1)*TempFigPosition1(4),TempFigPosition1(3),TempFigPosition1(4)]);hold off;TempFigPosition1=get(gcf,'OuterPosition');
            Temp2=figure(); imshow(EditedPeaks(:,:,i),[], 'InitialMagnification', 300); title(['Max Index#:',num2str(i)]); hold on; colorbar;  set(gcf, 'color', 'white'); TempFigPosition2=get(gcf,'OuterPosition');set(gcf, 'Position', [0,ScreenSize(4)-(2)*TempFigPosition1(4),TempFigPosition2(3),TempFigPosition2(4)]);hold off;

            exitEdit=1;
            editCount=0;
            while exitEdit==1
                BringAllToFront();
                EditCommand=0;
                EditCommand=input(['Index#',num2str(i),' (1) Delete Region (2) Undo Delete (3) Stop Editing or () Skip Index: ']);
                if EditCommand==1
                    TempSave=EditedPeaks(:,:,i);
                    editCount=editCount+1;
                    GoodEditRegion=0;
                    while GoodEditRegion==0
                        Edits(i).EditRegions(editCount).DeleteRegion = roipoly; % draw a region on the current figure
                        if isempty(Edits(i).EditRegions(editCount).DeleteRegion)
                            GoodEditRegion=0;
                            'Bad region try again'
                        else
                            Edits(i).EditRegions(editCount).DeleteRegion = imcomplement(Edits(i).EditRegions(editCount).DeleteRegion);
                            EditedPeaks(:,:,i)=EditedPeaks(:,:,i).*Edits(i).EditRegions(editCount).DeleteRegion;
                            close(Temp2);
                            Temp2=figure(); imshow(EditedPeaks(:,:,i),[], 'InitialMagnification', 300); title(['Max Index#:',num2str(i)]); hold on; colorbar;  set(gcf, 'color', 'white'); TempFigPosition2=get(gcf,'OuterPosition');set(gcf, 'Position', [0,ScreenSize(4)-(2)*TempFigPosition1(4),TempFigPosition2(3),TempFigPosition2(4)]);hold off;
                            GoodEditRegion=1;
                        end
                    end            
                elseif EditCommand==2
                    EditedPeaks(:,:,i)=TempSave;
                    Edits(i).EditRegions(editCount)=[];
                    editCount=editCount-1;
                    close(Temp2);
                    Temp2=figure(); imshow(EditedPeaks(:,:,i),[], 'InitialMagnification', 300); title(['Max Index#:',num2str(i)]); hold on; colorbar;  set(gcf, 'color', 'white'); TempFigPosition2=get(gcf,'OuterPosition');set(gcf, 'Position', [0,ScreenSize(4)-(2)*TempFigPosition1(4),TempFigPosition2(3),TempFigPosition2(4)]);hold off;
                elseif EditCommand==3
                    StopAllEdits=1;
                    exitEdit=0;
                    %break;break;break;break;
                else
                    exitEdit=0;
                end
            end
            Edits(i).editCount=editCount;
            if editCount==0
                Edits(i).EditRegions=[];
            end
            hold off
            close(Temp1);close(Temp2);
        end
    end
end
        


  
end