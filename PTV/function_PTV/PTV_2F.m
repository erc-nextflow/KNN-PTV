function [XP,YP,UP,VP]=PTV_2F(ImgA,ImgB,MeanImgA,MeanImgB,STDImgA,STDImgB,X,Y,U,V)
% function for computing particle velocity and position

% INPUT:
% - ImgA/B --> data from the PIV picture
% - MeanImgA/B --> mean of PIV picture
% - STDImgA/B --> standard deviation of PIV picture
% - X,Y --> grid point
% - U,V --> velocity fields

% OUTPUT:
% - XP,YP --> paricle position
% - UP,VP --> particle velocity


%% STARTING
% extracting particles from first picture
[~,Posa,Ia]=CountParticles_THMap(ImgA,MeanImgA,STDImgA);
% extracting particles from second picture
[~,Posb,Ib]=CountParticles_THMap(ImgB,MeanImgB,STDImgB);
% removing particle too close that can affect the peak computation
Posa=CleanPos(Posa);
Posb=CleanPos(Posb);
% building of particles pair
[Part]=ReadCoordPred(Posa,Posb,X,Y,U,V,ImgA,ImgB);

% assigniment of particle information
XP=Part(:,1);
YP=Part(:,2);
UP=Part(:,3);
VP=Part(:,4);

