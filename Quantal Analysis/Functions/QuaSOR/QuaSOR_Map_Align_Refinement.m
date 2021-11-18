cont=input('Do you really want to start from the beginning? ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in Tetanus Recording List Structure First!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set Recording Num Here:
RecordingNum=30;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except Recording RecordingNum ParentDir dc OS myPool
close all
warning on all
%%%%%%%%%%%%%%%%%%%
%use Spont_Suffix=[]; to skip mini addition
Spont_Suffix=[];
Spont_Color='b';
Spont_Sig=6;
Spont_Cont=6;
%%%%%%%%%%%%%%%%%%%
LowFreq_Suffix='_02Hz';
LowFreq_Color='g';
LowFreq_Sig=6;
LowFreq_Cont=6;
%%%%%%%%%%%%%%%%%%%
HighFreq_Suffix=Recording(RecordingNum).StackSaveNameSuffix;
HighFreq_Color='r';
HighFreq_Sig=6;
HighFreq_Cont=6;
%%%%%%%%%%%%%%%%%%%
ControlPoint_MarkerColor='w';
ControlPoint_OverlayMarkerSize=10;
ControlPoint_PairMarkerSize=8;
ExportBorderColor='w';
QuaSOR_BorderLine_Width=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[OS,dc,~,~,~,~]=BatchStartup;
disp('======================================')
cd(Recording(RecordingNum).dir)
StackSaveName=Recording(RecordingNum).StackSaveName;
disp(['Refinement Analysis for Recording # ',num2str(RecordingNum),': ',StackSaveName,': ',LowFreq_Suffix,' versus ',HighFreq_Suffix])

fprintf(['Loading Basic Data ',[StackSaveName,LowFreq_Suffix,'_QuaSOR_Data.mat'],'...'])
load([StackSaveName,LowFreq_Suffix,'_QuaSOR_Data.mat'],'QuaSOR_ImageHeight','QuaSOR_ImageWidth','QuaSOR_UpScaleFactor',...
    'ContrastEnhancements','QuaSOR_Bouton_Mask','QuaSOR_Bouton_Mask_BorderLine','QuaSOR_Color_Scalar','ScaleBar_Upscale')
fprintf('FINISHED!\n')

if ~isempty(Spont_Suffix)
    fprintf(['Loading Spont Data ',[StackSaveName,Spont_Suffix,'_QuaSOR_Data.mat'],'...'])
    load([StackSaveName,Spont_Suffix,'_QuaSOR_Data.mat'],'QuaSOR_HighRes_Maps','QuaSOR_All_Location_Coords')
    Spont_QuaSOR_HighRes_Maps=QuaSOR_HighRes_Maps; clear QuaSOR_HighRes_Maps
    Spont_QuaSOR_All_Location_Coords=QuaSOR_All_Location_Coords; clear QuaSOR_All_Location_Coords
    fprintf('FINISHED!\n')
end

fprintf(['Loading Low Freq Data ',[StackSaveName,LowFreq_Suffix,'_QuaSOR_Data.mat'],'...'])
load([StackSaveName,LowFreq_Suffix,'_QuaSOR_Data.mat'],'QuaSOR_HighRes_Maps','QuaSOR_All_Location_Coords')
LowFreq_QuaSOR_HighRes_Maps=QuaSOR_HighRes_Maps; clear QuaSOR_HighRes_Maps
LowFreq_QuaSOR_All_Location_Coords=QuaSOR_All_Location_Coords; clear QuaSOR_All_Location_Coords
fprintf('FINISHED!\n')

fprintf(['Loading High Freq Data ',[StackSaveName,HighFreq_Suffix,'_QuaSOR_Data.mat'],'...'])
load([StackSaveName,HighFreq_Suffix,'_QuaSOR_Data.mat'],'QuaSOR_HighRes_Maps','QuaSOR_All_Location_Coords')
HighFreq_QuaSOR_HighRes_Maps=QuaSOR_HighRes_Maps; clear QuaSOR_HighRes_Maps
HighFreq_QuaSOR_All_Location_Coords=QuaSOR_All_Location_Coords; clear QuaSOR_All_Location_Coords
fprintf('FINISHED!\n')

load([StackSaveName,HighFreq_Suffix,'_QuaSOR_Data.mat'],'Registered_QuaSOR_Coord')
if exist('Registered_QuaSOR_Coord')
    if Registered_QuaSOR_Coord
        warning('Using Registered Coordinates for High Freq Data!')
        warning('Using Registered Coordinates for High Freq Data!')
        warning('Using Registered Coordinates for High Freq Data!')
        warning('Using Registered Coordinates for High Freq Data!')
    end
end

RefinementSaveDir=[LowFreq_Suffix,HighFreq_Suffix,' Refinement Figs'];
if ~exist(RefinementSaveDir)
    mkdir(RefinementSaveDir)
end
QuaSOR_Refinement_cpstruct=[];
LowFreq_Fixed_Points=[];
HighFreq_Moving_Points=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Re-Coloring Maps...')

for zzz=1:1
QuaSOR_Bouton_Mask_Perim=bwperim(QuaSOR_Bouton_Mask);
QuaSOR_Bouton_Mask_Perim=imdilate(QuaSOR_Bouton_Mask_Perim,ones(3));


if ~isempty(Spont_Suffix)

    Spont_TestImage=Spont_QuaSOR_HighRes_Maps(Spont_Sig).QuaSOR_Image;
    Spont_TestImage_ContrastEnhancement=ContrastEnhancements(Spont_Cont);
    Spont_TestImage_MaxValue=...
        (ceil(max(Spont_TestImage(:))*QuaSOR_Color_Scalar));
    Spont_TestImage_MaxValue_Cont=...
        ceil(Spont_TestImage_MaxValue*...
        Spont_TestImage_ContrastEnhancement);
    Spont_TestImage_Colormap=...
        makeColorMap([0 0 0],ColorDefinitions(Spont_Color),...
        Spont_TestImage_MaxValue_Cont);
    TempImage=Spont_TestImage;
    TempImage(TempImage>Spont_TestImage_MaxValue_Cont)=...
        Spont_TestImage_MaxValue_Cont;
    Spont_TestImage_Color=...
        ind2rgb(round(TempImage*QuaSOR_Color_Scalar),...
        Spont_TestImage_Colormap);
    Spont_TestImage_Color_Perim=ColorMasking(Spont_TestImage_Color,QuaSOR_Bouton_Mask_Perim,[1,1,1]);
    %Spont_TestImage_Color=Spont_QuaSOR_HighRes_Maps(Spont_Sig).ContrastedOutputImages(Spont_Cont).QuaSOR_Image_Color;
    %Spont_TestImage_Color=ColorMasking(Spont_TestImage_Color,~QuaSOR_Bouton_Mask,[0,0,0]);

end

LowFreq_TestImage=LowFreq_QuaSOR_HighRes_Maps(LowFreq_Sig).QuaSOR_Image;
LowFreq_TestImage_ContrastEnhancement=ContrastEnhancements(LowFreq_Cont);
LowFreq_TestImage_MaxValue=...
    (ceil(max(LowFreq_TestImage(:))*QuaSOR_Color_Scalar));
LowFreq_TestImage_MaxValue_Cont=...
    ceil(LowFreq_TestImage_MaxValue*...
    LowFreq_TestImage_ContrastEnhancement);
LowFreq_TestImage_Colormap=...
    makeColorMap([0 0 0],ColorDefinitions(LowFreq_Color),...
    LowFreq_TestImage_MaxValue_Cont);
TempImage=LowFreq_TestImage;
TempImage(TempImage>LowFreq_TestImage_MaxValue_Cont)=...
    LowFreq_TestImage_MaxValue_Cont;
LowFreq_TestImage_Color=...
    ind2rgb(round(TempImage*QuaSOR_Color_Scalar),...
    LowFreq_TestImage_Colormap);
LowFreq_TestImage_Color_Perim=ColorMasking(LowFreq_TestImage_Color,QuaSOR_Bouton_Mask_Perim,[1,1,1]);
%LowFreq_TestImage_Color=LowFreq_QuaSOR_HighRes_Maps(LowFreq_Sig).ContrastedOutputImages(LowFreq_Cont).QuaSOR_Image_Color;
%LowFreq_TestImage_Color=ColorMasking(LowFreq_TestImage_Color,~QuaSOR_Bouton_Mask,[0,0,0]);


HighFreq_TestImage=HighFreq_QuaSOR_HighRes_Maps(HighFreq_Sig).QuaSOR_Image;
HighFreq_TestImage_ContrastEnhancement=ContrastEnhancements(HighFreq_Cont);
HighFreq_TestImage_MaxValue=...
    (ceil(max(HighFreq_TestImage(:))*QuaSOR_Color_Scalar));
HighFreq_TestImage_MaxValue_Cont=...
    ceil(HighFreq_TestImage_MaxValue*...
    HighFreq_TestImage_ContrastEnhancement);
HighFreq_TestImage_Colormap=...
    makeColorMap([0 0 0],ColorDefinitions(HighFreq_Color),...
    HighFreq_TestImage_MaxValue_Cont);
TempImage=HighFreq_TestImage;
TempImage(TempImage>HighFreq_TestImage_MaxValue_Cont)=...
    HighFreq_TestImage_MaxValue_Cont;
HighFreq_TestImage_Color=...
    ind2rgb(round(TempImage*QuaSOR_Color_Scalar),...
    HighFreq_TestImage_Colormap);
HighFreq_TestImage_Color_Perim=ColorMasking(HighFreq_TestImage_Color,QuaSOR_Bouton_Mask_Perim,[1,1,1]);
%HighFreq_TestImage_Color=HighFreq_QuaSOR_HighRes_Maps(HighFreq_Sig).ContrastedOutputImages(HighFreq_Cont).QuaSOR_Image_Color;
%HighFreq_TestImage_Color=ColorMasking(HighFreq_TestImage_Color,~QuaSOR_Bouton_Mask,[0,0,0]);

Merge_TestImage_Color=LowFreq_TestImage_Color+HighFreq_TestImage_Color;
if ~isempty(Spont_Suffix)
    Merge_TestImage_Color=Merge_TestImage_Color+Spont_TestImage_Color;
end
Merge_TestImage_Color_Perim=ColorMasking(Merge_TestImage_Color,QuaSOR_Bouton_Mask_Perim,[1,1,1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(Spont_Suffix)

    figure, subtightplot(1,3,1),imshow(Spont_TestImage_Color),title('Spont')
            hold on
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
            set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])
            %%%%%%%%%%%%%%
            subtightplot(1,3,2),imshow(LowFreq_TestImage_Color),title('Low Freq')
            hold on
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
            set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])
            %%%%%%%%%%%%%%
            subtightplot(1,3,3),imshow(HighFreq_TestImage_Color),title('High Freq')
            hold on
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
            set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])

