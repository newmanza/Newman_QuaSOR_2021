        if EventDetectionSettings.DetectionMethod==1

        elseif EventDetectionSettings.DetectionMethod==2
            fprintf(['Making: ',FigName,'...'])
            %%%%%%%%%%%%%%%%%%%%
            set(gcf,'position',[0,50,1200,600])
            %%%%%%%%%%%%%%%%%%%%
            ax(1)=subplot(2,3,1);
            plot([1:length(EventDetectionSettings.Template.TemplateResponse)],EventDetectionSettings.Template.TemplateResponse,'.-','color','k','linewidth',1,'markersize',10)
            hold on
            plot([EventDetectionSettings.Template.TemplatePeakPosition,EventDetectionSettings.Template.TemplatePeakPosition],[0,1],'-','color','g','linewidth',1)
            plot(EventDetectionSettings.Template.PeakFrames,EventDetectionSettings.Template.TemplateResponse(EventDetectionSettings.Template.PeakFrames),'*-','color','m','linewidth',1,'markersize',8)
            xlim([1,length(EventDetectionSettings.Template.TemplateResponse)])
            xlabel('Frame')
            ylabel('\DeltaF/F')
            title(['TemplateResponse'],'interpreter','none')
            leg=legend({'TemplateResponse','TemplatePeakPosition','PeakFrames'});
            TempPos=get(leg,'position');
            set(leg,'position',[TempPos(1)-TempPos(3),TempPos(2),TempPos(3),TempPos(4)])
            %%%%%%%%%%%%%%%%%%%%
            ax(2)=subplot(2,3,4);
            if EventDetectionSettings.Template.MultiTemplateFitting
                
                Spacer=1;
                ylim([-0.1,length(EventDetectionSettings.Template.TemplateStruct)*Spacer+1.5])
                hold on
                plot([-2,-2],[-0.1,length(EventDetectionSettings.Template.TemplateStruct)*Spacer+1.5],':','color',[0.5,0.5,0.5],'linewidth',1)
                plot([-1,-1],[-0.1,length(EventDetectionSettings.Template.TemplateStruct)*Spacer+1.5],':','color',[0.25,0.25,0.25],'linewidth',1)
                plot([0,0],[-0.1,length(EventDetectionSettings.Template.TemplateStruct)*Spacer+1.5],':','color',[0,0,0],'linewidth',1)
                plot([1,1],[-0.1,length(EventDetectionSettings.Template.TemplateStruct)*Spacer+1.5],':','color',[0.25,0.25,0.25],'linewidth',1)
                plot([2,2],[-0.1,length(EventDetectionSettings.Template.TemplateStruct)*Spacer+1.5],':','color',[0.5,0.5,0.5],'linewidth',1)
                for Template=1:length(EventDetectionSettings.Template.TemplateStruct)
                    plot([1:length(EventDetectionSettings.Template.TemplateStruct(Template).corrTemplate)]-EventDetectionSettings.Template.TemplateStruct(Template).corrTemplate_PeakPosition,...
                        EventDetectionSettings.Template.TemplateStruct(Template).corrTemplate+Spacer*Template,'-','linewidth',2)
                    text(-1*EventDetectionSettings.Template.TemplateStruct(Template).corrTemplate_PeakPosition-0.25,...
                        EventDetectionSettings.Template.TemplateStruct(Template).corrTemplate(1)+Spacer*Template,num2str(Template))
                end

                xlabel('Frame')
                ylabel('\DeltaF/F')
                title(['Multi corrTemplate'],'interpreter','none')
            else
                plot([1:length(EventDetectionSettings.Template.corrTemplate)],EventDetectionSettings.Template.corrTemplate,'.-','color','k','linewidth',1,'markersize',10)
                hold on
                plot([EventDetectionSettings.Template.TemplatePeakPosition,EventDetectionSettings.Template.TemplatePeakPosition],[0,1],'-','color','g','linewidth',1)
                plot(EventDetectionSettings.Template.PeakFrames,EventDetectionSettings.Template.corrTemplate(EventDetectionSettings.Template.PeakFrames),'*-','color','m','linewidth',1,'markersize',8)
                xlim([1,length(EventDetectionSettings.Template.TemplateResponse)])
                xlabel('Frame')
                ylabel('\DeltaF/F')
                title(['corrTemplate'],'interpreter','none')
                leg=legend({'corrTemplate','TemplatePeakPosition','PeakFrames'});
                TempPos=get(leg,'position');
                set(leg,'position',[TempPos(1)-TempPos(3),TempPos(2),TempPos(3),TempPos(4)])
            end
            %%%%%%%%%%%%%%%%%%%%
            ax(3)=subplot(2,3,2);
            if ~isempty(EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean)
                lineProps.col{1}='k';
                lineProps.style='.-';
                lineProps.width=0.5;
                mseb([1:size(EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean,2)],...
                    EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean,...
                    EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_STD,...
                    lineProps,0);
                xlim([1,size(EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean,2)])
                xlabel('Episode Frame')
                ylabel({'Mean Whole NMJ';'\DeltaF/F (STD)'})
                title(['Mean Whole DeltaF/F0'],'interpreter','none')
            end
            %%%%%%%%%%%%%%%%%%%%
            ax(4)=subplot(2,3,5);
            if ~isempty(EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean)
                hold on
                for EpisodeNumber=1:size(EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean,1)
                    plot([1:size(EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean,2)],...
                        EventDetectionSettings.TemplateGeneration.All_Episodes_DeltaFF0_Mean(EpisodeNumber,:),...
                        '-','color','k','linewidth',0.25)
                end
                xlim([1,size(EpisodeStruct(EpisodeNumber).MeanDeltaFF0_Vector,2)])
                xlabel('Episode Frame')
                ylabel({'Mean Whole NMJ';'\DeltaF/F'})
                title(['All Whole DeltaF/F0'],'interpreter','none')
            end
            %%%%%%%%%%%%%%%%%%%%
            if ~isempty(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0)
                ax(5)=subplot(2,3,3);
                lineProps.col{1}='k';
                lineProps.style='.-';
                lineProps.width=0.5;
                mseb([1:size(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0_Mean,2)],...
                    EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0_Mean,...
                    EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0_STD,...
                    lineProps,0);
                xlim([1,size(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0_Mean,2)])
                xlabel('Episode Frame')
                ylabel({'Mean Auto Event';'\DeltaF/F (STD)'})
                title(['Mean Auto Event DeltaFF0s'],'interpreter','none')
                %%%%%%%%%%%%%%%%%%%%
                ax(6)=subplot(2,3,6);
                hold on
                for i=1:size(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0,1)
                    plot([1:size(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0,2)],...
                        EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0(i,:),...
                        '-','color','k','linewidth',0.25)
                end
                xlim([1,size(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0,2)])
                xlabel('Episode Frame')
                ylabel({'Auto Event';'\DeltaF/F'})
                title([num2str(size(EventDetectionSettings.TemplateGeneration.All_TestEvents_DeltaFF0,1)),' Events'],'interpreter','none')
            end
            fprintf('Finished!\n')
        elseif EventDetectionSettings.DetectionMethod==3
            
        end
