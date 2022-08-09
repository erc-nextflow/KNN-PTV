function [Np,Pos,Int]=CountParticles_THMap(ImgU8,IM,ISTD)
% function for computing number of particle, position and intensity

% INPUT:
% - ImgU8 --> data from the PIV picture
% - IM --> mean of PIV picture
% - ISTD --> standard deviation of PIV picture

% OUTPUT:
% - Np --> number of particles
% - Pos -->  vector which will contain the positions of the particles
% - Int --> vector which will contain the intensities of the particles


%% STARTING

[H W]=size(ImgU8);
Img = double(ImgU8);

%th=IMax;
Np=0;
% pre-allocation with a tentative guess for the number of particles
guess=40000;
Pos=zeros(guess,2);                                                        % vector which will contain the positions of the particles
Int=zeros(guess,1);                                                        % vector which will contain the intensities of the particles

% ij=find(Img>th);

ij=find(Img>(IM+1*ISTD));

[i,j]=ind2sub([H,W],ij);
for ii=1:length(ij)
    I=i(ii);
    J=j(ii);
    if (I>1 && I<H && J>1 && J<W)
       % extract 3x3 kernel around the candidate point to be a peak
        dum=Img(I-1:I+1,J-1:J+1);                                          
        dum2=dum;
        dum(2,2)=0; dum(1,1)=0; dum(1,3)=0; dum(3,1)=0; dum(3,3)=0;
        if(Img(I,J)>max(dum(:)))
            dum2=log(dum2+0.01);
            i0=I+(dum2(1,2)-dum2(3,2))/(2*dum2(1,2)+2*dum2(3,2)-4.*dum2(2,2));
            j0=J+(dum2(2,1)-dum2(2,3))/(2*dum2(2,1)+2*dum2(2,3)-4.*dum2(2,2));
            Np=Np+1;
            Pos(Np,2)=i0;
            Pos(Np,1)=j0;
            Int(Np)=Img(I,J);
        end
        if Np==guess
            guess=guess+10000;
            Pos=[Pos;zeros(10000,2)];
            Int=[Int;zeros(10000,1)];
        end
    end
end

Pos=Pos(1:Np,1:2);
Int=Int(1:Np);