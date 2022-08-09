function [ImgA,ImgB]=ReadInput2F(FileName,Ndig,i,ROI)

% function for loading pairs of PIV pictures
% INPUT:
% - FileName --> complete path and name of Tomo reconstructions [char]
% - Ndig --> number of digits in the output name [1x1]
% - i --> index of the picture [1x1]
% - ROI --> Region of Interest [1 H 1 W]

% OUTPUT:
% -  ImgA/B --> data from the PIV picture

%% STARTING
% loading first picture
s=sprintf(strcat([FileName '%0' num2str(Ndig) 'da.tif']),i);
A=double(imread(s));
ImgA=A(ROI(1):ROI(2),ROI(3):ROI(4));
% loading second picture
s=sprintf(strcat([FileName '%0' num2str(Ndig) 'db.tif']),i);
A=double(imread(s));
ImgB=A(ROI(1):ROI(2),ROI(3):ROI(4));
   

