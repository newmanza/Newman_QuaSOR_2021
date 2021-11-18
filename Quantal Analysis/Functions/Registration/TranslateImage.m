function OffsetImage = TranslateImage(Image, DeltaY, DeltaX)

% does not work if Image contains NaN
% to get rid of NaNs:
Image(isnan(Image)) = 0;

% the translation
se = translate(strel(1), [DeltaY DeltaX]);
OffsetImage = imdilate(Image, se);