else

    figure, subtightplot(1,2,1),imshow(LowFreq_TestImage_Color),title('Low Freq')
            hold on
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
            set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])
            %%%%%%%%%%%%%%
            subtightplot(1,2,2),imshow(HighFreq_TestImage_Color),title('High Freq')
            hold on
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
            set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])
end
figure, subtightplot(1,1,1),imshow(Merge_TestImage_Color),title('Merge')
        hold on
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
        end
        set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

fprintf('FINISHED Prep!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%Control Point Selection
%helpdlg('Make sure to Export cpstruct before closing selection tool','REMINDER!')
if ~isempty(QuaSOR_Refinement_cpstruct)
    cpselect(HighFreq_TestImage_Color_Perim,LowFreq_TestImage_Color_Perim,QuaSOR_Refinement_cpstruct);
else
    cpselect(HighFreq_TestImage_Color_Perim,LowFreq_TestImage_Color_Perim);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Check Control Points
close all
QuaSOR_Refinement_cpstruct=cpstruct;
LowFreq_Fixed_Points=fixedPoints;
HighFreq_Moving_Points=movingPoints;

figure, subtightplot(1,2,1),imshow(LowFreq_TestImage_Color),title('Low Freq Reference Points')
        hold on
        for i=1:size(LowFreq_Fixed_Points,1)
            plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
                '.','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
            plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
                'o','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
        end
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
        end
        subtightplot(1,2,2),imshow(HighFreq_TestImage_Color),title('High Freq Moving Points')
        hold on
        for i=1:size(HighFreq_Moving_Points,1)
            plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
                '.','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
            plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
                'o','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
        end
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
        end
        set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])

