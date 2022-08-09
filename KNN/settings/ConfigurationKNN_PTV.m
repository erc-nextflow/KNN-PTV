%% CONFIGURATION FOR FLUIDIC PINBALL TEST CASE

NImg = ;                                                                   % vector of number of snapshots
NImgR = ;                                                                  % vector of number of snapshots to rebuild
H= ;                                                                       % height in pixel
W=   ;                                                                     % width in pixel
ROI=[           ];                                                         % region of interest
Res=  ;                                                                    % resolution [pix/D]
Uinf =  ;                                                                  % bulk velocity
OutDir =   ;                                                               % output directory
InputName =   ;                                                            % input filename ( the same name of the subfolder that contains the snapshot, " NameTestCase")
OutName = InputName;                                                       % output filename
Ndig= ;                                                                    % number of digits
wincorr = ;                                                                % vector window for local analysis
wspac =  ;                                                                 % spacing between windows, i.e 75% overlapping --> 1 - 0.75 = 2.5 [1x1]
npb =  ;                                                                   % number of particles per bin
FlagLocalSaving = 0;                                                       % Flag to enable partial saving during the generation of minidatasets, 
                                                                           % suggested when the dataset are large and the computational time is long 
                                                                           % 1 - enable      0 - disable
FlagRestart = 0;                                                           % 1--> enable reloading of matrix until a specific row ( put it as first_row instead 1) 0--> no restarting


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%      DO NOT MODIFY THE FOLLOWING LINES        %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LOADING PTV

RootPTVstruct = sprintf('.\\Input\\%s_PTV_%d_%d_%d.mat',OutName,NImg(1),NImg(2)-NImg(1),NImg(end));         %Root PTV structure
if isfile(RootPTVstruct)
    load (RootPTVstruct)
else
    cont = 1;
    for i = NImg(1):NImg(end)
        RootPTVSnapshot = sprintf(strcat(['.\\Input\\' InputName '\\PTV_Snapshots\\PTVSnapshot_%0' num2str(Ndig) 'd.mat']),i);  % Root of the PTV snapshots
        load(RootPTVSnapshot);
        PTV.X{cont} = X; PTV.Y{cont} = Y; PTV.U{cont} = U; PTV.V{cont} = V;
        cont = cont+1;
    end
    save(RootPTVstruct,'PTV');
end

clear X Y U V
% Loading the grid onto which we want the results
RootGrid = sprintf('.\\Input\\%s\\PTV_Snapshots\\Grid\\Grid_%s.mat', InputName,InputName); % Root of the grid  
load(RootGrid);                                                            % final output grid
dx = X(1,2)- X(1,1);                                                       % dx of the reference grid 

