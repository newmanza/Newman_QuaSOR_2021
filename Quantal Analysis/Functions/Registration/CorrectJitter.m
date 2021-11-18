% correct jitter in DeltaX
% repeating correction for several iterations, as specified by Jitters.
% e.g. Jitters = [1 2 1] will correct jitters of one image, then two
% images, then one image again

function DeltaXnew = CorrectJitter(DeltaX, Jitters)

DeltaXnew = DeltaX;
LastDelta = length(DeltaX);
LastJitter = length(Jitters);

for JitterIndex=1:LastJitter
    ImagesPerSequence = Jitters(JitterIndex);
    FirstIndex = ImagesPerSequence + 1;
    LastIndex = LastDelta - ImagesPerSequence;

    for Index=FirstIndex:LastIndex
        if(DeltaXnew(Index-ImagesPerSequence) == DeltaXnew(Index+ImagesPerSequence))
            DeltaXnew(Index) = DeltaXnew(Index-ImagesPerSequence);
        end
    end
end