figure, imshow(zeros(size(LowFreq_TestImage_Color))),title('Pre-Registration Control Points')
        hold on
        for i=1:size(LowFreq_Fixed_Points,1)
            plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points(i,1)],...
                [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points(i,2)],...
                '-','color',ControlPoint_MarkerColor,'linewidth',0.5);
            plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
                '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
            plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
                '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
        end
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate Transform Parameters
close all

%cp2tform Defaults
QuaSOR_cp2tform_Method='projective';
%QuaSOR_cp2tform_Method='affine';
%QuaSOR_cp2tform_N_Points=12; %12 is default Not using right now

%Calculate tform
clear HighFreq_Moving_Points_Reg QuaSOR_Refinement_MovingPoints_Used QuaSOR_Refinement_FixedPoints_Used
clear QuaSOR_Refinement_MovingPoints_Bad QuaSOR_Refinement_FixedPoints_Bad
[QuaSOR_Refinement_tform,QuaSOR_Refinement_MovingPoints_Used,QuaSOR_Refinement_FixedPoints_Used,...
    QuaSOR_Refinement_MovingPoints_Bad,QuaSOR_Refinement_FixedPoints_Bad] = ...
    cp2tform(QuaSOR_Refinement_cpstruct,QuaSOR_cp2tform_Method); 

