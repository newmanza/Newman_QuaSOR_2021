function [FitDetails]=Multi_3D_Fitting(TempXData,TempYData,TempZData,XLabel,YLabel,ZLabel,Title,FigSaveDir,ScratchDir,...
    Azimuth,Elevation,Save3DFitFigs,FigurePosition_3D,AxesPosition_3D,AxesStandardFontSizes,SilentColor,UpperLimitBuffer,AdjustRatio,MovieFits,SubPlotSize,FigurePosition_AllFits,SurfaceFitAlpha)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
    
    clear FitDetails

    if ~exist(FigSaveDir)
        mkdir(FigSaveDir)
    end

    FitDetails.XRange=[min(TempXData(:)):max(TempXData(:))/1000:max(TempXData(:))];
    FitDetails.YRange=[min(TempYData(:)):max(TempYData(:))/1000:max(TempYData(:))];
    [FitDetails.SurfaceXData,FitDetails.SurfaceYData]=meshgrid(FitDetails.XRange,FitDetails.YRange);

    XMax=max(TempXData(:));
    YMax=max(TempYData(:));
    ZMax=max(TempZData(:));
    XMin=min(TempXData(:));
    YMin=min(TempYData(:));
    ZMin=min(TempZData(:));
    
    if any(isnan(TempXData))
        warning on
        warning('X value NaN, setting to zero!')
    end
    if any(isnan(TempYData))
        warning on
        warning('Y value NaN, setting to zero!')
    end
    if any(isnan(TempZData))
        warning on
        warning('Z value NaN, setting to zero!')
    end    
    
    TempXData_NoNaN=TempXData;
    TempXData_NoNaN(isnan(TempXData_NoNaN))=0;
    TempYData_NoNaN=TempYData;
    TempYData_NoNaN(isnan(TempYData_NoNaN))=0;
    TempZData_NoNaN=TempZData;
    TempZData_NoNaN(isnan(TempZData_NoNaN))=0;
    
    
    if min(TempXData)<=0
        warning('X data has a zero, fixing...')
        TempXData_NaN=TempXData;
        TempXData_NaN(TempXData_NaN==0)=NaN;
        MinXNotZero=min(TempXData_NaN);
        MinXNotZeroLog=log10(MinXNotZero);
        MinXZeroLog=floor(MinXNotZeroLog);
        MinXZero=10^MinXZeroLog;
        MinXZeroAdjust=MinXZero*AdjustRatio;
        TempXData_ZeroFix=TempXData_NaN;
        TempXData_ZeroFix(isnan(TempXData_ZeroFix))=MinXZeroAdjust;
    else
        TempXData_NaN=TempXData;
        TempXData_ZeroFix=TempXData;
    end
    if min(TempYData)<=0
        warning('Y data has a zero, fixing...')
        TempYData_NaN=TempYData;
        TempYData_NaN(TempYData_NaN==0)=NaN;
        MinYNotZero=min(TempYData_NaN);
        MinYNotZeroLog=log10(MinYNotZero);
        MinYZeroLog=floor(MinYNotZeroLog);
        MinYZero=10^MinYZeroLog;
        MinYZeroAdjust=MinYZero*AdjustRatio;
        TempYData_ZeroFix=TempYData_NaN;
        TempYData_ZeroFix(isnan(TempYData_ZeroFix))=MinYZeroAdjust;
    else
        TempYData_NaN=TempYData;
        TempYData_ZeroFix=TempYData;
    end
    if min(TempZData)<=0
        warning('Z data has a zero, fixing...')
        TempZData_NaN=TempZData;
        TempZData_NaN(TempZData_NaN==0)=NaN;
        MinZNotZero=min(TempZData_NaN);
        MinZNotZeroLog=log10(MinZNotZero);
        MinZZeroLog=floor(MinZNotZeroLog);
        MinZZero=10^MinZZeroLog;
        MinZZeroAdjust=MinZZero*AdjustRatio;
        TempZData_ZeroFix=TempZData_NaN;
        TempZData_ZeroFix(isnan(TempZData_ZeroFix))=MinZZeroAdjust;
    else
        TempZData_NaN=TempZData;
        TempZData_ZeroFix=TempZData;
    end
