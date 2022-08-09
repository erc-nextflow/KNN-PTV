function [i0,j0,Fc,SN]=TwoDcorr2F_WinDef(Wa,Wb,Nf)
IW=size(Wa,1);
IWhalf=ceil(IW/2);
% Fc is the correlation factor
% SN is the signal/noise ratio (measured on second correlation peak)

Wa=Wa-mean(Wa(:));
Wb=Wb-mean(Wb(:));
den=sqrt(sum(Wa(:).^2)*sum(Wb(:).^2));
Fa=fftn(Wa);
Fb=fftn(Wb);
R=ifftn(Fb.*conj(Fa))./den;
R=fftshift(R);

II=(-3:3)+IWhalf;
JJ=(-3:3)+IWhalf;
rappo=R(II,JJ);
[Fc,I]=max(rappo(:));

[im,jm]=ind2sub(size(rappo),I);
im=im-4+IWhalf;
jm=jm-4+IWhalf;

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