%Apply tform to Moving points
[HighFreq_Moving_Points_Reg(:,1),HighFreq_Moving_Points_Reg(:,2)]=...
    tformfwd(QuaSOR_Refinement_tform, HighFreq_Moving_Points(:,1),HighFreq_Moving_Points(:,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check results
figure, imshow(zeros(size(LowFreq_TestImage_Color))),title('Pre-Registration Control Points')
        hold on
        for i=1:size(LowFreq_Fixed_Points,1)
            plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points(i,1)],...
                [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points(i,2)],...
                '-','color',ControlPoint_MarkerColor,'linewidth',0.5);
            plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
                '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
            plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
                '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
        end
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
        end

figure, imshow(zeros(size(LowFreq_TestImage_Color))), title('Post-Registration Control Points')
        hold on
        for i=1:size(LowFreq_Fixed_Points,1)
            plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points_Reg(i,1)],...
                [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points_Reg(i,2)],...
                '-','color',ControlPoint_MarkerColor,'linewidth',0.5);
            plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
                '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
            plot(HighFreq_Moving_Points_Reg(i,1),HighFreq_Moving_Points_Reg(i,2),...
                '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
        end
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
        end

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
if ~exist('ParentDir')        
    OS,dc,ParentDir,ParentDir1,ParentDir2,ParentDir3,TemplateDir,ScratchDir]=BatchStartup;
    currentFolder=cd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply tform to all QuaSOR Points
%HighFreq_QuaSOR_All_Location_Coords ---> HighFreq_QuaSOR_All_Location_Coords_Reg
clear HighFreq_QuaSOR_All_Location_Coords_Reg
[HighFreq_QuaSOR_All_Location_Coords_Reg(:,2),HighFreq_QuaSOR_All_Location_Coords_Reg(:,1)]=...
    tformfwd(QuaSOR_Refinement_tform, HighFreq_QuaSOR_All_Location_Coords(:,2)*QuaSOR_UpScaleFactor,HighFreq_QuaSOR_All_Location_Coords(:,1)*QuaSOR_UpScaleFactor);


HighFreq_QuaSOR_All_Location_Coords_Reg=HighFreq_QuaSOR_All_Location_Coords_Reg/QuaSOR_UpScaleFactor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check and make figs
fprintf('Checking and Making Figures for Records...')
close all
RefinementSaveDir=[LowFreq_Suffix,HighFreq_Suffix,' Refinement Figs'];
if ~exist(RefinementSaveDir)
    mkdir(RefinementSaveDir)
