figure,
mu = [-0.8 -0.8];
Sigma = [0.8 0; 0 0.8];
X = -4:.1:4; Y = -4:.1:4;
[X1,X2] = meshgrid(X,Y);
Z = mvnpdf([X1(:) X2(:)],mu,Sigma);
Z = reshape(Z,length(Y),length(X));
Z=Z*10000;
grid off
s=surf(X,Y,Z,'FaceColor','interp','EdgeColor','none');
hold on

az=45;
el=50;            view(az, el)

caxis([min(Z(:))-.5*range(Z(:)),max(Z(:))]);
axis([-4 4 -4 4 0 2000])
xlabel('Pixel'); ylabel('Pixel');zlabel('Photons')
AxisLabelSize = 14;
AxisTickSize = 12;


set(get(gca,'ylabel'),'fontsize',AxisLabelSize,'FontName','Arial');

set(get(gca,'ylabel'),'fontsize',AxisLabelSize,'FontName','Arial');

set(gca, 'fontsize',AxisTickSize,'FontName','Arial');
        set(gcf, 'color', 'white');




% Extract X,Y and Z data from surface plot
x=s.XData;
y=s.YData;
z=s.ZData;
% For R2014a and earlier:
% x=get(s,'XData');
% y=get(s,'YData');
% z=get(s,'ZData');
% Create vectors out of surface's XData and YData
x=x(1,:);
y=y(1,:);
% Divide the lengths by the number of lines needed
xnumlines = 8; % 10 lines
ynumlines = 8; % 10 partitions
xspacing = round(length(x)/xnumlines);
yspacing = round(length(y)/ynumlines);
% Plot the mesh lines 
% Plotting lines in the X-Z plane
hold on
for i = 1:yspacing:length(y)
    Y1 = y(i)*ones(size(x)); % a constant vector
    Z1 = z(i,:);
    plot3(x,Y1,Z1,'-k');
end
% Plotting lines in the Y-Z plane
for i = 1:xspacing:length(x)
    X2 = x(i)*ones(size(y)); % a constant vector
    Z2 = z(:,i);
    plot3(X2,y,Z2,'-k');
end
hold off



for k1 = 1:10:size(Z,1)-1
    idxr = 1+fix(k1/10);
    for k2 = 1:10:size(z,2)-1
        idxc = 1+fix(k2/10);
        MF = Z(k1:k1+1,k2:k2+1);        % Matrix Frame (4x4)
        MR(idxr,idxc) = mean(MF(:));
    end
end

figure, imagesc(MR), axis equal tight, 
caxis([min(Z(:))-.5*range(Z(:)),max(Z(:))]);
set(gca,'xtick',[])
set(gca,'ytick',[])
        set(gcf, 'color', 'white');




figure,
mu = [0.5 0.5];
Sigma = [0.8 .3; .3 0.8];
Sigma=1
X = -4:.1:4; Y = -4:.1:4;
[X1,X2] = meshgrid(X,Y);
Z = normpdf([X1(:) X2(:)],mu,Sigma);
Z = reshape(Z,length(Y),length(X));
grid off
s=surf(X,Y,Z,'FaceColor','interp','EdgeColor','none');
hold on
caxis([min(Z(:))-.5*range(Z(:)),max(Z(:))]);
axis([-4 4 -4 4 0 .25])
xlabel('x1'); ylabel('x2'); zlabel('Probability Density');

% Extract X,Y and Z data from surface plot
x=s.XData;
y=s.YData;
z=s.ZData;
% For R2014a and earlier:
% x=get(s,'XData');
% y=get(s,'YData');
% z=get(s,'ZData');
% Create vectors out of surface's XData and YData
x=x(1,:);
y=y(1,:);
% Divide the lengths by the number of lines needed
xnumlines = 8; % 10 lines
ynumlines = 8; % 10 partitions
xspacing = round(length(x)/xnumlines);
yspacing = round(length(y)/ynumlines);
% Plot the mesh lines 
% Plotting lines in the X-Z plane
hold on
for i = 1:yspacing:length(y)
    Y1 = y(i)*ones(size(x)); % a constant vector
    Z1 = z(i,:);
    plot3(x,Y1,Z1,'-k');
end
% Plotting lines in the Y-Z plane
for i = 1:xspacing:length(x)
    X2 = x(i)*ones(size(y)); % a constant vector
    Z2 = z(:,i);
    plot3(X2,y,Z2,'-k');
end
hold off



for k1 = 1:10:size(Z,1)-1
    idxr = 1+fix(k1/10);
    for k2 = 1:10:size(z,2)-1
        idxc = 1+fix(k2/10);
        MF = Z(k1:k1+1,k2:k2+1);        % Matrix Frame (4x4)
        MR(idxr,idxc) = mean(MF(:));
    end
end
figure, imagesc(Z)

figure, imagesc(MR)



