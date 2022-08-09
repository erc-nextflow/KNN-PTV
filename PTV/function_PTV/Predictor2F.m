function [X,Y,U,V,Fc,SN,Info]=Predictor2F(ImgA,ImgB,IW,Ov,ValPar)
% function to compute the predictors for cross validation

% INPUT:
% - ImgA/B --> data from the PIV picture
% - IW --> interrogation window [1x1]
% - Ov --> overlap between interrogation window [1x1]
% - i --> index of the picture [1x1]
% - ROI --> Region of Interest [1 H 1 W]
% - ValPar --> validation parameter [struct]

% OUTPUT:
% - X,Y --> grid point
% - U,V --> velocity fields
% - Fc --> correlation factor
% - SN --> signal/noise ratio (measured on second correlation peak)
% - Info --> flag matrix of correct vectors

%% STARTING

[S1,S2]=size(ImgA);
GD=round(IW*(1-Ov));                                                        % grid distance

IWhalf=round(IW/2);                                                         % half IW

y=IWhalf:GD:(S1-IWhalf);
x=IWhalf:GD:(S2-IWhalf);
% computing grid
[X,Y]=meshgrid(x,y);
%pre-allocation in  memory
U=0.*X; V=0.*X; Fc=0.*X; SN=0.*X;
[GS1,GS2]=size(X);

for i=1:GS2
     XX=(x(i)-IWhalf+1):(x(i)+IWhalf-1);
    for j=1:GS1
%         fprintf('i=%d\tj=%d\t',i,j);
        Wa=ImgA((y(j)-IWhalf+1):(y(j)+IWhalf-1),XX,:);                      % windows in picture A
        Wb=ImgB((y(j)-IWhalf+1):(y(j)+IWhalf-1),XX,:);                      % windows in picture B
        % computing 2D correlation
        [V(j,i),U(j,i),Fc(j,i),SN(j,i)]=TwoDCorr2F_Pred(Wa,Wb,ValPar);
    end
end
% performing cross validation
[U,V,Info]=Validation(U,V,X,Y,ValPar);







