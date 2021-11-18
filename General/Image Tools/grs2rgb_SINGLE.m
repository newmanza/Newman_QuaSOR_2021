function res = grs2rgb_SINGLE(img, map)


% Check the arguments
if nargin<1
	error('grs2rgb:missingImage','Specify the name or the matrix of the image');
end;

if ~exist('map','var') || isempty(map)
	map = parula(1024);
end;

[l,w] = size(map);

if w~=3
	error('grs2rgb:wrongColormap','Colormap matrix must contain 3 columns');
end;

if ischar(img)
	a = imread(img);
elseif isnumeric(img)
	a = img;
else
	error('grs2rgb:wrongImageFormat','Image format: must be name or matrix');
end;

% Calculate the indices of the colormap matrix
a = double(a);
a(a==0) = 1; % Needed to produce nonzero index of the colormap matrix
ci = ceil(l*a/max(a(:))); 

% Colors in the new image
[il,iw] = size(a);
r = zeros(il,iw,'single'); 
g = zeros(il,iw,'single');
b = zeros(il,iw,'single');
r(:) = single(map(ci,1));
g(:) = single(map(ci,2));
b(:) = single(map(ci,3));

% New image
res = zeros(il,iw,3,'single');
res(:,:,1) = r; 
res(:,:,2) = g; 
res(:,:,3) = b;
res=single(res);
