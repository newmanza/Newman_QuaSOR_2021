function Stack_Writer(ExportArray)

FileDir=cd
FileName=SaveName
ExportArray=uint16(Reference_Data_3D_MeanProj_Reg);
imwrite(ExportArray(:,:,1),[CurrentSaveDir,SaveName,'Reg Ref Stack','.tif'])
for z=2:size(ExportArray,3)
imwrite(ExportArray(:,:,z),[CurrentSaveDir,SaveName,'Reg Ref Stack','.tif'],'WriteMode','append')
end


fiji_descr = ['ImageJ=1.52p' newline ...
            'images=' num2str(size(ExportArray,3)) newline... 
            'slices=' num2str(size(ExportArray,3)) newline...
            'hyperstack=true' newline...
            'mode=grayscale' newline...  
            'loop=false' newline...  
            'min=0.0' newline...      
            'max=65535.0'];  % change this to 256 if you use an 8bit image
            
t = Tiff(['Test','.tif'],'w');
tagstruct.ImageLength = size(ExportArray,1);
tagstruct.ImageWidth = size(ExportArray,2);
tagstruct.RowsPerStrip=size(ExportArray,1);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.ImageDescription = fiji_descr;
for slice = 1:size(ExportArray,3)
t.setTag(tagstruct)
    t.write(ExportArray(:,:,slice));
t.writeDirectory(); % saves a new page in the tiff file
end
t.close() 



fiji_descr = ['ImageJ=1.52p' newline ...
            'images=' num2str(size(ExportArray,3)*...
                              size(ExportArray,4)*...
                              size(ExportArray,5)) newline... 
            'channels=' num2str(size(ExportArray,4)) newline...
            'slices=' num2str(size(ExportArray,3)) newline...
            'frames=' num2str(size(ExportArray,5)) newline... 
            'hyperstack=true' newline...
            'mode=grayscale' newline...  
            'loop=false' newline...  
            'min=0.0' newline...      
            'max=65535.0'];  % change this to 256 if you use an 8bit image
            
t = Tiff(['Test','.tif'],'w');

        tagstruct.ImageLength = size(ExportArray,1);
tagstruct.ImageWidth = size(ExportArray,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.RowsPerStrip=size(ExportArray,1);
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.ImageDescription = fiji_descr;
for frame = 1:1
    for slice = 1:1
        for slice = 1:size(ExportArray,3)
            t.setTag(tagstruct)
            t.write(im2uint16(ExportArray(:,:,slice)));
            t.writeDirectory(); % saves a new page in the tiff file
        end
    end
end
t.close() 


% fiji_descr = ['ImageJ=1.52p' newline ...
%             'images=' num2str(size(ExportArray,3)*...
%                               size(ExportArray,4)*...
%                               size(ExportArray,5)) newline... 
%             'channels=' num2str(size(ExportArray,3)) newline...
%             'slices=' num2str(size(ExportArray,4)) newline...
%             'frames=' num2str(size(ExportArray,5)) newline... 
%             'hyperstack=true' newline...
%             'mode=grayscale' newline...  
%             'loop=false' newline...  
%             'min=0.0' newline...      
%             'max=65535.0'];  % change this to 256 if you use an 8bit image
%             
% t = Tiff([FileDir,FileName,'.tif','w');
% tagstruct.ImageLength = size(ExportArray,1);
% tagstruct.ImageWidth = size(ExportArray,2);
% tagstruct.RowsPerStrip=size(ExportArray,1);
% tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
% tagstruct.BitsPerSample = 16;
% tagstruct.SamplesPerPixel = 1;
% tagstruct.Compression = Tiff.Compression.None;
% tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
% tagstruct.ImageDescription = fiji_descr;
% for frame = 1:size(ExportArray,5)
%     for slice = 1:size(ExportArray,4)
%         for channel = 1:size(ExportArray,3)
%             t.setTag(tagstruct)
%             t.write(im2uint16(ExportArray(:,:,channel,slice,frame)));
%             t.writeDirectory(); % saves a new page in the tiff file
%         end
%     end
% end
% t.close() 
% 

end