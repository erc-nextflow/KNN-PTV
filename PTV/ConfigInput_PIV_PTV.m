%%  CONFIGURATION FILE FOR PIV_PTV MAIN


IW=[];                                                                      % interrogation window  
Ov=[];                                                                      % Overlap

FlagOutIter=0;                                                              % if =1 it saves at each iteration
NImg=1:300;                                                                 % image numbers (ex. 1:100)
FileName='.';                                                               % complete path and name of Tomo reconstructions
OutDir='.';                                                                 % path of the Output folder
OutName='';                                                                 % name of testcase (ex.'Pinball','Channel'...)
Ndig=6;                                                                     % number of digits in the snapshots name
FlagSR='YES';                                                               % Flag Super-Resolution PTV
SR.ImStat=1:200;                                                            % flag to compute statistics of the image
ROI=[];                                                                     % Region of Interest [1 H 1 W]

% Initialization of parameter
Pred.U=0;                                                                   % predictor U
Pred.V=0;                                                                   % predictor V
Pred.W=0;                                                                   % predictor W


ValPar.Hist=1;                                                              % if =1 activates the histogram validation with the following parameters
ValPar.umax=10;
ValPar.umin=-10;
ValPar.vmax=10;
ValPar.vmin=-10;
ValPar.UnivTh=2;                                                            % universal median threshold
ValPar.eps=0.1;                                                             % universal median error
ValPar.ker=3;                                                               % half-size of the stencil (1->3x3x3; 2-> 5x5x5)


mkdir(OutDir)