%     
    
    FitFig=figure('name',Title);
    set(gcf,'units','normalized','position',FigurePosition_AllFits)
    set(gcf, 'color', 'white');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitDetails.FitType(1).Label='Linear Polynomial Surface';
    [FitDetails.FitType(1).FitObject,...
        FitDetails.FitType(1).GoodnessOfFit,...
        FitDetails.FitType(1).Output]=...
        fit([TempXData_NoNaN',TempYData_NoNaN'],TempZData_NoNaN','poly11');
%     FitDetails.FitType(1).Label
%     FitDetails.FitType(1).FitObject
%     FitDetails.FitType(1).GoodnessOfFit
%     FitDetails.FitType(1).Output
    FitDetails.FitType(1).SurfaceZData=...
        FitDetails.FitType(1).FitObject.p00 + ...
        FitDetails.FitType(1).FitObject.p10*FitDetails.SurfaceXData + ...
        FitDetails.FitType(1).FitObject.p01*FitDetails.SurfaceYData;
    FitDetails.FitType(1).SurfaceEquation=...
        ['z=',num2str(FitDetails.FitType(1).FitObject.p00),'+',...
        num2str(FitDetails.FitType(1).FitObject.p10),'x+',...
        num2str(FitDetails.FitType(1).FitObject.p01),'y'];

    S(1)=subplot(2,3,1);
    title({[FitDetails.FitType(1).Label];[' R2 = ',num2str(FitDetails.FitType(1).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(1).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    p=plot3(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,...
        '.','color','k','markersize',10);
    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([0,XMax*UpperLimitBuffer])
    ylim([0,YMax*UpperLimitBuffer])
    zlim([0,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    %FigureStandardizer(get(gca,'xlabel'), get(gca,'ylabel'), gca);
    set(gcf, 'color', 'white');
    %set(gca, 'units','normalized');TempPos=get(gca,'position');set(gca,'position',[TempPos(1),TempPos(2),TempPos(3)*0.6,TempPos(3)])
    %set(gcf,'units','normalized','position',[0.25 0.25 0.3 0.7])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitDetails.FitType(2).Label='Double Second Degree Regression Surface';
    [FitDetails.FitType(2).FitObject,...
        FitDetails.FitType(2).GoodnessOfFit,...
        FitDetails.FitType(2).Output]=...
        fit([TempXData_NoNaN',TempYData_NoNaN'],TempZData_NoNaN','poly22');
%     FitDetails.FitType(2).Label
%     FitDetails.FitType(2).FitObject
%     FitDetails.FitType(2).GoodnessOfFit
%     FitDetails.FitType(2).Output
    FitDetails.FitType(2).SurfaceZData=...
        FitDetails.FitType(2).FitObject.p00 + ...
        FitDetails.FitType(2).FitObject.p10*FitDetails.SurfaceXData + ...
        FitDetails.FitType(2).FitObject.p01*FitDetails.SurfaceYData + ...
        FitDetails.FitType(2).FitObject.p20*FitDetails.SurfaceXData.^2 + ...
        FitDetails.FitType(2).FitObject.p11*FitDetails.SurfaceXData.*FitDetails.SurfaceYData + ...
        FitDetails.FitType(2).FitObject.p02*FitDetails.SurfaceYData.^2;
    FitDetails.FitType(2).SurfaceEquation=...
        ['z=',num2str(FitDetails.FitType(2).FitObject.p00),'+',...
        num2str(FitDetails.FitType(2).FitObject.p10),'x+',...
        num2str(FitDetails.FitType(2).FitObject.p01),'y+',...
        num2str(FitDetails.FitType(2).FitObject.p20),'x2+',...
        num2str(FitDetails.FitType(2).FitObject.p11),'xy+',...
        num2str(FitDetails.FitType(2).FitObject.p02),'y2+',...
        ];


    S(2)=subplot(2,3,2);
    title({[FitDetails.FitType(2).Label];[' R2 = ',num2str(FitDetails.FitType(2).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(2).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    p=plot3(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,...
        '.','color','k','markersize',10);
    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([0,XMax*UpperLimitBuffer])
    ylim([0,YMax*UpperLimitBuffer])
    zlim([0,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    %FigureStandardizer(get(gca,'xlabel'), get(gca,'ylabel'), gca);
    set(gcf, 'color', 'white');
    %set(gcf,'units','normalized','position',[0.25 0.25 0.3 0.7])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitDetails.FitType(3).Label='First Degree X Second Degree Y Regression Surface';
    [FitDetails.FitType(3).FitObject,...
        FitDetails.FitType(3).GoodnessOfFit,...
        FitDetails.FitType(3).Output]=...
        fit([TempXData_NoNaN',TempYData_NoNaN'],TempZData_NoNaN','poly12');
%     FitDetails.FitType(3).Label
%     FitDetails.FitType(3).FitObject
%     FitDetails.FitType(3).GoodnessOfFit
%     FitDetails.FitType(3).Output
    FitDetails.FitType(3).SurfaceZData=...
        FitDetails.FitType(3).FitObject.p00 + ...
        FitDetails.FitType(3).FitObject.p10*FitDetails.SurfaceXData + ...
        FitDetails.FitType(3).FitObject.p01*FitDetails.SurfaceYData + ...
        FitDetails.FitType(3).FitObject.p11*FitDetails.SurfaceXData.*FitDetails.SurfaceYData + ...
        FitDetails.FitType(3).FitObject.p02*FitDetails.SurfaceYData.^2;
   
    S(4)=subplot(2,3,4);
    title({[FitDetails.FitType(3).Label];[' R2 = ',num2str(FitDetails.FitType(3).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(3).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    p=plot3(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,...
        '.','color','k','markersize',10);
    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([0,XMax*UpperLimitBuffer])
    ylim([0,YMax*UpperLimitBuffer])
    zlim([0,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    %FigureStandardizer(get(gca,'xlabel'), get(gca,'ylabel'), gca);
    set(gcf, 'color', 'white');
    %set(gcf,'units','normalized','position',[0.25 0.25 0.3 0.7])
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitDetails.FitType(4).Label='Second Degree X First Degree Y Regression Surface';
    [FitDetails.FitType(4).FitObject,...
        FitDetails.FitType(4).GoodnessOfFit,...
        FitDetails.FitType(4).Output]=...
        fit([TempXData_NoNaN',TempYData_NoNaN'],TempZData_NoNaN','poly21');
%     FitDetails.FitType(4).Label
%     FitDetails.FitType(4).FitObject
%     FitDetails.FitType(4).GoodnessOfFit
%     FitDetails.FitType(4).Output
    FitDetails.FitType(4).SurfaceZData=...
        FitDetails.FitType(4).FitObject.p00 + ...
        FitDetails.FitType(4).FitObject.p10*FitDetails.SurfaceXData + ...
        FitDetails.FitType(4).FitObject.p01*FitDetails.SurfaceYData + ...
        FitDetails.FitType(4).FitObject.p20*FitDetails.SurfaceXData.^2 + ...
        FitDetails.FitType(4).FitObject.p11*FitDetails.SurfaceXData.*FitDetails.SurfaceYData;        
   
    S(5)=subplot(2,3,5);
    title({[FitDetails.FitType(4).Label];[' R2 = ',num2str(FitDetails.FitType(4).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(4).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    p=plot3(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,...
        '.','color','k','markersize',10);
    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([0,XMax*UpperLimitBuffer])
    ylim([0,YMax*UpperLimitBuffer])
    zlim([0,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    %FigureStandardizer(get(gca,'xlabel'), get(gca,'ylabel'), gca);
    set(gcf, 'color', 'white');
    %set(gcf,'units','normalized','position',[0.25 0.25 0.3 0.7])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitDetails.FitType(5).Label='Double Third Degree Regression Surface';
    [FitDetails.FitType(5).FitObject,...
        FitDetails.FitType(5).GoodnessOfFit,...
        FitDetails.FitType(5).Output]=...
        fit([TempXData_NoNaN',TempYData_NoNaN'],TempZData_NoNaN','poly33');
%     FitDetails.FitType(5).Label
%     FitDetails.FitType(5).FitObject
%     FitDetails.FitType(5).GoodnessOfFit
%     FitDetails.FitType(5).Output
    FitDetails.FitType(5).SurfaceZData=...
        FitDetails.FitType(5).FitObject.p00 + ...
        FitDetails.FitType(5).FitObject.p10*FitDetails.SurfaceXData + ...
        FitDetails.FitType(5).FitObject.p01*FitDetails.SurfaceYData + ...
        FitDetails.FitType(5).FitObject.p20*FitDetails.SurfaceXData.^2 + ...
        FitDetails.FitType(5).FitObject.p11*FitDetails.SurfaceXData.*FitDetails.SurfaceYData + ...
        FitDetails.FitType(5).FitObject.p02*FitDetails.SurfaceYData.^2 + ...
        FitDetails.FitType(5).FitObject.p30*FitDetails.SurfaceXData.^3 + ...
        FitDetails.FitType(5).FitObject.p21*FitDetails.SurfaceXData.^2.*FitDetails.SurfaceYData + ...
        FitDetails.FitType(5).FitObject.p12*FitDetails.SurfaceXData.*FitDetails.SurfaceYData.^2 + ...
        FitDetails.FitType(5).FitObject.p03*FitDetails.SurfaceYData.^3;

    S(3)=subplot(2,3,3);
    title({[FitDetails.FitType(5).Label];[' R2 = ',num2str(FitDetails.FitType(5).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(5).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    p=plot3(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,...
        '.','color','k','markersize',10);
    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([0,XMax*UpperLimitBuffer])
    ylim([0,YMax*UpperLimitBuffer])
    zlim([0,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    
    for s=1:length(S)
       TempPos=get(S(s),'position');
       set(S(s),'position',[TempPos(1),TempPos(2),SubPlotSize(1),SubPlotSize(2)])
    end
%     export_fig( [FigSaveDir,dc,Title,' 3D Fits', '.png'], '-png','-tif','-nocrop','-transparent');
%     for s=1:length(S)
%        axes(S(s));
%        alpha(1)
%     end
    %saveas(gcf, [FigSaveDir,dc,Title,' 3D Fits', '.fig']);
    %saveas(gcf, [FigSaveDir,dc,Title,' 3D Fits', '.eps'],'epsc2');
    %export_fig( [FigSaveDir,dc,Title,' 3D Fits V2', '.eps'], '-eps','-nocrop','-transparent');
    Full_Export_Fig(gcf,gca,Check_Dir_and_File([FigSaveDir,dc],[Title,' 3D Fits'],[],1),4)
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitFig2=figure('name',[Title,' Log-Log-Log']);
    set(gcf,'units','normalized','position',FigurePosition_AllFits)
    set(gcf, 'color', 'white');

    S(1)=subplot(2,3,1);
    title({[FitDetails.FitType(1).Label];[' R2 = ',num2str(FitDetails.FitType(1).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(1).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    Log3DPlotZeroCorrection(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,[],10,AdjustRatio)

    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([XMin*0.9,XMax*UpperLimitBuffer])
    ylim([YMin*0.9,YMax*UpperLimitBuffer])
    zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    set(gca,'XScale','log');set(gca,'YScale','log');set(gca,'ZScale','log');
  
    S(2)=subplot(2,3,2);
    title({[FitDetails.FitType(2).Label];[' R2 = ',num2str(FitDetails.FitType(2).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(2).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    Log3DPlotZeroCorrection(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,[],10,AdjustRatio)

    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([XMin*0.9,XMax*UpperLimitBuffer])
    ylim([YMin*0.9,YMax*UpperLimitBuffer])
    zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    set(gca,'XScale','log');set(gca,'YScale','log');set(gca,'ZScale','log');

    S(4)=subplot(2,3,4);
    title({[FitDetails.FitType(3).Label];[' R2 = ',num2str(FitDetails.FitType(3).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(3).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    Log3DPlotZeroCorrection(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,[],10,AdjustRatio)

    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([XMin*0.9,XMax*UpperLimitBuffer])
    ylim([YMin*0.9,YMax*UpperLimitBuffer])
    zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    set(gca,'XScale','log');set(gca,'YScale','log');set(gca,'ZScale','log');

    S(5)=subplot(2,3,5);
    title({[FitDetails.FitType(4).Label];[' R2 = ',num2str(FitDetails.FitType(4).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(4).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    Log3DPlotZeroCorrection(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,[],10,AdjustRatio)

    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([XMin*0.9,XMax*UpperLimitBuffer])
    ylim([YMin*0.9,YMax*UpperLimitBuffer])
    zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    set(gca,'XScale','log');set(gca,'YScale','log');set(gca,'ZScale','log');

    S(3)=subplot(2,3,3);
    title({[FitDetails.FitType(5).Label];[' R2 = ',num2str(FitDetails.FitType(5).GoodnessOfFit.rsquare)]})
    hold on
    surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(5).SurfaceZData)
    alpha(SurfaceFitAlpha)
    shading interp
    Log3DPlotZeroCorrection(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,[],10,AdjustRatio)

    grid on
    XLimits=xlim;
    YLimits=ylim;
    ZLimits=zlim;
    xlim([XMin*0.9,XMax*UpperLimitBuffer])
    ylim([YMin*0.9,YMax*UpperLimitBuffer])
    zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
    xlabel(XLabel)
    ylabel(YLabel,'rotation',-60)
    zlabel(ZLabel);
    view(Azimuth,Elevation) 
    set(gca,'XScale','log');set(gca,'YScale','log');set(gca,'ZScale','log');
    
    
    
    
    for s=1:length(S)
       TempPos=get(S(s),'position');
       set(S(s),'position',[TempPos(1),TempPos(2),SubPlotSize(1),SubPlotSize(2)])
    end
    %export_fig( [FigSaveDir,dc,Title,' 3D Fits Log', '.png'], '-png','-tif','-nocrop','-transparent');
%     for s=1:length(S)
%        axes(S(s));
%        alpha(1)
%     end
    %saveas(gcf, [FigSaveDir,dc,Title,' 3D Fits', '.fig']);
    %saveas(gcf, [FigSaveDir,dc,Title,' 3D Fits Log', '.eps'],'epsc2');
    %export_fig( [FigSaveDir,dc,Title,' 3D Fits Log V2', '.eps'], '-eps','-nocrop','-transparent');
    Full_Export_Fig(gcf,gca,Check_Dir_and_File([FigSaveDir,dc],[Title,' 3D Fits Log'],[],1),4)
    close all
    jheapcl
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:length(FitDetails.FitType)
        FitDetails.FitType(i).Num_Pairs=length(FitDetails.FitType(i).Output.residuals);
        FitDetails.FitType(i).Residuals=FitDetails.FitType(i).Output.residuals;
        FitDetails.FitType(i).Mean_Residuals=mean(FitDetails.FitType(i).Output.residuals);
        FitDetails.FitType(i).STD_Residuals=std(FitDetails.FitType(i).Output.residuals);
        FitDetails.FitType(i).SEM_Residuals=FitDetails.FitType(i).STD_Residuals/sqrt(FitDetails.FitType(i).Num_Pairs);
        [FitDetails.FitType(i).Residuals_Histogram_Counts,FitDetails.FitType(i).Residuals_Histogram_Bin_Centers]=hist(FitDetails.FitType(i).Output.residuals);
        FitDetails.FitType(i).Num_1SD=length(FitDetails.FitType(i).Residuals(FitDetails.FitType(i).Residuals<FitDetails.FitType(i).STD_Residuals*-1))+...
            length(FitDetails.FitType(i).Residuals(FitDetails.FitType(i).Residuals>FitDetails.FitType(i).STD_Residuals*1));
        FitDetails.FitType(i).Percent_1SD=FitDetails.FitType(i).Num_1SD/FitDetails.FitType(i).Num_Pairs;
        FitDetails.FitType(i).Num_2SD=length(FitDetails.FitType(i).Residuals(FitDetails.FitType(i).Residuals<FitDetails.FitType(i).STD_Residuals*-2))+...
            length(FitDetails.FitType(i).Residuals(FitDetails.FitType(i).Residuals>FitDetails.FitType(i).STD_Residuals*2));
        FitDetails.FitType(i).Percent_2SD=FitDetails.FitType(i).Num_2SD/FitDetails.FitType(i).Num_Pairs;
    end
    for i=1:length(FitDetails.FitType)
        disp('=======================================')
        disp(['Fit #',num2str(i)])
        disp([FitDetails.FitType(i).Label])
        disp(['rsquare          = ',num2str(FitDetails.FitType(i).GoodnessOfFit.rsquare)])
        disp(['adjusted rsquare = ',num2str(FitDetails.FitType(i).GoodnessOfFit.adjrsquare)])
        disp(['percent residuals +/- 1SD = ',num2str(FitDetails.FitType(i).Percent_1SD)])
        disp(['percent residuals +/- 2SD = ',num2str(FitDetails.FitType(i).Percent_2SD)])
    end
    disp('=======================================')
    fprintf('Exporting Individual fit plots...')
    for i=1:length(FitDetails.FitType)
        FigName=[Title,' ',FitDetails.FitType(i).Label];
        TempFig=figure('name',FigName);
        set(gcf,'units','pixels','position',FigurePosition_3D)
        set(gcf, 'color', 'white');
        %title({Title;[FitDetails.FitType(i).Label];[' R2 = ',num2str(FitDetails.FitType(i).GoodnessOfFit.rsquare)]},'interpreter','none')
        hold on
        surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(i).SurfaceZData)
        alpha(SurfaceFitAlpha)
        shading interp
        p=plot3(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,...
            '.','color','k','markersize',10);
        grid on
        XLimits=xlim;
        YLimits=ylim;
        ZLimits=zlim;
        xlim([XMin*0.9,XMax*UpperLimitBuffer])
        ylim([YMin*0.9,YMax*UpperLimitBuffer])
        zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
        if isfield(FitDetails.FitType(i),'SurfaceEquation')
            text(XMin,YMax,ZMax,['R2=',num2str(FitDetails.FitType(i).GoodnessOfFit.rsquare),' ',...
                FitDetails.FitType(i).SurfaceEquation])
        end
        xlabel(XLabel)
        ylabel(YLabel,'rotation',-60)
        zlabel(ZLabel);
        view(Azimuth,Elevation) 
        set(gcf,'units','pixels','position',FigurePosition_3D)
        set(gca,'units','pixels','position',AxesPosition_3D)
        FigureStandardizer_FixTicks(gca,AxesStandardFontSizes);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if Save3DFitFigs;saveas(gcf, [FigSaveDir,dc,FigName,' 3D Fits', '.fig']);end
        Full_Export_Fig(gcf,gca,Check_Dir_and_File([FigSaveDir,dc],[FigName,' 3D Fits'],[],1),4)
        Full_Export_Fig(gcf,gca,Check_Dir_and_File([FigSaveDir,dc],[FigName,' 3D Fits'],[],1),11)
        %Full_Export_Fig(gcf,gca,[FigSaveDir,dc,FigName,' 3D Fits'],15)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if any(MovieFits==i)
            pbaspect([1,1,1])
            title([])
            mov = VideoWriter([FigSaveDir,dc,FigName,' 3D Fits Rotating.avi'],'Motion JPEG AVI');
            colormap('parula')
            mov.FrameRate = 30;  % Default 30
            mov.Quality = 70;    % Default 75
            open(mov);
            CurrentView=get(gca,'view');
            set(gca,'view',CurrentView)
            xlabel(XLabel)
            ylabel(YLabel,'rotation',-60)
            zlabel(ZLabel);
            for t=1:20
                OneFrame = getframe(gcf);
                writeVideo(mov,OneFrame);
            end
            zlabel([])
            xlabel([])
            ylabel([])
            for t=0:360
                set(gca,'view',[CurrentView(1)+t,CurrentView(2)])
                pbaspect([1,1,1])

                OneFrame = getframe(gcf);
                writeVideo(mov,OneFrame);
            end
            xlabel(XLabel)
            ylabel(YLabel,'rotation',-60)
            zlabel(ZLabel);
            for t=1:20
                OneFrame = getframe(gcf);
                writeVideo(mov,OneFrame);
            end
            close(mov);
        end
        close(gcf)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        FigName=[Title,' ',FitDetails.FitType(i).Label,' Log_Log_Log'];
        TempFig=figure('name',FigName);
        set(gcf,'units','pixels','position',FigurePosition_3D)
        set(gcf, 'color', 'white');
        %title({Title;[FitDetails.FitType(i).Label];[' R2 = ',num2str(FitDetails.FitType(i).GoodnessOfFit.rsquare)]},'interpreter','none')
        hold on
        surf(FitDetails.SurfaceXData,FitDetails.SurfaceYData,FitDetails.FitType(i).SurfaceZData)
        alpha(SurfaceFitAlpha)
        shading interp
        Log3DPlotZeroCorrection(TempXData_NoNaN,TempYData_NoNaN,TempZData_NoNaN,[],10,AdjustRatio)
        grid on
        XLimits=xlim;
        YLimits=ylim;
        ZLimits=zlim;
        xlim([XMin*0.9,XMax*UpperLimitBuffer])
        ylim([YMin*0.9,YMax*UpperLimitBuffer])
        zlim([MinZZeroAdjust*0.9,ZMax*UpperLimitBuffer])
        if isfield(FitDetails.FitType(i),'SurfaceEquation')
            text(XMin,YMax,ZMax,['R2=',num2str(FitDetails.FitType(i).GoodnessOfFit.rsquare),' ',...
                FitDetails.FitType(i).SurfaceEquation])
        end
        xlabel(XLabel)
        ylabel(YLabel,'rotation',-60)
        zlabel(ZLabel);
        view(Azimuth,Elevation) 
        set(gca,'XScale','log');set(gca,'YScale','log');set(gca,'ZScale','log');
        grid on
        FigureStandardizer(get(gca,'xlabel'), get(gca,'ylabel'), gca);
%         if i==1
%             saveas(gcf, [FigSaveDir,dc,FigName,' 3D Fits Log', '.fig']);
%         end
        %export_fig( [FigSaveDir,dc,FigName,' 3D Fits Log', '.png'], '-png','-tif','-nocrop','-transparent');
        Full_Export_Fig(gcf,gca,Check_Dir_and_File([FigSaveDir,dc],[FigName,' 3D Fits Log'],[],1),4)
        %alpha(1)
        Full_Export_Fig(gcf,gca,Check_Dir_and_File([FigSaveDir,dc],[FigName,' 3D Fits Log'],[],1),11)
        %Full_Export_Fig(gcf,gca,[FigSaveDir,dc,FigName,' 3D Fits Log'],15)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if any(MovieFits==i)
            pbaspect([1,1,1])
            title([])
            mov = VideoWriter([FigSaveDir,dc,FigName,' 3D Fits Log Rotating.avi'],'Motion JPEG AVI');
            colormap('parula')
            mov.FrameRate = 30;  % Default 30
            mov.Quality = 70;    % Default 75
            open(mov);
            CurrentView=get(gca,'view');
            set(gca,'view',CurrentView)
            xlabel(XLabel)
            ylabel(YLabel,'rotation',-60)
            zlabel(ZLabel);
            for t=1:20
                OneFrame = getframe(gcf);
                writeVideo(mov,OneFrame);
            end
            zlabel([])
            xlabel([])
            ylabel([])
            for t=0:360
                set(gca,'view',[CurrentView(1)+t,CurrentView(2)])
                pbaspect([1,1,1])

                OneFrame = getframe(gcf);
                writeVideo(mov,OneFrame);
            end
            xlabel(XLabel)
            ylabel(YLabel,'rotation',-60)
            zlabel(ZLabel);
            for t=1:20
                OneFrame = getframe(gcf);
                writeVideo(mov,OneFrame);
            end
            close(mov);
        end
        close(gcf)

    end
    fprintf('Finished!\n')
    disp('=======================================')
    disp('=======================================')
    disp('=======================================')
    disp('=======================================')
    
    
end


