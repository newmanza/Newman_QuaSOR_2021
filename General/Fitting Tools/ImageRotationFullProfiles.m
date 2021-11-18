function RotatedFullProfile=ImageRotationFullProfiles(TestImage,FullProfileAngles,RotateMethod,PixelLine_Full_XCoords,PixelLine_Full_YCoords)
    TestImage=single(TestImage);
    for angle=1:length(FullProfileAngles)
        TempAllProfiles(angle).TempProfile=zeros(size(PixelLine_Full_XCoords));
    end
    parfor angle=1:length(FullProfileAngles)
        TestImageRot=imrotate(double(TestImage),FullProfileAngles(angle),RotateMethod,'crop');
        for pixel=1:length(PixelLine_Full_XCoords)
            TempAllProfiles(angle).TempProfile(pixel)=TestImageRot(PixelLine_Full_YCoords(pixel),PixelLine_Full_XCoords(pixel));
        end
    end
    RotatedFullProfile=zeros(length(FullProfileAngles),length(PixelLine_Full_XCoords));
    for angle=1:length(FullProfileAngles)
        RotatedFullProfile(angle,:)=TempAllProfiles(angle).TempProfile;
    end
    RotatedFullProfile=double(RotatedFullProfile);
end