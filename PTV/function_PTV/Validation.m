function [U,V,Info]=Validation(U,V,X,Y,ValPar)
% function to perfdorm cross validation

% INPUT:
% - U,V --> velocity fields
% - X,Y --> grid point
% - ValPar --> validation parameter [struct]

% OUTPUT:
% - U,V --> velocity fields
% - Info --> flag matrix of correct vectors


%% STARTING

fprintf('Validation...')
Info=zeros(size(U));

if ValPar.Hist==1
    Indg=find(U<ValPar.umax & U>ValPar.umin & V<ValPar.vmax & V>ValPar.vmin);
end
Info(Indg)=1;

Xg=X(Indg);
Yg=Y(Indg);

Ug=U(Indg);
Vg=V(Indg);


Fu=scatteredInterpolant(Xg,Yg,Ug,'linear','linear');
U=Fu(X,Y);
clear Fu
Fv=scatteredInterpolant(Xg,Yg,Vg,'linear','linear');
V=Fv(X,Y);
clear Fv

[U,V,Infom]=medianVal(U,V,ValPar);

Info=Info.*Infom;

fprintf('Correct vectors  %1.1f%%\n',numel(find(Info==1))./numel(Info)*100)


