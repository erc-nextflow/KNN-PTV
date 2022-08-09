function [U,V]=UpdateVelocity(Up,Vp,U,V,X,Y,IW)
% function for update velocity field

% INPUT:
% - Up,Vp --> velocity fields deformed
% - U,V --> velocity fields 
% - X,Y --> grid point
% - IW --> interrogation window

% OUTPUT:
% - U,V --> velocity fields updated


IWhalf=ceil(IW/2);
[S1,S2]=size(X);
UP=0.*U; VP=UP;

for i=1:S1
    for j=1:S2
        JJ=X(i,j)-IWhalf+1:X(i,j)+IWhalf-1;
        II=Y(i,j)-IWhalf+1:Y(i,j)+IWhalf-1;
        dumU=Up(II,JJ);
        dumV=Vp(II,JJ);
        
        UP(i,j)=mean(dumU(:));
        VP(i,j)=mean(dumV(:));
    end
end

U=U+UP;
V=V+VP;