end
for zzz=1:1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement LowFreq HighFreq Map Control Points'];
figure
subtightplot(1,2,1)
imshow(LowFreq_TestImage_Color),title('Low Freq Reference Points')
hold on
for i=1:size(LowFreq_Fixed_Points,1)
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        '.','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        'o','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
end
subtightplot(1,2,2)
imshow(HighFreq_TestImage_Color),title('High Freq Moving Points')
hold on
for i=1:size(HighFreq_Moving_Points,1)
    plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
        '.','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
    plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
        'o','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
end
set(gcf,'units','normalized','position',[0.1,0.1,0.7,0.7])
set(gcf, 'color', 'white');
axis off 
box off
saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement LowFreq HighFreq PreReg Control Points'];
figure
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
for i=1:size(LowFreq_Fixed_Points,1)
    plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points(i,1)],...
        [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points(i,2)],...
        '-','color','k','linewidth',0.5);
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
    plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
        '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
title(FigName,'Interpreter','none','fontsize',8)
set(gcf,'units','normalized','position',[0.25,0.05,0.5,0.85])
set(gca,'XTick', []); set(gca,'YTick', []);
set(gcf, 'color', [0.75,0.75,0.75]);
legend({'Low Freq','High Freq'},'Location','Best')
xlim([0,QuaSOR_ImageWidth])
ylim([0,QuaSOR_ImageHeight])
axis off 
box off
saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement LowFreq HighFreq PostReg Control Points'];
figure
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
for i=1:size(LowFreq_Fixed_Points,1)
    plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points_Reg(i,1)],...
        [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points_Reg(i,2)],...
        '-','color','k','linewidth',0.5);
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
    plot(HighFreq_Moving_Points_Reg(i,1),HighFreq_Moving_Points_Reg(i,2),...
        '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
title(FigName,'Interpreter','none','fontsize',8)
set(gcf,'units','normalized','position',[0.25,0.05,0.5,0.85])
set(gca,'XTick', []); set(gca,'YTick', []);
set(gcf, 'color', [0.75,0.75,0.75]);
legend({'Low Freq','High Freq Reg'},'Location','Best')
xlim([0,QuaSOR_ImageWidth])
ylim([0,QuaSOR_ImageHeight])
axis off 
box off
saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement LowFreq HighFreq PreReg All_Coords'];
figure
subtightplot(1,1,1,[0,0])
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
plot(LowFreq_QuaSOR_All_Location_Coords(:,2),...
    LowFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color',LowFreq_Color,'MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords(:,2),...
    HighFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color',HighFreq_Color,'MarkerSize',6)
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2)/QuaSOR_UpScaleFactor,...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1)/QuaSOR_UpScaleFactor,...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
title(FigName,'Interpreter','none','fontsize',8)
set(gcf,'units','normalized','position',[0.25,0.05,0.5,0.85])
set(gca,'XTick', []); set(gca,'YTick', []);
set(gcf, 'color', [0.75,0.75,0.75]);
legend({'Low Freq','High Freq'},'Location','Best')
xlim([0,QuaSOR_ImageWidth/QuaSOR_UpScaleFactor])
ylim([0,QuaSOR_ImageHeight/QuaSOR_UpScaleFactor])
axis off 
box off
saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement HighFreq Pre_PostReg All_Coords'];
figure
hold on
plot(-1,-1,'.','color','k','MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords(:,2),...
    HighFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color','k','MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords_Reg(:,2),...
    HighFreq_QuaSOR_All_Location_Coords_Reg(:,1),...
    '.','color',HighFreq_Color,'MarkerSize',6)
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2)/QuaSOR_UpScaleFactor,...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1)/QuaSOR_UpScaleFactor,...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
title(FigName,'Interpreter','none','fontsize',8)
set(gcf,'units','normalized','position',[0.25,0.05,0.5,0.85])
set(gca,'XTick', []); set(gca,'YTick', []);
set(gcf, 'color', [0.75,0.75,0.75]);
legend({'High Freq Pre-Reg','High Freq Post-Reg'},'Location','Best')
xlim([0,QuaSOR_ImageWidth/QuaSOR_UpScaleFactor])
ylim([0,QuaSOR_ImageHeight/QuaSOR_UpScaleFactor])
axis off 
box off
saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement LowFreq vs HighFreq PostReg All_Coords'];
figure
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
plot(LowFreq_QuaSOR_All_Location_Coords(:,2),...
    LowFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color',LowFreq_Color,'MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords_Reg(:,2),...
    HighFreq_QuaSOR_All_Location_Coords_Reg(:,1),...
    '.','color',HighFreq_Color,'MarkerSize',6)
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2)/QuaSOR_UpScaleFactor,...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1)/QuaSOR_UpScaleFactor,...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
title(FigName,'Interpreter','none','fontsize',8)
set(gcf,'units','normalized','position',[0.25,0.05,0.5,0.85])
set(gca,'XTick', []); set(gca,'YTick', []);
set(gcf, 'color', [0.75,0.75,0.75]);
legend({'Low Freq','High Freq Reg'},'Location','Best')
xlim([0,QuaSOR_ImageWidth/QuaSOR_UpScaleFactor])
ylim([0,QuaSOR_ImageHeight/QuaSOR_UpScaleFactor])
axis off 
box off
saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FigName=[StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement Summary'];
figure
SummaryGaps=[0.02,0];
set(gcf,'units','normalized','position',[0.05,0.05,0.9,0.85])
set(gcf, 'color', [0.75,0.75,0.75]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subtightplot(2,4,1,SummaryGaps)
imshow(LowFreq_TestImage_Color)
title('Low Freq Reference Points','fontsize',10)
hold on
for i=1:size(LowFreq_Fixed_Points,1)
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        '.','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        'o','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subtightplot(2,4,5,SummaryGaps)
imshow(HighFreq_TestImage_Color)
title('High Freq Moving Points','fontsize',10)
hold on
for i=1:size(HighFreq_Moving_Points,1)
    plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
        '.','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
    plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
        'o','color',ControlPoint_MarkerColor,'markersize',ControlPoint_OverlayMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subtightplot(2,4,2,SummaryGaps)
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
for i=1:size(LowFreq_Fixed_Points,1)
    plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points(i,1)],...
        [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points(i,2)],...
        '-','color','k','linewidth',0.5);
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
    plot(HighFreq_Moving_Points(i,1),HighFreq_Moving_Points(i,2),...
        '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
set(gca,'XTick', []); set(gca,'YTick', []);
title('Reverence vs Pre-Reg Control Points','fontsize',10)
legend({'Low Freq','High Freq'},'Location','Best')
xlim([0,QuaSOR_ImageWidth])
ylim([0,QuaSOR_ImageHeight])
axis off 
box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subtightplot(2,4,6,SummaryGaps)
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
for i=1:size(LowFreq_Fixed_Points,1)
    plot([LowFreq_Fixed_Points(i,1),HighFreq_Moving_Points_Reg(i,1)],...
        [LowFreq_Fixed_Points(i,2),HighFreq_Moving_Points_Reg(i,2)],...
        '-','color','k','linewidth',0.5);
    plot(LowFreq_Fixed_Points(i,1),LowFreq_Fixed_Points(i,2),...
        '.','color',LowFreq_Color,'markersize',ControlPoint_PairMarkerSize);
    plot(HighFreq_Moving_Points_Reg(i,1),HighFreq_Moving_Points_Reg(i,2),...
        '.','color',HighFreq_Color,'markersize',ControlPoint_PairMarkerSize);
end
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
set(gca,'XTick', []); set(gca,'YTick', []);
title('Reference vs Post-Reg Control Points','fontsize',10)
legend({'Low Freq','High Freq Reg'},'Location','Best')
xlim([0,QuaSOR_ImageWidth])
ylim([0,QuaSOR_ImageHeight])
axis off 
box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subtightplot(2,4,3,SummaryGaps)
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
plot(LowFreq_QuaSOR_All_Location_Coords(:,2),...
    LowFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color',LowFreq_Color,'MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords(:,2),...
    HighFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color',HighFreq_Color,'MarkerSize',6)
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2)/QuaSOR_UpScaleFactor,...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1)/QuaSOR_UpScaleFactor,...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
set(gca,'XTick', []); set(gca,'YTick', []);
title('Reference vs Pre-Reg All Coords','fontsize',10)
legend({'Low Freq','High Freq'},'Location','Best')
xlim([0,QuaSOR_ImageWidth/QuaSOR_UpScaleFactor])
ylim([0,QuaSOR_ImageHeight/QuaSOR_UpScaleFactor])
axis off 
box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subtightplot(2,4,4,SummaryGaps)
hold on
plot(-1,-1,'.','color','k','MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords(:,2),...
    HighFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color','k','MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords_Reg(:,2),...
    HighFreq_QuaSOR_All_Location_Coords_Reg(:,1),...
    '.','color',HighFreq_Color,'MarkerSize',6)
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2)/QuaSOR_UpScaleFactor,...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1)/QuaSOR_UpScaleFactor,...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
set(gca,'XTick', []); set(gca,'YTick', []);
title('Pre vs Post-Reg All Coords','fontsize',10)
legend({'High Freq Pre-Reg','High Freq Post-Reg'},'Location','Best')
xlim([0,QuaSOR_ImageWidth/QuaSOR_UpScaleFactor])
ylim([0,QuaSOR_ImageHeight/QuaSOR_UpScaleFactor])
axis off 
box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subtightplot(2,4,7,SummaryGaps)
hold on
plot(-1,-1,'.','color',LowFreq_Color,'MarkerSize',6)
plot(-1,-1,'.','color',HighFreq_Color,'MarkerSize',6)
plot(LowFreq_QuaSOR_All_Location_Coords(:,2),...
    LowFreq_QuaSOR_All_Location_Coords(:,1),...
    '.','color',LowFreq_Color,'MarkerSize',6)
