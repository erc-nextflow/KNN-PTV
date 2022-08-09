function [ImgAn,ImgBn,Ud,Vd]=DewarpImages2F(ImgA,ImgB,Up,Vp,X,Y)
% function for image deformation (Scarano, F. (2001). Iterative image
% deformation methods in PIV. Measurement science and technology, 13(1), R1)

% INPUT:
% - ImgA/B --> data from the PIV picture
% - Up,Vp --> velocity fields
% - X,Y --> grid point

% OUTPUT:
% - ImgAn/Bn --> deformed picture
% - Ud,Vd --> velocity fields deformed

%% STARTING
fprintf('Dewarping images...\n')
[row,col]=size(ImgA);
ImgAn=ImgA;
ImgBn=ImgB;
xd=1:col;
yd=1:row;
[Xd,Yd]=meshgrid(xd,yd);
Ud=interp2(X,Y,Up,Xd,Yd,'spline');
Vd=interp2(X,Y,Vp,Xd,Yd,'spline');

Ud=real(Ud); Vd=real(Vd);

ImgAn=interp2(Xd,Yd,ImgA,Xd-Ud./2,Yd-Vd./2,'linear',0);
ImgBn=interp2(Xd,Yd,ImgB,Xd+Ud./2,Yd+Vd./2,'linear',0);

