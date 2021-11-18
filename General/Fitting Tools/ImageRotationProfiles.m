function [AllProfiles,AllProfiles_Mean,AllProfiles_STD,AllProfiles_SEM]=...
            ImageRotationProfiles(TempImage,CenterCoord,ProfileCoords,DegreeInterval,DegreeRange,RotationMethod)
    AllProfiles=[];
    for theta=1:length(DegreeRange)
        TempAllProfiles(theta).Profile=[];
    end
%     p = gcp('nocreate');
%     if isempty(p)
        for theta=1:length(DegreeRange)
            TempImage1=imrotate(TempImage,DegreeRange(theta),RotationMethod,'crop');
            TempAllProfiles(theta).Profile=TempImage1(CenterCoord(2),ProfileCoords);
            clear TempImage1
        end
%     else
%         parfor theta=1:length(DegreeRange)
%             TempImage1=imrotate(TempImage,DegreeRange(theta),RotationMethod,'crop');
%             TempAllProfiles(theta).Profile=TempImage1(CenterCoord(2),ProfileCoords);
%             %clear TempImage1
%         end
%     end
    for theta=1:length(DegreeRange)
        AllProfiles(theta,:)=TempAllProfiles(theta).Profile;
    end
    [   AllProfiles_Mean,...
        AllProfiles_STD,...
        AllProfiles_SEM,~]=...
        Mean_STD_SEM(AllProfiles);

end