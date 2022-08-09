%%  CONFIGURATION FILE FOR PIV_PTV MAIN


IW=[64  40  40 32];                                                         % interrogation window  
Ov=[0.5 0.5 0.75 0.75];                                                     % Overlap

FlagOutIter=0;                                                              % if =1 it saves at each iteration
NImg=1:300;                                                                 % image numbers (ex. 1:100)
FileName='.\\Input\\img\\field_';                                           % complete path and name of Tomo reconstructions
OutDir='.\\Output\\';                                                       % path of the Output folder
OutName='Channel';                                                          % name of testcase (ex.'Pinball','Channel'...)
Ndig=6;                                                                     % number of digits in the snapshots name
FlagSR='YES';                                                               % Flag Super-Resolution PTV
SR.ImStat=1:200;                                                            % flag to compute statistics of the image

Pred.U=0;                                                                   % predictor U
Pred.V=0;                                                                   % predictor V
Pred.W=0;                                                                   % predictor W


ROI=[1 512 1 1024];                                                         % Region of Interest [1 H 1 W]

ValPar.Hist=1;                                                              % if =1 activates the histogram validation with the following parameters
ValPar.umax=10;
ValPar.umin=-10;
ValPar.vmax=10;
ValPar.vmin=-10;
ValPar.UnivTh=2;                                                            % universal median threshold
ValPar.eps=0.1;                                                             % universal median error
ValPar.ker=3;                                                               % half-size of the stencil (1->3x3x3; 2-> 5x5x5)


mkdir(OutDir)