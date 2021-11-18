fprintf('Generating Full Export Stack...')
ExportStack=zeros(stackSizeX,stackSizeY,NumSlices,NumChannels,1,'uint16');

for c=1:NumChannels
    for z=1:NumSlices
        TempImage=Channel(c).RawData_Filtered(:,:,z);
        %%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%
        TempImage=imrotate(TempImage,90);
        ExportStack(:,:,z,c,1)=TempImage;
    end
end
fprintf('Finished!\n')
clear ExportStack_MetaData
ExportStack_MetaData = createMinimalOMEXMLMetadata(ExportStack,'XYZCT');
bfsave(ExportStack, [ScratchDir,'Test.ome.tiff']);

bfsave(ExportStack, [ScratchDir,'Test.ome.tiff'],'metadata', ExportStack_MetaData);




pixelSize = ome.units.quantity.Length(java.lang.Double(MetaData.ScaleFactor), ome.units.UNITS.MICROMETER);
ExportStack_MetaData.setPixelsPhysicalSizeX(pixelSize, 0);
ExportStack_MetaData.setPixelsPhysicalSizeY(pixelSize, 0);
pixelSizeZ = ome.units.quantity.Length(java.lang.Double(MetaData.PlaneSpacing), ome.units.UNITS.MICROMETER);
ExportStack_MetaData.setPixelsPhysicalSizeZ(pixelSizeZ, 0);


ExportStack_MetaData.setPixelsPhysicalSizeX(0.05, 0);


bfsave(ExportStack, [ScratchDir,'Test.ome.tiff'],'metadata', ExportStack_MetaData);


plane = zeros(64, 64, 1, 2, 2, 'uint8');
metadata = createMinimalOMEXMLMetadata(plane);
pixelSize = metadata.units.quantity.Length(java.lang.Double(.05), OME.units.UNITS.MICROMETER);
metadata.setPixelsPhysicalSizeX(pixelSize, 0);
metadata.setPixelsPhysicalSizeY(pixelSize, 0);
pixelSizeZ = ome.units.quantity.Length(java.lang.Double(.2), ome.units.UNITS.MICROMETER);
metadata.setPixelsPhysicalSizeZ(pixelSizeZ, 0);
bfsave(plane, 'metadata.ome.tiff', 'metadata', metadata);








clear ExportStack_MetaData

ExportStack_Structure = Tiff([ScratchDir,'Test.tif'],'w');
ExportStack_MetaData.ImageLength = stackSizeX;
ExportStack_MetaData.ImageWidth = stackSizeY;
ExportStack_MetaData.Photometric = Tiff.Photometric.MinIsBlack;
ExportStack_MetaData.BitsPerSample = 16;
ExportStack_MetaData.SamplesPerPixel = 1;
ExportStack_MetaData.RowsPerStrip = 16;
ExportStack_MetaData.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
ExportStack_MetaData.Software = 'MATLAB';
ExportStack_MetaData % display ExportStack_MetaData
setTag(ExportStack_Structure,ExportStack_MetaData)
write(ExportStack_Structure,ExportStack(:,:,15,2));
close(ExportStack_Structure);






fprintf('Generating Full Export Stack...')
ExportStack=zeros(stackSizeX,stackSizeY,NumChannels,NumSlices,1,'uint16');

for c=1:NumChannels
    for z=1:NumSlices
        TempImage=Channel(c).RawData_Filtered(:,:,z);
        %%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%
        TempImage=imrotate(TempImage,90);
        ExportStack(:,:,c,z,1)=TempImage;
    end
end
clear TestStack
TestStack(:,:,:)=ExportStack(:,:,2,:,1);

fprintf('Finished!\n')
hyperstack_write([ScratchDir,'Test.tif'], single(ExportStack))

hyperstack=(ExportStack);
file=[ScratchDir,'Test.tif'];
% get all five dimensions
d = zeros(5, 1);
for i = 1 : 5
    d(i) = size(hyperstack, i);
end
clear s
% assemble image description
s = sprintf('ImageJ=1.51\nnimages=%d\nchannels=%d\nslices=%d\nframes=%d\nhyperstack=true\nmode=color\nloop=false\nmin=%.1f\nmax=%.1f\n',...
    prod(d(3:5)), d(3), d(4), d(5), floor(min(hyperstack(:))*10)/10, ceil(max(hyperstack(:))*10)/10);
s = sprintf('ImageJ=1.51\nnimages=%d\nchannels=%d\nslices=%d\nframes=%d\nhyperstack=true\nmode=color\nloop=false\nmin=%.1f\nmax=%.1f\n',...
    prod(d(3:5)), d(3), d(4), d(5), 0, 2^16-1);
s = sprintf('ImageJ=1.51\nnimages=%d\nchannels=%d\nslices=%d\nframes=%d\nhyperstack=true\nmode=color\nloop=true\nmin=%.1f\nmax=%.1f\n',...
    prod(d(3:5)), d(3), d(4), d(5), 0, 500);

% open tif file for writing and set file tags
t = Tiff(file, 'w');
clear ts
ts.ImageLength = d(1);
ts.ImageWidth = d(2);
ts.Photometric = Tiff.Photometric.MinIsBlack;
ts.Compression = Tiff.Compression.None;
ts.BitsPerSample = 16;
ts.SamplesPerPixel = 1;
ts.SampleFormat = Tiff.SampleFormat.UInt;
%ts.RowsPerStrip = 5;
ts.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
ts.Software = 'MATLAB';
ts.ImageDescription = s;

% loop over dimensions 3, 4, and 5
fprintf('Writing Image to file...')
% figure, hold on
k = 1 ;
    for j = 1 : d(4)
        for i = 1 : d(3)
            frame = hyperstack(:, :, i, j, k);
%             clf
%             imagesc(frame),axis equal tight
%             pause(0.1)
            t.setTag(ts)            
            t.write(frame);
            t.writeDirectory();
        end
    end

% close tif file
t.close();
fprintf('Finished!\n')



imp = ijmshow(ExportStack,'XYCZT') % I is 5D array of uint8 or uint16


addpath 'C:\Fiji.app\scripts\' % depends your Fiji installation
ImageJ(0)
imp = copytoImagePlus(ExportStack,'YXCZT')
imp = ijmshow(ExportStack,'YXCZT') % I is 5D array of uint8 or uint16
% the second argument determines which dimension represents what
% imp is a 5D hyperstack

ij.IJ.saveAsTiff(imp, 'image1.tif');