plot(HighFreq_QuaSOR_All_Location_Coords_Reg(:,2),...
    HighFreq_QuaSOR_All_Location_Coords_Reg(:,1),...
    '.','color',HighFreq_Color,'MarkerSize',6)
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2)/QuaSOR_UpScaleFactor,...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1)/QuaSOR_UpScaleFactor,...
        '-','color','k','linewidth',QuaSOR_BorderLine_Width)
end
set(gca,'ydir','reverse'), axis equal tight
set(gca,'XTick', []); set(gca,'YTick', []);
title('Reference vs Post-Reg All Coords','fontsize',10)
legend({'Low Freq','High Freq Reg'},'Location','Best')
xlim([0,QuaSOR_ImageWidth/QuaSOR_UpScaleFactor])
ylim([0,QuaSOR_ImageHeight/QuaSOR_UpScaleFactor])
axis off 
box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subtightplot(2,4,8,SummaryGaps)
imshow(Merge_TestImage_Color)
title('PRE-REGISTRATAION MERGE')
hold on
for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
    plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
        QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
        '-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
end
title('PRE-REGISTRATAION MERGE','fontsize',10)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveas(gcf, [RefinementSaveDir,dc, FigName, '.fig']);
export_fig( [RefinementSaveDir,dc, FigName, '.eps'], '-eps','-pdf','-png','-nocrop','-q101','-native');        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

