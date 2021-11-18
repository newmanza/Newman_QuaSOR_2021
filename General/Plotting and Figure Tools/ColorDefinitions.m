function ColorCode=ColorDefinitions(ColorAbbreviation)
%ColorDefinitions('m')
% [1 1 0]y
% [1 0 1]m
% [0 1 1]c
% [1 0 0]r
% [0 1 0]g
% [0 0 1]b
% [1 1 1]w
% [0 0 0]k
if ischar(ColorAbbreviation)
    BasicColors={'y' 'm' 'c' 'r' 'g' 'b' 'w' 'k'};
    BasicColorCodes={[1 1 0] [1 0 1] [0 1 1] [1 0 0] [0 1 0] [0 0 1] [1 1 1] [0 0 0]};
    ColorCode=[1 1 1];
    for i=1:length(BasicColors)
        if strcmp(BasicColors{i},ColorAbbreviation)
            ColorCode=BasicColorCodes{i};
        end
    end
else
    ColorCode=ColorAbbreviation;
end

end
