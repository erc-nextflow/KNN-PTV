
%% File to prepare the workspace properly
%%% You can run this code before the main in order to create all the
%%% folders where import datasets, useful in the case you want to import
%%% the dataset available on zenodo at 

OutDir='.\\Output\\';                                                      % output directory
InputName = 'Pinball'  ;                                                 % input filename (i.e. Pinball, channel,tbl)
OutName = InputName;                                                       % output filename (can be different, as you prefer)                                                               % number of digits
wincorr=10;                                                                % vector window for local analysis
mkdir(OutDir)
mkdir(sprintf('%sTrainingSet\\TS_%s\\',OutDir,OutName));
mkdir(sprintf('%sKNN_PTV\\%s\\LOCAL_w%d_adaptive\\',OutDir,OutName,wincorr));
mkdir(sprintf('%sWA_PTV\\%s\\',OutDir,OutName));
mkdir(sprintf('.\\Input\\%s\\PTV_Snapshots',OutName));