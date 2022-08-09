function [X,Y,U,V,Fc,SN]=Corrector(ImgA,ImgB,IW,Ov)
% function for computing correctors

% INPUT:
% - ImgA/B --> data from the PIV picture
% - IW --> interrogation window
% - Ov --> overlap

% OUTPUT:
% - ImgAn/Bn --> deformed picture
% - X,Y --> grid point
% - U,V --> velocity fields
% - Fc --> correlation factor
% - SN --> signal/noise ratio (measured on second correlation peak)


%% STARTING


fprintf('Computing corrector...\n')
[S1,S2]=size(ImgA);
GD=round(IW*(1-Ov));

IWhalf=round(IW/2);

y=IWhalf:GD:(S1-IWhalf);
x=IWhalf:GD:(S2-IWhalf);

[X,Y]=meshgrid(x,y);
U=0.*X; V=0.*X; Fc=0.*X; SN=Fc;
[GS1,GS2]=size(X);

for i=1:GS2
    XX=(x(i)-IWhalf+1):(x(i)+IWhalf-1);
    for j=1:GS1
        Wa=ImgA((y(j)-IWhalf+1):(y(j)+IWhalf-1),XX,:);
        Wb=ImgB((y(j)-IWhalf+1):(y(j)+IWhalf-1),XX,:);
        [V(j,i),U(j,i),Fc(j,i),SN(j,i)]=TwoDcorr2F_WinDef(Wa,Wb);
    end
end

ij=find(isnan(Fc)); Fc(ij)=0;
ij=find(isnan(SN)); SN(ij)=0;

U=real(U);
V=real(V);



