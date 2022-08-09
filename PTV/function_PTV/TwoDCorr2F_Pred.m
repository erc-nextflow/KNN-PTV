function [i0,j0,Fc,SN]=TwoDCorr2F_Pred(Wa,Wb,ValPar)
% function to compute 2D correlation

% INPUT:
% - Wa/b --> windows in picture A/B
% - ValPar --> validation parameter [struct]

% OUTPUT:
% - i0 --> x coordinate for interpolation
% - j0 --> y coordinate for interpolation
% - Fc --> correlation factor
% - SN --> signal/noise ratio (measured on second correlation peak)

%% STARTING
IW=size(Wa,1);                                                             % interrogation window
IWhalf=ceil(IW/2);                                                         % half interrogation window
% removing mean from window
Wa=Wa-mean(Wa(:));
Wb=Wb-mean(Wb(:));
den=sqrt(sum(Wa(:).^2)*sum(Wb(:).^2));

%% COMPUTING CORRELATION
% Fourier transform
Fa=fftn(Wa);
Fb=fftn(Wb);
% computing correlation
R=ifftn(Fb.*conj(Fa))./den;
R=fftshift(R);
% computing index
II=(ValPar.vmin:ValPar.vmax)+IWhalf;
JJ=(ValPar.umin:ValPar.umax)+IWhalf;
rappo=R(II,JJ);
% rappo=Rc;
[Fc,I]=max(rappo(:));

[im,jm]=ind2sub(size(rappo),I);
im=im+ValPar.vmin+IWhalf-1;
jm=jm+ValPar.umin+IWhalf-1;

Flag=0;
% sub-voxel interpolation
if (im>2 && im<IW-1)
    if (jm>2 && jm<IW-1)
        dum=R(im-1:im+1,jm-1:jm+1);
        dum2=log(dum+0.01);
        i0=im+(dum2(1,2)-dum2(3,2))/(2*dum2(1,2)+2*dum2(3,2)-4.*dum2(2,2))-IWhalf;
        j0=jm+(dum2(2,1)-dum2(2,3))/(2*dum2(2,1)+2*dum2(2,3)-4.*dum2(2,2))-IWhalf;
        R(im-2:im+2,jm-2:jm+2)=0;
        [SM]=max(R(:));
        SN=Fc/SM;
        Flag=1;
    end
end

if(Flag==0)
    i0=0;
    j0=0;
    Fc=0;
    SN=1;
end





