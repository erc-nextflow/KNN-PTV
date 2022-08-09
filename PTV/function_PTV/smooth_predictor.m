function [Up,Vp]=smooth_predictor(U,V)
% function for smoothing predictor by a SavitzkyGolay filter
% INPUT:
% - U,V --> velocity fields

% OUTPUT:
% - Up,Vp --> velocity fields filtered

fprintf('Smoothing predictor...\n')
[Ny,Nx]=size(U);
lX=min(Nx,5);
lY=min(Ny,5);

Up = savitzkyGolay2D_rle_coupling(Nx,Ny,U,lX,lY,2);
Vp = savitzkyGolay2D_rle_coupling(Nx,Ny,V,lX,lY,2);

