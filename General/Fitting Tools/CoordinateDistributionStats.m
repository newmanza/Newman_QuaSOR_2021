function [Coord_Dist_Stats]=CoordinateDistributionStats(myPool,DistMode,InputImage,CenterCoord,PixelSize,PixelUnits,DistanceBinSize,DisplayOn)
    ParallelLargeCalc=0;
    Coord_Dist_Stats.DistanceMatrix=zeros(size(InputImage));
    if DistMode==0 %Center Rotate
        fprintf('Rotational Analysis...')
        Coord_Dist_Stats.CenterCoord=CenterCoord;
        for x=1:size(InputImage,2)
            for y=1:size(InputImage,1)
                Coord_Dist_Stats.DistanceMatrix(y,x)=sqrt((CenterCoord(1)-y)^2+(CenterCoord(2)-x)^2);
            end
        end
    elseif DistMode==1 %Vert Up Planar
        fprintf('Vertical Up Planar Analysis...')
        Coord_Dist_Stats.CenterCoord=CenterCoord;
        for x=1:size(InputImage,2)
            for y=1:size(InputImage,1)
                Coord_Dist_Stats.DistanceMatrix(y,x)=(size(InputImage,1)-y+1);
            end
        end
    elseif DistMode==2 %Horz Left Planar
        fprintf('Horizontal Left Planar Analysis...')
        Coord_Dist_Stats.CenterCoord=CenterCoord;
        for x=1:size(InputImage,2)
            for y=1:size(InputImage,1)
                Coord_Dist_Stats.DistanceMatrix(y,x)=(size(InputImage,2)-x+1);
            end
        end        
    elseif DistMode==3 %Vert Down Planar
        fprintf('Vertical Down Planar Analysis...')
        Coord_Dist_Stats.CenterCoord=CenterCoord;
        for x=1:size(InputImage,2)
            for y=1:size(InputImage,1)
                Coord_Dist_Stats.DistanceMatrix(y,x)=(y);
            end
        end
    elseif DistMode==4 %Horz Right Planar
        fprintf('Horizontal Right Planar Analysis...')
        Coord_Dist_Stats.CenterCoord=CenterCoord;
        for x=1:size(InputImage,2)
            for y=1:size(InputImage,1)
                Coord_Dist_Stats.DistanceMatrix(y,x)=(x);
            end
        end        
    end
    
    Coord_Dist_Stats.PixelUnits=PixelUnits;
    Coord_Dist_Stats.PixelSize=1.6;
    Coord_Dist_Stats.DistanceMatrix=Coord_Dist_Stats.DistanceMatrix*PixelSize;
    Coord_Dist_Stats.DistanceMax=ceil(max(Coord_Dist_Stats.DistanceMatrix(:))/10)*10;
    Coord_Dist_Stats.DistanceBinSize=DistanceBinSize;
    Coord_Dist_Stats.PixelArea=PixelSize^2;
    [~,...
        ~,...
        ~,...
        Coord_Dist_Stats.Possible_Distance_Histogram_Centers,...
        Coord_Dist_Stats.Possible_Distance_Histogram,...
        ~,...
        ~,...
        ~]=...
        Multi_Histogram(Coord_Dist_Stats.DistanceMatrix(:),...
        [0,Coord_Dist_Stats.DistanceMax],...
        Coord_Dist_Stats.DistanceBinSize);

    Coord_Dist_Stats.Possible_Distance_Bin_Areas=Coord_Dist_Stats.Possible_Distance_Histogram*Coord_Dist_Stats.PixelArea;

    if any(InputImage(:)~=0)

        if DisplayOn==2
            figure
            set(gcf,'position',[50,50,1400,400])
            subplot(1,3,1),
            imagesc(InputImage),
            axis equal tight,
            colorbar
            hold on
            plot(CenterCoord(2),CenterCoord(1),'*','color','m','markersize',10)
            pause(0.1);
        end
        %if DisplayOn==1
            fprintf('Collecting all distances for ')
        %end
        TotalNumCoords=sum(InputImage(:));
        Coord_Dist_Stats.AllCoords=zeros(TotalNumCoords,2);
        Coord_Dist_Stats.AllCoord_Distances=zeros(TotalNumCoords,1);
        %if DisplayOn==1
            fprintf([num2str(TotalNumCoords),' Coordinates...'])
        %end
        %Coord_Dist_Stats.AllCoords=[];
        %Coord_Dist_Stats.AllCoord_Distances=[];
        if size(InputImage,2)<200
            if DisplayOn==1
                progressbar('Scanning Row','Scanning Column')
            end
            count=0;
            for x=1:size(InputImage,2)
                for y=1:size(InputImage,1)
                    if DisplayOn==1
                        progressbar(x/size(InputImage,2),y/size(InputImage,1))
                    end
                    TempNum=InputImage(y,x);
                    for i=1:TempNum
                        count=count+1;
                        Coord_Dist_Stats.AllCoords(count,:)=[y,x];
                        Coord_Dist_Stats.AllCoord_Distances(count,1)=Coord_Dist_Stats.DistanceMatrix(y,x);
    %                     Coord_Dist_Stats.AllCoords=vertcat(Coord_Dist_Stats.AllCoords,[y,x]);
    %                     Coord_Dist_Stats.AllCoord_Distances=vertcat(Coord_Dist_Stats.AllCoord_Distances,Coord_Dist_Stats.DistanceMatrix(y,x));
                    end
                end
            end
        else
            if ParallelLargeCalc
                parfor x=1:size(InputImage,2)
                    Slice(x).count=0;
                    for y=1:size(InputImage,1)
                        TempNum=InputImage(y,x);
                        for i=1:TempNum
                            Slice(x).count=Slice(x).count+1;
                            Slice(x).AllCoords(Slice(x).count,:)=[y,x];
                            Slice(x).AllCoord_Distances(Slice(x).count,1)=Coord_Dist_Stats.DistanceMatrix(y,x);
                        end
                    end
                end
                count=0;
                for x=1:size(InputImage,2)
                    count=count+Slice(x).count;
                    Coord_Dist_Stats.AllCoords=vertcat(Coord_Dist_Stats.AllCoords,Slice(x).AllCoords);
                    Coord_Dist_Stats.AllCoord_Distances=vertcat(Coord_Dist_Stats.AllCoord_Distances,Slice(x).AllCoord_Distances);
                end
            else
                if DisplayOn==1
                    progressbar('Scanning Row','Scanning Column')
                end
                count=0;
                for x=1:size(InputImage,2)
                    for y=1:size(InputImage,1)
                        if DisplayOn==1
                            progressbar(x/size(InputImage,2),y/size(InputImage,1))
                        end
                        TempNum=InputImage(y,x);
                        for i=1:TempNum
                            count=count+1;
                            Coord_Dist_Stats.AllCoords(count,:)=[y,x];
                            Coord_Dist_Stats.AllCoord_Distances(count,1)=Coord_Dist_Stats.DistanceMatrix(y,x);
        %                     Coord_Dist_Stats.AllCoords=vertcat(Coord_Dist_Stats.AllCoords,[y,x]);
        %                     Coord_Dist_Stats.AllCoord_Distances=vertcat(Coord_Dist_Stats.AllCoord_Distances,Coord_Dist_Stats.DistanceMatrix(y,x));
                        end
                    end
                end
            end
        end
        if count~=TotalNumCoords
            error('Coordinate Mismatch!')
        end
        [   Coord_Dist_Stats.Distance_Mean,...
            Coord_Dist_Stats.Distance_STD,...
            Coord_Dist_Stats.Distance_SEM,...
            Coord_Dist_Stats.NumEntries]=...
            Mean_STD_SEM(Coord_Dist_Stats.AllCoord_Distances);

        [Coord_Dist_Stats.Num_Bins,...
            Coord_Dist_Stats.Bin_Edges,...
            Coord_Dist_Stats.Bin_Labels,...
            Coord_Dist_Stats.Bin_Centers,...
            Coord_Dist_Stats.Histogram,...
            Coord_Dist_Stats.Normalized_Histogram,...
            Coord_Dist_Stats.Cumulative_Histogram,...
            Coord_Dist_Stats.Normalized_Cumulative_Histogram]=...
            Multi_Histogram(Coord_Dist_Stats.AllCoord_Distances,...
            [0,Coord_Dist_Stats.DistanceMax],...
            Coord_Dist_Stats.DistanceBinSize);

        Coord_Dist_Stats.EventDensity=Coord_Dist_Stats.Histogram./Coord_Dist_Stats.Possible_Distance_Bin_Areas;

        [Coord_Dist_Stats.MaxEventDensity,Coord_Dist_Stats.MaxEventDensityBin]=max(Coord_Dist_Stats.EventDensity);
        Coord_Dist_Stats.MaxEventDensity_Pos=Coord_Dist_Stats.Bin_Centers(Coord_Dist_Stats.MaxEventDensityBin);
        Coord_Dist_Stats.HalfMaxEventDensityBin = find(Coord_Dist_Stats.EventDensity >= (Coord_Dist_Stats.MaxEventDensity/2), 1, 'last');
        Coord_Dist_Stats.HalfMaxEventDensity_Pos=Coord_Dist_Stats.Bin_Centers(Coord_Dist_Stats.HalfMaxEventDensityBin);
        [   Coord_Dist_Stats.EventDensity_Mean,...
            Coord_Dist_Stats.EventDensity_STD,...
            Coord_Dist_Stats.EventDensity_SEM,...
            ~]=...
            Mean_STD_SEM(Coord_Dist_Stats.EventDensity);

        Coord_Dist_Stats.AllCoords=uint16(Coord_Dist_Stats.AllCoords);
        Coord_Dist_Stats.AllCoord_Distances=single(Coord_Dist_Stats.AllCoord_Distances);
        Coord_Dist_Stats.DistanceMatrix=single(Coord_Dist_Stats.DistanceMatrix);
        %if DisplayOn==1
            fprintf(['Finished! Found ',num2str(Coord_Dist_Stats.NumEntries),' Entries within the image...\n'])
        %end
        if DisplayOn==2
            subplot(1,3,2)
            plot(Coord_Dist_Stats.Bin_Centers,Coord_Dist_Stats.Histogram,'-')
            ylabel('# Coordinates')
            xlabel('Distance (nm)')

            subplot(1,3,3)
            plot(Coord_Dist_Stats.Bin_Centers,Coord_Dist_Stats.EventDensity,'-')
            ylabel('Coordinate Density')
            xlabel('Distance (nm)')
            pause(0.5);
        end    
    else
        warning on
        warning('No Coordinates found!')


        Coord_Dist_Stats.Possible_Distance_Bin_Areas=Coord_Dist_Stats.Possible_Distance_Histogram*Coord_Dist_Stats.PixelArea;
        Coord_Dist_Stats.AllCoords=[];
        Coord_Dist_Stats.AllCoord_Distances=[];
        Coord_Dist_Stats.Distance_Mean=0;
        Coord_Dist_Stats.Distance_STD=0;
        Coord_Dist_Stats.Distance_SEM=0;
        Coord_Dist_Stats.NumEntries=0;
        Bin_Edges=[0:Coord_Dist_Stats.DistanceBinSize:Coord_Dist_Stats.DistanceMax];
        Num_Bins=length(Bin_Edges)-1;
        for Bin=1:Num_Bins
            if Bin<Num_Bins
                Bin_Labels{Bin}=[num2str(Bin_Edges(Bin)),'<=x<',num2str(Bin_Edges(Bin+1))];
            else
                Bin_Labels{Bin}=[num2str(Bin_Edges(Bin)),'<=x<=',num2str(Bin_Edges(Bin+1))];
            end
            Bin_Centers(Bin)=(Bin_Edges(Bin+1)-Bin_Edges(Bin))/2+Bin_Edges(Bin);
        end
        Coord_Dist_Stats.Num_Bins=Num_Bins;
        Coord_Dist_Stats.Bin_Edges=Bin_Edges;
        Coord_Dist_Stats.Bin_Labels=Bin_Labels;
        Coord_Dist_Stats.Bin_Centers=Bin_Centers;
        Coord_Dist_Stats.Histogram=zeros(size(Coord_Dist_Stats.Possible_Distance_Histogram));
        Coord_Dist_Stats.Normalized_Histogram=zeros(size(Coord_Dist_Stats.Possible_Distance_Histogram));
        Coord_Dist_Stats.Cumulative_Histogram=zeros(size(Coord_Dist_Stats.Possible_Distance_Histogram));
        Coord_Dist_Stats.Normalized_Cumulative_Histogram=zeros(size(Coord_Dist_Stats.Possible_Distance_Histogram));
        Coord_Dist_Stats.EventDensity=zeros(size(Coord_Dist_Stats.Possible_Distance_Histogram));
        Coord_Dist_Stats.MaxEventDensity=0;
        Coord_Dist_Stats.MaxEventDensityBin=0;
        Coord_Dist_Stats.MaxEventDensity_Pos=0;
        Coord_Dist_Stats.HalfMaxEventDensityBin=0;
        Coord_Dist_Stats.HalfMaxEventDensity_Pos=0;
        Coord_Dist_Stats.EventDensity_Mean=0;
        Coord_Dist_Stats.EventDensity_STD=0;
        Coord_Dist_Stats.EventDensity_SEM=0;
        Coord_Dist_Stats.DistanceMatrix=single(Coord_Dist_Stats.DistanceMatrix);

    end
end