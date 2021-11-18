close all
[OS,dc,~,~,~,~,~,ScratchDir]=BatchStartup;

ScaleBarLength_um=20
PixelSize_um=0.21
ColorScalar=1000;%we can get better color precision and definition when using double precision input data by upscaling the color data
YScalar=100;
ExportFormat='.tif';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate a double precision array
TestImage=rand(1000,3000)*10;
figure
imagesc(TestImage)
axis equal tight
colorbar

%Add an ROI
ROI.Crop_Props.BoundingBox=[20,40,500,500];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%first export with a jet colormap

Jet_ColorScheme='jet'
Jet_Contrast_Low=0;
Jet_Contrast_High=15;

%use this to colorize
[   TestImage_Contrasted,...
    TestImage_Contrasted_Color,...
    TestImage_Contrasted_cMap]=...
    Adjust_Contrast_and_Color(TestImage,...
        Jet_Contrast_Low,Jet_Contrast_High,...
        Jet_ColorScheme,ColorScalar);

%Always write out the full resolution image file to a .tif                
imwrite(double(TestImage_Contrasted_Color),...
    [ScratchDir,'Test Image Jet Bitmap Data', ExportFormat])

%Export the overlay pieces separately, then you can align and reconstruct
%in illustrator
ExportName=['Test Image Jet Vector Overlay'];
figure
imshow(TestImage_Contrasted_Color,[],'border','tight')
axis off
box off
hold on
PlotBox2(ROI.Crop_Props.BoundingBox,'-','m',0.5,['ROI'],8,'m');
set(gca,'ydir','reverse')
axis equal tight
Auto_ScaleBar(size(TestImage_Contrasted_Color,1),...
    size(TestImage_Contrasted_Color,2),...
    PixelSize_um,...
    ScaleBarLength_um,'BL',1,'w',0.02,0.05)

%There are many options in this to export different formats, very very
%useful
Full_Export_Fig(gcf,gca,[ScratchDir,dc,ExportName],0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%second export with a single color colormap and higher contrast

SingleColor_ColorScheme='m'
SingleColor_Contrast_Low=0;
SingleColor_Contrast_High=8;

%use this to colorize
[   TestImage_Contrasted,...
    TestImage_Contrasted_Color,...
    TestImage_Contrasted_cMap]=...
    Adjust_Contrast_and_Color(TestImage,...
        SingleColor_Contrast_Low,SingleColor_Contrast_High,...
        SingleColor_ColorScheme,ColorScalar);

%Always write out the full resolution image file to a .tif                
imwrite(double(TestImage_Contrasted_Color),...
    [ScratchDir,'Test Image Color Bitmap Data', ExportFormat])

%Export the overlay pieces separately, then you can align and reconstruct
%in illustrator
ExportName=['Test Image Color Vector Overlay'];
figure
imshow(TestImage_Contrasted_Color,[],'border','tight')
axis off
box off
hold on
PlotBox2(ROI.Crop_Props.BoundingBox,'-','g',1,['ROI'],8,'g');
set(gca,'ydir','reverse')
axis equal tight
Auto_ScaleBar(size(TestImage_Contrasted_Color,1),...
    size(TestImage_Contrasted_Color,2),...
    PixelSize_um,...
    ScaleBarLength_um,'BL',1,'w',0.02,0.05)

%There are many options in this to export different formats, very very
%useful
Full_Export_Fig(gcf,gca,[ScratchDir,dc,ExportName],0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%try cropping too
TestImage_Contrasted_Color_Crop=imcrop(TestImage_Contrasted_Color,ROI.Crop_Props.BoundingBox);
imwrite(double(TestImage_Contrasted_Color_Crop),...
    [ScratchDir,'Test Image Color Bitmap Data Cropped', ExportFormat])

ExportName=['Test Image Color Vector Overlay Cropped'];
figure
imshow(TestImage_Contrasted_Color_Crop,[],'border','tight')
axis off
box off
hold on
set(gca,'ydir','reverse')
axis equal tight
Auto_ScaleBar(size(TestImage_Contrasted_Color_Crop,1),...
    size(TestImage_Contrasted_Color_Crop,2),...
    PixelSize_um,...
    ScaleBarLength_um,'BL',1,'w',0.05,0.05)

%There are many options in this to export different formats, very very
%useful
Full_Export_Fig(gcf,gca,[ScratchDir,dc,ExportName],0)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Then we can make a custom proper color bar separately for both export sets

Channel_Labels{1}='Jet Color Data';
Channel_Colors{1}=Jet_ColorScheme;
Contrast_Data(1).MinVal=Jet_Contrast_Low;
Contrast_Data(1).MaxVal=Jet_Contrast_High;

Channel_Labels{2}='Single Color Data';
Channel_Colors{2}=SingleColor_ColorScheme;
Contrast_Data(2).MinVal=SingleColor_Contrast_Low;
Contrast_Data(2).MaxVal=SingleColor_Contrast_High;


Multi_ColorBars(Channel_Labels,Channel_Colors,ColorScalar,YScalar,Contrast_Data,ScratchDir,dc,['Test Image Color Bars'])


     