function [U,V,xInt,yInt,stdu,stdv,N]=weightedaverage(x,y,u,v,dist,X,Y,b)

% Function that computes the velocity in the bin according Eq.5
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022

% INPUT:
% - x,y --> particle position
% - X,Y --> grid point
% - u,v --> particle velocity
% - dist --> distance in feature space, dimensionless
% - b --> bin size

% OUTPUT:
% - xInt,yInt --> position of empty bin
% - U,V --> velocity of the bin
% - N --> number of particles for each bin
% - stdu,stdv --> weighted standard deviation

[S1]=numel(X);

tree = kdtree_build([x y]);
bmed=0.5*b;
cont = 0;
xInt = [];

yInt = [];
U=0.*X;V=U;
stdu = U; stdv = stdu; N = U;
for i=1:S1
    % KNN for searching the particles that falling in the bin
    [idxs, dists] = kdtree_ball_query( tree, [X(i) Y(i)], bmed);
    if ~isempty(idxs)
        %% COMPUTING VELOCITY AND UNCERTAINTY
        wi=exp(-(dists/bmed).^2).*exp(-(4*dist(idxs)).^2);                  %weight coefficient
        U(i)=sum(wi.*u(idxs))./sum(wi);
        V(i)=sum(wi.*v(idxs))./sum(wi);
        stdu(i) = sqrt(sum(wi.*(u(idxs)-U(i)).^2)./((numel(wi)-1)/(numel(wi))*sum(wi)));
        stdv(i) = sqrt(sum(wi.*(v(idxs)-V(i)).^2)./((numel(wi)-1)/(numel(wi))*sum(wi)));
        xInt(i) = 0;
        yInt(i) = 0;
        N(i) = numel(wi);
    else
        xInt(i) = 1;
        yInt(i) = 1;
        N(i) = 0;
        cont = cont+1;
        
    end
    
end


kdtree_delete(tree)

               