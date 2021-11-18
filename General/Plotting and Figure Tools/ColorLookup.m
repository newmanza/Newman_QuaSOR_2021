function ColorAbbreviation=ColorLookup(ColorCode)
%ColorDefinitions('m')
% [1 1 0]y
% [1 0 1]m
% [0 1 1]c
% [1 0 0]r
% [0 1 0]g
% [0 0 1]b
% [1 1 1]w
% [0 0 0]k

BasicColors={'y' 'm' 'c' 'r' 'g' 'b' 'w' 'k'};
BasicColorCodes={[1 1 0] [1 0 1] [0 1 1] [1 0 0] [0 1 0] [0 0 1] [1 1 1] [0 0 0]};
ColorAbbreviation=NaN;
    for i=1:length(BasicColorCodes)
        if any(BasicColorCodes{i}~=ColorCode)
        else
            ColorAbbreviation=BasicColors{i};
        end
    end
end
