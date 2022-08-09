function [MeanImgA, STDImgA, MeanImgB, STDImgB]=CalcStatImg(NImg,FileName,ROI,Ndig)
% v1.001 of 2020_06_23
% This function calculates the statistics of the pair PIV images. The objective is
% to select a locally-varying threshold.

% INPUT:
% - NImg --> number of snapshots [1xNImg]
% - FileName --> complete path and name of Tomo reconstructions [char]
% - ROI --> Region of Interest [1 H 1 W]
% - Ndig --> number of digits in the output name [1x1]

% OUTPUT:
% -  MeanImgA/B --> mean of the PIV picture
% -  STDImgA/B --> standard deviation of the PIV picture

%% STARTING
% pre-allocation in memory
MeanImgA=0;
STDImgA=0;
MeanImgB=0;
STDImgB=0;

% preparing waitbar
f = waitbar(0,'1','Name','Computing Statistics...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);
cont=0;
N=numel(NImg);
t1=cputime;

%% COMPUTING STATHISTICS
for i=NImg
     if getappdata(f,'canceling')
        break
     end
    % loading first picture
    s=sprintf(strcat([FileName '%0' num2str(Ndig) 'da.tif']),i);
    A=double(imread(s));
    A=A(ROI(1):ROI(2),ROI(3):ROI(4));
    % computing stathistics of first picture
    MeanImgA=MeanImgA+A./N;
    STDImgA=STDImgA+A.^2./N;
    % loading second picture
    s=sprintf(strcat([FileName '%0' num2str(Ndig) 'db.tif']),i);
    B=double(imread(s));
    B=B(ROI(1):ROI(2),ROI(3):ROI(4));
    % computing stathistics of second picture
    MeanImgB=MeanImgB+B./N;
    STDImgB=STDImgB+B.^2./N;
    cont=cont+1;
    t2=cputime;
    waitbar(cont/N,f,sprintf('%1.1fs to finish',(t2-t1)/cont*(N-cont)))
end

delete(f)

STDImgA=sqrt(STDImgA-MeanImgA.^2);
STDImgB=sqrt(STDImgB-MeanImgB.^2);
