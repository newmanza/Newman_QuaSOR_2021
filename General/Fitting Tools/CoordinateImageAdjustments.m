function OutputImage=CoordinateImageAdjustments(InputImage,TranslationParams,RotationAngle)

%     InputImage=TestImage;
%     TranslationParams=[Grouped_Data(RecordingNum).Verified_Quantifications.STORM_AZ_Struct_AZ_Domain_AlignmentParams(Pair).ChannelData(Rotate_Centering_Channel(ClassIndex)).Offset(1),...
%                                 Grouped_Data(RecordingNum).Verified_Quantifications.STORM_AZ_Struct_AZ_Domain_AlignmentParams(Pair).ChannelData(Rotate_Centering_Channel(ClassIndex)).Offset(2)],...
%               
%     RotationAngle=Grouped_Data(RecordingNum).Verified_Quantifications.STORM_AZ_Struct_AZ_Domain_AlignmentParams(Pair).Rotate_Angle
%     
    fprintf('Extracting Coordinates...')
    AllCoords=[];
    for x=1:size(InputImage,2)
        for y=1:size(InputImage,1)
            TempNum=InputImage(y,x);
            for i=1:TempNum
                AllCoords=vertcat(AllCoords,[y,x]);
            end
        end
    end
    OutputImage=zeros(size(InputImage));
    fprintf([num2str(size(AllCoords,1)),' Coords...'])
    if size(AllCoords,1)>0
        fprintf('Translating...')     
        AllCoords(:,1)=AllCoords(:,1)+TranslationParams(2);
        AllCoords(:,2)=AllCoords(:,2)+TranslationParams(1);
        if ~exist('RotationAngle')
            RotationAngle=0;
        end

        if ~isempty(RotationAngle)
            if RotationAngle~=0
                fprintf('Rotating...')     
                RotationAngle_rad=deg2rad(RotationAngle)*-1;
                R = [cos(RotationAngle_rad) -sin(RotationAngle_rad); sin(RotationAngle_rad) cos(RotationAngle_rad)];
                Max_Rot_Size=max(size(InputImage));
                Rot_XSize=size(InputImage,2);
                Rot_YSize=size(InputImage,1);
                xdiff=(Rot_XSize-size(InputImage,2))/2;
                ydiff=(Rot_YSize-size(InputImage,1))/2;
                x_center_rot = size(InputImage,2)/2;
                y_center_rot = size(InputImage,1)/2;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                v = [AllCoords(:,2)';AllCoords(:,1)'];
                center = repmat([x_center_rot; y_center_rot], 1, length(AllCoords));
                s = v - center;     % shift points in the plane so that the center of rotation is at the origin
                so = R*s;           % apply the rotation about the origin
                vo = so + center;   % shift again so the origin goes back to the desired center of rotation
                x_rotated = vo(1,:);
                y_rotated = vo(2,:);
                AllCoords_Rotated=[y_rotated-ydiff;x_rotated-xdiff]';
            else
                AllCoords_Rotated=AllCoords;
            end
        else
            AllCoords_Rotated=AllCoords;
        end
        AllCoords_Rotated=round(AllCoords_Rotated);
        fprintf('Reconstructing...')    
        for i=1:size(AllCoords_Rotated,1)
            if AllCoords_Rotated(i,1)>0&&AllCoords_Rotated(i,2)>0&&AllCoords_Rotated(i,1)<=size(InputImage,1)&&AllCoords_Rotated(i,2)<=size(InputImage,2)
                OutputImage(AllCoords_Rotated(i,1),AllCoords_Rotated(i,2))=OutputImage(AllCoords_Rotated(i,1),AllCoords_Rotated(i,2))+1;
            end
        end
    else
    end
    fprintf('Finished!\n')
end