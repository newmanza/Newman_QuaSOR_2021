function [LinkedLineHandles,LinkedMarkerHandles,MeanHandles,ErrorHandles]=...
    plotLinked_withMeanError(XData,YData,MeanData,SEMData,Pairs,MeanWidth,MeanOffset,SEMWidth,...
    Color,MarkerSize,MarkerStyle,MeanLineWidth,ErrorLineWidth,LinkLineWidth,LinkLineStyle,LinkLineColor)


% Pairs=ExperimentSetPairs(ExperimentSetPairCount).Ib_Is_Pairs_RecordingNums;
% XData=[1,2];
% YData=ExperimentSet_Mean_RFProb_byNMJ_wGaps;
% MeanData=ExperimentSet_OverallPrepMean_Mean_RFProb_byNMJ;
% SEMData=ExperimentSet_OverallPrepSEM_Mean_RFProb_byNMJ;
% MeanWidth=0.2;
% MeanOffset=0.2;
% SEMWidth=0.1;
% Color=ExperimentSet_Colors
% MarkerSize=ExperimentSetMarkerSize(ExperimentSetPairCount)
% MarkerStyle=ExperimentSetMarkerStyles{ExperimentSetPairCount}
% MeanLineWidth=1.5
% ErrorLineWidth=1.5
% LinkLineWidth=1
% LinkLineStyle='-';
% LinkLineColor=ExperimentSetPairs(ExperimentSetPairCount).Color
% 
% % 
% figure('name',strcat('Test'));
% hold on;set(gcf,'position',[0,0,ByNMJFigureDimensions]);
% xlim([0.5,length(ExperimentSet)+0.5]);
% set(gcf, 'color', 'white');
% set(gca, 'XTick',[1:1:length(ExperimentSet)]);
% set(gca, 'XTickLabel', []);
if isempty(Pairs)
    for i=1:length(YData{1})
        for j=1:length(XData)
            Pairs(i,j)=i;
        end
    end
end
NumPairs=size(Pairs,1);
for i=1:length(YData)
    Temp(i).YData=YData{i};
end
for j=1:NumPairs
    if isnan(Pairs(j,1))
        LinkedMarkerHandles(2,j)=plot(XData(2)-MeanOffset/2,Temp(2).YData(Pairs(j,2)),MarkerStyle,'color',Color(2,:),'MarkerSize',MarkerSize);
    elseif isnan(Pairs(j,2))
        LinkedMarkerHandles(1,j)=plot(XData(1)+MeanOffset/2,Temp(1).YData(Pairs(j,1)),MarkerStyle,'color',Color(1,:),'MarkerSize',MarkerSize);
    else
        LinkedLineHandles(j)=plot([XData(1)+MeanOffset/2,XData(2)-MeanOffset/2],[Temp(1).YData(Pairs(j,1)),Temp(2).YData(Pairs(j,2))],LinkLineStyle,'color',LinkLineColor);
        LinkedMarkerHandles(1,j)=plot(XData(1)+MeanOffset/2,Temp(1).YData(Pairs(j,1)),MarkerStyle,'color',Color(1,:),'MarkerSize',MarkerSize);
        LinkedMarkerHandles(2,j)=plot(XData(2)-MeanOffset/2,Temp(2).YData(Pairs(j,2)),MarkerStyle,'color',Color(2,:),'MarkerSize',MarkerSize);
    end
end
MeanHandles(1)=plot([XData(1)-MeanOffset/2-MeanWidth/2,XData(1)-MeanOffset/2+MeanWidth/2],[MeanData(1),MeanData(1)],'-','color',Color(1,:),'LineWidth', MeanLineWidth);
MeanHandles(2)=plot([XData(2)+MeanOffset/2-MeanWidth/2,XData(2)+MeanOffset/2+MeanWidth/2],[MeanData(2),MeanData(2)],'-','color',Color(2,:),'LineWidth', MeanLineWidth);
ErrorHandles(1)=errorbar(XData(1)-MeanOffset/2,MeanData(1),SEMData(1),'-','color',Color(1,:),'LineWidth', ErrorLineWidth);
ErrorHandles(2)=errorbar(XData(2)+MeanOffset/2,MeanData(2),SEMData(2),'-','color',Color(2,:),'LineWidth', ErrorLineWidth);
for j = 1:length(MeanData)
    errorbar_tick(ErrorHandles(j),SEMWidth,'UNITS');
end

% 
% for j = 1:length(ExperimentSet)
%     text(j,  -0.02, ExperimentSet_Legend(j), 'Rotation',ShortLabelRotation, 'fontsize', XLabelTextSize, 'HorizontalAlignment', ShortLabelAlignment,'FontName','Arial');
% end
% 
% YLimits=ylim;
% ylim([0,YLimits(2)]);
% ylabel('Mean \DeltaF/F');
% FigureStandardizer(get(gca,'xlabel'), get(gca,'ylabel'), gca);
% hold off

% 
% Pairs=PairedNums;
% XData=[1,2];
% YData=IbIs_DeltaF_Integral;
% MeanData=IbIs_DeltaF_Integral_Mean;
% SEMData=IbIs_DeltaF_Integral_SEM;
% MeanWidth=0.2;
% MeanOffset=0.2;
% SEMWidth=0.1;
% Color=NMJColors
% MarkerStyle=NMJMarkerStyles{1};
% MeanLineWidth=1.5
% ErrorLineWidth=1.5
% LinkLineWidth=1
% LinkLineStyle='-';
% LinkLineColor='k'
% 
% % 
% figure('name',strcat('Test'));
% hold on;set(gcf,'position',[0,0,ByNMJFigureDimensions]);
% xlim([0.5,length(ExperimentSet)+0.5]);
% set(gcf, 'color', 'white');
% set(gca, 'XTick',[1:1:length(ExperimentSet)]);
% set(gca, 'XTickLabel', []);
% 
% 
% 
%     IbIs_DeltaF_Integral,...
%     IbIs_DeltaF_Integral_Mean,...
%     IbIs_DeltaF_Integral_SEM,...
%     PairedNums,MeanWidth,MeanOffset,SEMWidth,NMJColors,MarkerSize,NMJMarkerStyles,...
%     LineWidth,LineWidth,LinkLineWidth