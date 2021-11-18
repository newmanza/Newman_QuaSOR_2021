GaussTestFig=figure;
set(GaussTestFig,'position',[100,100,1700,800]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AreaSize=100;
Amp=1;
mu1 = [30 30];
Sigma1 = [  50   20; 
            20   50];
% Sigma = [Variance1, Covariance1;
%         Covariance1, Variance2]
%         Covariance must be equal
%         VarDiff is used in fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
InterpolationMethod = 'nearest'; % 'nearest','linear','spline','cubic'
x = 1:AreaSize; y = 1:AreaSize;
[X,Y] = meshgrid(x,y);
F1 = mvnpdf([X(:) Y(:)],mu1,Sigma1);
F1 = reshape(F1,length(y),length(x));
F1=(F1/max(F1(:)))*Amp;
subplot(1,2,1)
imagesc(F1)
axis equal tight
colorbar
subplot(1,2,2)
surf(F1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Region settings
% SOQA_Parameters(1).RegionSplitting_Threshold=0.05; %Apply a stricter threshold to the initial region finding CorrAmp map to get more smaller regions, will need to adjust for different inputs/amplitudes
% SOQA_Parameters(1).RegionSplitting_Threshold_Increase=0.05;
% SOQA_Parameters(1).Max_Region_Area=800; %in pixels will split by increasing the starting threshold value
% SOQA_Parameters(1).Min_Region_Area=15; %Lower for Ib?
% SOQA_Parameters(1).RegionEdge_Padding=2; %pixels to increase the size of the
% SOQA_Parameters(1).SuppressBorder=1; %Can avoid any matches too close to the border, shouldnt be a problem anymore but probably safer
% SOQA_Parameters(1).SuppressBorderSize=2;%in pixels
% SOQA_Parameters(1).SuppressBorderRatio=0.8;%how much to suppress edge pixel values
% 
% %Replicate/components nandling
% SOQA_Parameters(1).NumReplicates=20;%Initial number of complete runs through progressing numbers of components
% SOQA_Parameters(1).MaxNumGaussians=1;%Initial number of components to test per window can set differently for different inputs
% SOQA_Parameters(1).ReplicateIncrease=10; %The number of test fits will increase as the number of components increases
% SOQA_Parameters(1).MaxAllowed_NumReplicates=200;%To prevent too many tests
% SOQA_Parameters(1).MaxAllowed_NumGaussians=2;%to prevent too many fits.  with very large regions this would need to be increased
% SOQA_Parameters(1).MaxAllowed_NumResets=1;%if no good fits are found it will restart after adjusting parameters
% SOQA_Parameters(1).Repeat_Amp_Threshold=0.1;
% 
% %GMM Settings
% SOQA_Parameters(1).Check_Prior_Frame_Fit=0;%This option will allow the script to check for conditions that would allow the frame prior to the peak frame to be used for fitting, probably most useful in Is where spots spread rapidly
% SOQA_Parameters(1).Check_Prior_Frame_Limits=[0.3,0.8];%Will trigger an alternative image if the frame before the TemplatePeakPosition is within this range.
% SOQA_Parameters(1).FitFiltered=0;%uses filtered data for the primary analysis, I would rather not have to use this but it seems to work better and less errors
% SOQA_Parameters(1).TestFiltered=0;%use a filtered test image for the 2d correlation testing procedure to avoid noise triggering more fits
% SOQA_Parameters(1).FilterSize=5;%Filter the TestImage, gaussian, might be bad prior to gaussian fitting, data was intially gaussian filtered once
% SOQA_Parameters(1).FilterSigma=1;
% SOQA_Parameters(1).MinDistance=10;%helps avoid double matches right on top of one another but might be good
% SOQA_Parameters(1).PenalizeMoreComponents=1;%Will try to supress fits that have more components
% SOQA_Parameters(1).NumCompPenalty=-0.3;%how much to scale the 
% SOQA_Parameters(1).RegularizationValue=1e-6;%will keep the function converging and not going off to infinity
% SOQA_Parameters(1).Minimum_Peak_Amplitude=0.04;
% SOQA_Parameters(1).Corr_Score_Scalar=3;
% 
% %Mini-based Weighting Settings
% % SynapGCaMP6 Minis Ib Boutons
% % Amp Mean: 0.44989 STD: 0.37106
% % Variance Mean: 7.8505 STD: 3.5213
% % Variance Diff Mean: 2.3381 STD: 2.2767
% % Covariance Mean: -0.1273 STD: 1.7553
% SOQA_Parameters(1).AmpXData = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3];
% SOQA_Parameters(1).Amp_Norm_Hist = [0.7185, 1, 0.92279, 0.87882, 0.71153, 0.55818, 0.42145, 0.31957, 0.24665, 0.18874, 0.14263, 0.10509, 0.078284, 0.057373, 0.046113, 0.034853, 0.026273, 0.021984, 0.017694, 0.012869, 0.010724, 0.0085791, 0.0053619, 0.0037534, 0.0037534, 0.002681, 0.0016086, 0.0010724, 0.0010724, 0, 0];
% SOQA_Parameters(1).Amp_Score_Shift=0;
% SOQA_Parameters(1).Amp_Score_Scalar=1;
% 
% SOQA_Parameters(1).VarHistXData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
% SOQA_Parameters(1).Variance_Norm_Hist = [0, 0.029842, 0.25878, 0.45304, 0.67365, 0.89054, 0.98885, 1, 0.91757, 0.78209, 0.62872, 0.47601, 0.35709, 0.26385, 0.20101, 0.13682, 0.1, 0.069595, 0.056081, 0.036149, 0.020608, 0.016216, 0.0125, 0.0084459, 0.0054054, 0.0043919, 0.0030405, 0.0016892, 0.0010135, 0.0016892, 0.0016892];
% SOQA_Parameters(1).Var_Score_Shift=0;
% SOQA_Parameters(1).Var_Score_Scalar=1;
% 
% SOQA_Parameters(1).VarDiffXData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
% SOQA_Parameters(1).Variance_Difference_Norm_Hist = [0.75183, 1, 0.80085, 0.69951, 0.46024, 0.29159, 0.17927, 0.10427, 0.058537, 0.038049, 0.023049, 0.016463, 0.012439, 0.01061, 0.0065854, 0.0047561, 0.0032927, 0.002561, 0.0014634, 0.0018293, 0.0018293];
% SOQA_Parameters(1).Var_Diff_Score_Shift=0;
% SOQA_Parameters(1).Var_Diff_Score_Scalar=2;
% 
% SOQA_Parameters(1).CovHistXData = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10];
% SOQA_Parameters(1).Covariance_Norm_Hist = [1, 0.45299, 0.29255, 0.096947, 0.056777, 0.02906, 0.015873, 0.010745, 0.0070818, 0.004884, 0.003663, 0.0026862, 0.0020757, 0.0017094, 0.0017094, 0.0019536, 0.0015873, 0.0013431, 0.0014652, 0.001221, 0.002442];
% SOQA_Parameters(1).Cov_Score_Shift=0;
% SOQA_Parameters(1).Cov_Score_Scalar=1.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %CpxRNAi
% %Region settings
% SOQA_Parameters(7).RegionSplitting_Threshold=0.05; %Apply a stricter threshold to the initial region finding CorrAmp map to get more smaller regions, will need to adjust for different inputs/amplitudes
% SOQA_Parameters(7).RegionSplitting_Threshold_Increase=0.05;
% SOQA_Parameters(7).Max_Region_Area=600; %in pixels will split by increasing the starting threshold value
% SOQA_Parameters(7).Min_Region_Area=15; %Lower for Ib?
% SOQA_Parameters(7).RegionEdge_Padding=2; %pixels to increase the size of the
% SOQA_Parameters(7).SuppressBorder=1; %Can avoid any matches too close to the border, shouldnt be a problem anymore but probably safer
% SOQA_Parameters(7).SuppressBorderSize=2;%in pixels
% SOQA_Parameters(7).SuppressBorderRatio=0.8;%how much to suppress edge pixel values
% 
% %Replicate/components nandling
% SOQA_Parameters(7).NumReplicates=20;%Initial number of complete runs through progressing numbers of components
% SOQA_Parameters(7).MaxNumGaussians=6;%Initial number of components to test per window can set differently for different inputs
% SOQA_Parameters(7).ReplicateIncrease=10; %The number of test fits will increase as the number of components increases
% SOQA_Parameters(7).MaxAllowed_NumReplicates=200;%To prevent too many tests
% SOQA_Parameters(7).MaxAllowed_NumGaussians=4;%to prevent too many fits.  with very large regions this would need to be increased
% SOQA_Parameters(7).MaxAllowed_NumResets=1;%if no good fits are found it will restart after adjusting parameters
% SOQA_Parameters(7).Repeat_Amp_Threshold=0.1;
% SOQA_Parameters(7).RunInParallelMode=2;%new method is very different, currently the non-parallel mode is not a default option
% 
% %GMM Settings
% SOQA_Parameters(7).Check_Prior_Frame_Fit=0;%This option will allow the script to check for conditions that would allow the frame prior to the peak frame to be used for fitting, probably most useful in Is where spots spread rapidly
% SOQA_Parameters(7).Check_Prior_Frame_Limits=[0.3,0.8];%Will trigger an alternative image if the frame before the TemplatePeakPosition is within this range.
% SOQA_Parameters(7).FitFiltered=0;%uses filtered data for the primary analysis, I would rather not have to use this but it seems to work better and less errors
% SOQA_Parameters(7).TestFiltered=0;%use a filtered test image for the 2d correlation testing procedure to avoid noise triggering more fits
% SOQA_Parameters(7).FilterSize=5;%Filter the TestImage, gaussian, might be bad prior to gaussian fitting, data was intially gaussian filtered once
% SOQA_Parameters(7).FilterSigma=1;
% SOQA_Parameters(7).MinDistance=7;%helps avoid double matches right on top of one another but might be good
% SOQA_Parameters(7).PenalizeMoreComponents=1;%Will try to supress fits that have more components
% SOQA_Parameters(7).NumCompPenalty=-0.3;%-0.15;%how much to scale the 
% SOQA_Parameters(7).ProbabilityTolerance=1e-9;%not used right now
% SOQA_Parameters(7).InternalReplicates=1;%how many replicates each fitgmdist call runs, it will pick the best fit from each run with the largest liklihood
% SOQA_Parameters(7).GMDistFitOptions=statset;
% SOQA_Parameters(7).GMDistFitOptions.Display='off';
% SOQA_Parameters(7).GMDistFitOptions.MaxIter=10;%To get different options keep this low
% SOQA_Parameters(7).GMDistFitOptions.TolFun=1e-6;%not sure but not used yet
% SOQA_Parameters(7).StartCondition='randSample';%eventually I would like to guide fitting here
% SOQA_Parameters(7).RegularizationValue=1e-6;%will keep the function converging and not going off to infinity
% SOQA_Parameters(7).Minimum_Peak_Amplitude=0.15;%0.035;
% SOQA_Parameters(7).Minimum_Peak_Amplitude_IndexDelta=-0.0025;
% SOQA_Parameters(7).Corr_Score_Scalar=3;
% 
% %Mini-based Weighting Settings
% % SynapGCaMP6 Minis Ib Boutons
% % Amp Mean: 0.44989 STD: 0.37106
% % Variance Mean: 7.8505 STD: 3.5213
% % Variance Diff Mean: 2.3381 STD: 2.2767
% % Covariance Mean: -0.1273 STD: 1.7553
% SOQA_Parameters(7).AmpXData = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3];
% SOQA_Parameters(7).Amp_Norm_Hist = [0.7185, 1, 0.92279, 0.87882, 0.71153, 0.55818, 0.42145, 0.31957, 0.24665, 0.18874, 0.14263, 0.10509, 0.078284, 0.057373, 0.046113, 0.034853, 0.026273, 0.021984, 0.017694, 0.012869, 0.010724, 0.0085791, 0.0053619, 0.0037534, 0.0037534, 0.002681, 0.0016086, 0.0010724, 0.0010724, 0, 0];
% SOQA_Parameters(7).Amp_Score_Shift=0;
% SOQA_Parameters(7).Amp_Score_Scalar=0.5;%1;
% 
% SOQA_Parameters(7).VarHistXData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
% SOQA_Parameters(7).Variance_Norm_Hist = [0, 0.029842, 0.25878, 0.45304, 0.67365, 0.89054, 0.98885, 1, 0.91757, 0.78209, 0.62872, 0.47601, 0.35709, 0.26385, 0.20101, 0.13682, 0.1, 0.069595, 0.056081, 0.036149, 0.020608, 0.016216, 0.0125, 0.0084459, 0.0054054, 0.0043919, 0.0030405, 0.0016892, 0.0010135, 0.0016892, 0.0016892];
% SOQA_Parameters(7).Var_Score_Shift=0;
% SOQA_Parameters(7).Var_Score_Scalar=2;%1;
% 
% SOQA_Parameters(7).VarDiffXData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
% SOQA_Parameters(7).Variance_Difference_Norm_Hist = [0.75183, 1, 0.80085, 0.69951, 0.46024, 0.29159, 0.17927, 0.10427, 0.058537, 0.038049, 0.023049, 0.016463, 0.012439, 0.01061, 0.0065854, 0.0047561, 0.0032927, 0.002561, 0.0014634, 0.0018293, 0.0018293];
% SOQA_Parameters(7).Var_Diff_Score_Shift=0;
% SOQA_Parameters(7).Var_Diff_Score_Scalar=2;
% 
% SOQA_Parameters(7).CovHistXData = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10];
% SOQA_Parameters(7).Covariance_Norm_Hist = [1, 0.45299, 0.29255, 0.096947, 0.056777, 0.02906, 0.015873, 0.010745, 0.0070818, 0.004884, 0.003663, 0.0026862, 0.0020757, 0.0017094, 0.0017094, 0.0019536, 0.0015873, 0.0013431, 0.0014652, 0.001221, 0.002442];
% SOQA_Parameters(7).Cov_Score_Shift=0;
% SOQA_Parameters(7).Cov_Score_Scalar=1.5;
% 