fprintf('FINISHED!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Saving Data...')
close all

clear HighFreq_QuaSOR_HighRes_Maps LowFreq_QuaSOR_HighRes_Maps Spont_QuaSOR_HighRes_Maps

save([StackSaveName,LowFreq_Suffix,HighFreq_Suffix,'_QuaSOR_Refinement_Data.mat'],...
    '-regexp','^(?!(RecordingNum|LastRecording|ID_Suffix|Suffix_Ib|Suffix_Is|LoopCount|File2Check|AnalysisLabelFunction|BufferSize|Port|TimeOut|NumLoops|ServerIP|BadConnection|ConnectionAttempts|OverwriteData|AllRecordingStatuses|ServerIP|currentFolder|TemplateDir|ScratchDir|ParentDir1|ParentDir|Recording|dc|OS|myPool|SaveDir)$).')
fprintf('FINISHED!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(['Adding Refined Coordinates to: ',StackSaveName,HighFreq_Suffix,'_QuaSOR_Data.mat...'])
% close all
% save([StackSaveName,HighFreq_Suffix,'_QuaSOR_Data.mat'],'HighFreq_QuaSOR_All_Location_Coords_Reg','-append')
% fprintf('FINISHED!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(['Adding Refined Coordinates to: ',StackSaveName,HighFreq_Suffix,'_SOQA_Data2.mat...'])
close all
All_Location_Coords_Reg=HighFreq_QuaSOR_All_Location_Coords_Reg;
save([StackSaveName,HighFreq_Suffix,'_SOQA_Data2.mat'],'All_Location_Coords_Reg','-append')
fprintf('FINISHED!\n')

open([RefinementSaveDir,dc,StackSaveName,LowFreq_Suffix,HighFreq_Suffix,' Refinement Summary','.fig']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    %Export new lists for fixing 
                    File2Find='_SOQA_Data2.mat';
                    Suffix2Find='_Ib'; %Use '_' for Ib and Is or '_Ib' for only Ib
                    clear InfoArray 
                    InfoArray=[];
                    Count=0;
                    disp('Exporting Refined List...')
                    ParentDirText='ParentDir,';
                    BufferTextLength=22-length(ParentDirText);
                    BufferText=[];
                    for i=1:BufferTextLength
                        BufferText=[BufferText,' '];
                    end
                    warning off
                    CurrentLine=1;
                    for RecordingNum=1:size(Recording,2)
                        if exist([Recording(RecordingNum).dir,dc,...
                                Recording(RecordingNum).StackSaveName,...
                                Recording(RecordingNum).StackSaveNameSuffix,File2Find])&&...
                            any(strfind(Recording(RecordingNum).StackSaveName,Suffix2Find))
                            load([Recording(RecordingNum).dir,dc,...
                                Recording(RecordingNum).StackSaveName,...
                                Recording(RecordingNum).StackSaveNameSuffix,File2Find],'All_Location_Coords_Reg')
                            if exist('All_Location_Coords_Reg')
                                
                                Count=Count+1;
                                disp(['Found All_Location_Coords_Reg in: ',Recording(RecordingNum).StackSaveName,Recording(RecordingNum).StackSaveNameSuffix])
                                TempDir=Recording(RecordingNum).dir;
                                TempDir=TempDir(length(ParentDir)+1:length(TempDir));
                                InfoArray{CurrentLine+1,1}=['Recording(',num2str(Count),').dir=[',ParentDirText,BufferText,'''',TempDir,'''];'];
                                InfoArray{CurrentLine+2,1}=['Recording(',num2str(Count),').StackSaveName=             ''',Recording(RecordingNum).StackSaveName,''';'];
                                InfoArray{CurrentLine+3,1}=['Recording(',num2str(Count),').ReferenceStackSaveName=    ''',Recording(RecordingNum).ReferenceStackSaveName,''';'];
                                InfoArray{CurrentLine+4,1}=['Recording(',num2str(Count),').StackSaveNameSuffix=       ''',Recording(RecordingNum).StackSaveNameSuffix,''';'];
                                InfoArray{CurrentLine+5,1}=['Recording(',num2str(Count),').StackFileName=             ''',Recording(RecordingNum).StackFileName,''';'];
                                InfoArray{CurrentLine+6,1}=['Recording(',num2str(Count),').FirstImageFileName=        ''',Recording(RecordingNum).FirstImageFileName,''';'];
                                InfoArray{CurrentLine+7,1}=[];
                                CurrentLine=CurrentLine+7;
                            end
                            clear All_Location_Coords_Reg
                        end
                    end
                    disp([num2str(Count),' Refined Files'])
                    warning on
                    cd(ParentDir)
                    FileRecord_Dir=['ID Files'];
                    mkdir(FileRecord_Dir)
                    CurrentDateTime=clock;
                    Year=num2str(CurrentDateTime(1)-2000);Month=num2str(CurrentDateTime(2));Day=num2str(CurrentDateTime(3));Hour=num2str(CurrentDateTime(4));Minute=num2str(CurrentDateTime(5));Second=num2str(CurrentDateTime(6));
                    if length(Month)<2;Month=['0',Month];end;if length(Day)<2;Day=['0',Day];end
                    dlmcell([FileRecord_Dir,dc,(Year),(Month),(Day),' Post Refinement High Freq Batch Prep Temp.txt'], InfoArray);
                    open([FileRecord_Dir,dc,(Year),(Month),(Day),' Post Refinement High Freq Batch Prep Temp.txt'])



