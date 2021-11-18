               
function DensityScatterOutput=DensityColoring(DensityScatterOutput,map)
    L = size(map,1);
    if isempty(DensityScatterOutput)
        warning on
        warning('No DensityScatterOutput...')
        DensityScatterOutput=[];
    else
        if min(DensityScatterOutput.dd(:))<max(DensityScatterOutput.dd(:))
            DensityScatterOutput.dd_s = round(interp1(linspace(min(DensityScatterOutput.dd(:)),max(DensityScatterOutput.dd(:)),L),1:L,DensityScatterOutput.dd));
            DensityScatterOutput.dd_color = reshape(map(DensityScatterOutput.dd_s,:),[size(DensityScatterOutput.dd_s) 3]); % Make RGB image from scaled.
            DensityScatterOutput.ddf_s = round(interp1(linspace(min(DensityScatterOutput.ddf(:)),max(DensityScatterOutput.ddf(:)),L),1:L,DensityScatterOutput.ddf));
            DensityScatterOutput.ddf_color = reshape(map(DensityScatterOutput.ddf_s,:),[size(DensityScatterOutput.ddf_s) 3]); % Make RGB image from scaled.
        else
            warning('Not enough density differences!')
            DensityScatterOutput.dd_s = round(interp1(linspace(min(DensityScatterOutput.dd(:)),max(DensityScatterOutput.dd(:))+1,L),1:L,DensityScatterOutput.dd));
            DensityScatterOutput.dd_color = reshape(map(DensityScatterOutput.dd_s,:),[size(DensityScatterOutput.dd_s) 3]); % Make RGB image from scaled.
            DensityScatterOutput.ddf_s = round(interp1(linspace(min(DensityScatterOutput.ddf(:)),max(DensityScatterOutput.ddf(:))+1,L),1:L,DensityScatterOutput.ddf));
            DensityScatterOutput.ddf_color = reshape(map(DensityScatterOutput.ddf_s,:),[size(DensityScatterOutput.ddf_s) 3]); % Make RGB image from scaled.
        end
    end
end