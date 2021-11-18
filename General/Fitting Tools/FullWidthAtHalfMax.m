function [FWHM]=FullWidthAtHalfMax(xdata, ydata)

    % Find the half max value.
    halfMax = (min(ydata) + max(ydata)) / 2;
    % Find where the data first drops below half the max.
    index1 = find(ydata >= halfMax, 1, 'first');
    % Find where the data last rises above half the max.
    index2 = find(ydata >= halfMax, 1, 'last');
    FWHM = index2-index1 + 1; % FWHM in indexes.
    % OR, if you have an x vector
    if ~isempty(xdata)
        FWHM = xdata(index2) - xdata(index1);
    end
end