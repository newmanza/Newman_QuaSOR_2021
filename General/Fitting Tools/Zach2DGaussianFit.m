

function FitOutput=Zach2DGaussianFit(S,InitialParams,InterpMethod,FitOrientation,FigDisplay)
    FitOutput=[];
    % 1. 2D Gaussian function ( A requires 5 coefs ).
    g = @(A,X) A(1)*exp( -((X(:,:,1)-A(2)).^2/(2*A(3)^2) + (X(:,:,2)-A(4)).^2/(2*A(5)^2)) );

    % 2. 2D Rotated Gaussian function ( A requires 6 coefs ).
    f = @(A,X) A(1)*exp( -(...
        ( X(:,:,1)*cos(A(6))-X(:,:,2)*sin(A(6)) - A(2)*cos(A(6))+A(4)*sin(A(6)) ).^2/(2*A(3)^2) + ... 
        ( X(:,:,1)*sin(A(6))+X(:,:,2)*cos(A(6)) - A(2)*sin(A(6))-A(4)*cos(A(6)) ).^2/(2*A(5)^2) ) );

    % ---Parameters---
    n = size(S,1); m = size(S,2);         % n x m pixels area/data matrix

    % ---Build numerical Grids---
    % Numerical Grid
    [x,y]=meshgrid(-n/2:n/2,-m/2:m/2);
    X=zeros(m+1,n+1,2);
    X(:,:,1)=x;
    X(:,:,2)=y;

    % High Resolution Grid
    h=10;
    [xh,yh]=meshgrid(-n/2:1/h:n/2,-m/2:1/h:m/2);
    Xh=zeros(h*m+1,h*n+1,2);
    Xh(:,:,1)=xh; Xh(:,:,2)=yh;

    S1=zeros(size(S,1)+1,size(S,2)+1);
    S1(1:size(S,1),1:size(S,2))=S;

    % ---Fit---
    % Define lower and upper bounds [Amp,xo,wx,yo,wy,fi]
    lb = [0,-n/2,0,-n/2,0,0];
    ub = [realmax('double'),n/2,(n/2)^2,n/2,(n/2)^2,pi/4];

    % Fit sample data
    switch FitOrientation
        case 'dont', [A,resnorm,res,flag,output] = lsqcurvefit(g,InitialParams(1:5),X,S1,lb(1:5),ub(1:5));
        case 'fit',  [A,resnorm,res,flag,output] = lsqcurvefit(f,InitialParams,X,S1,lb,ub);
        otherwise, error('invalid entry');
    end
    if FigDisplay
        disp(output); % display summary of LSQ algorithm
    end
    % ---Plot Data---
    % Plot 3D Data and Fitted curve
    if FigDisplay
        hf1=figure;
        set(hf1,'Position',[800 200 1000 500]); 
    end
    if FigDisplay
        switch FitOrientation
            case 'dont'
                s1=subplot(1,2,1);
                C=del2(g(A,Xh));
                mesh(xh,yh,g(A,Xh),C);
                hold on
                s2=subplot(1,2,2);
                imagesc(g(A,Xh))
                axis equal tight

            case 'fit'
                s1=subplot(1,2,1);
                C=del2(f(A,Xh));
                mesh(xh,yh,f(A,Xh),C);
                hold on
                s2=subplot(1,2,2);
                imagesc(f(A,Xh))
                axis equal tight
        end
    end
    if FigDisplay
        axes(s1);
        surface(x,y,S1,'EdgeColor','none');
        alpha(0.5); 
        colormap('hot');
        view(-60,20);
        grid on;
        hold off
    end
    % Plot Sample Pixels data
    if FigDisplay
        hf2=figure; 
        set(hf2,'Position',[100 100 800 800]); 
        subplot(4,4,[5,6,7,9,10,11,13,14,15]);
        imagesc(x(1,:),y(:,1),S1); 
        colormap('hot');

        % Output and compare data and fitted function coefs
        text(-n/2-5,m/2+5.0,sprintf('\t Amplitude \t X-Coord \t X-Width \t Y-Coord \t Y-Width \t Angle'),'Color','black');
        text(-n/2-5,m/2+6.2,sprintf('Fit \t %1.3f \t %1.3f \t %1.3f \t %1.3f \t %1.3f \t %1.3f',A),'Color','red');
    end
    % Plot vertical and horizontal axis
    vx_h=x(1,:); vy_v=y(:,1);
    switch FitOrientation
        case 'fit', M=-tan(A(6));
            % generate points along _horizontal & _vertical axis
            vy_h=M*(vx_h-A(2))+A(4);
            hPoints = interp2(x,y,S1,vx_h,vy_h,InterpMethod);
            vx_v=M*(A(4)-vy_v)+A(2);
            vPoints = interp2(x,y,S1,vx_v,vy_v,InterpMethod);
        case 'dont', A(6)=0; 
            % generate points along _horizontal & _vertical axis
            vy_h=A(4)*ones(size(vx_h));
            hPoints = interp2(x,y,S1,vx_h,vy_h,InterpMethod);
            vx_v=A(2)*ones(size(vy_v));
            vPoints = interp2(x,y,S1,vx_v,vy_v,InterpMethod);
    end
    if FigDisplay
        % plot lines 
        hold on; plot(A(2),A(4),'+b',vx_h,vy_h,'.r',vx_v,vy_v,'.g'); hold off;
    end
    % Plot cross sections 
    dmin=1.1*min(S1(:));
    xfit=xh(1,:);
    hfit=A(1)*exp(-(xfit-A(2)).^2/(2*A(3)^2));
    dmax=1.1*max(S1(:));
    yfit=yh(:,1);
    vfit=A(1)*exp(-(yfit-A(4)).^2/(2*A(5)^2));
    if FigDisplay
        subplot(4,4,[1,2,3]); xposh = (vx_h-A(2))/cos(A(6))+A(2); 
        plot(xposh,hPoints,'r.',xfit,hfit,'black'); grid on; axis([-n/2,n/2,dmin,dmax]);
        subplot(4,4,[8,12,16]); xposv = (vy_v-A(4))/cos(A(6))+A(4); 
        plot(vPoints,xposv,'g.',vfit,yfit,'black'); grid on; axis([dmin,dmax,-m/2,m/2]); 
        set(gca,'YDir','reverse');
    end
    
    FitOutput.g=g;
    FitOutput.f=f;
    FitOutput.A=A;
    FitOutput.dmin=dmin;
    FitOutput.xfit=xfit;
    FitOutput.hfit=hfit;
    FitOutput.dmax=dmax;
    FitOutput.yfit=yfit;
    FitOutput.vfit=vfit;
    FitOutput.h=h;
    FitOutput.FitImage=f(A,X);
    FitOutput.FitImage=FitOutput.FitImage(1:n,1:m);
    FitOutput.FitHighResImage=f(A,Xh);
    FitOutput.FitHighResImage=FitOutput.FitHighResImage(1:n,1:m);

end