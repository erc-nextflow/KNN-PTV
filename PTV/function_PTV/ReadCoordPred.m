function [Matches]=ReadCoordPred(Posa,Posb,X,Y,U,V,ImgA,ImgB)

% This function construct the particles pairs
 
% INPUT:
% - PosA/B --> position of particles in the pair of picture
% - X,Y --> grid point
% - U,V --> velocity fields
% - ImgA/B -->  PIV picture

% OUTPUT
% - Matches --> matches between particles

%% STARTING

% kdtree function set to perform the matchings
ImgA=double(ImgA);
ImgB=double(ImgB);
[H,W]=size(ImgA);

rad=2;
tree=kdtree_build(Posb);

NP=size(Posa,1);
VV=[0 0];
XV=VV;

[Hv,Wv]=size(X);

% building grid
X=[zeros(Hv,1) X (X(end)+X(1)).*ones(Hv,1)];
X=[X(1,:);X;X(1,:)];
Y=[zeros(1,Wv); Y;(Y(end)+Y(1)).*ones(1,Wv)];
Y=[Y(:,1) Y Y(:,1)];
% building velocity matrix
U=[U(:,1) U U(:,end)]; U=[U(1,:);U;U(end,:)];
V=[V(:,1) V V(:,end)]; V=[V(1,:);V;V(end,:)];
% particle velocity
up=griddata(X,Y,U,Posa(:,1),Posa(:,2),'cubic');
vp=griddata(X,Y,V,Posa(:,1),Posa(:,2),'cubic');
    
cont=0;
for i=1:NP
    
    Cen=Posa(i,:)+[up(i) vp(i)];
    range = [ Cen-[0.3 0.3]; Cen+[0.3 0.3]  ]';
    [idxs] = kdtree_range_query( tree, range );   
    if (length(idxs)==1)
        cont=cont+1;
        pa=Posa(i,:);
        pb=Posb(idxs,:);
        VV(cont,:)=pb-pa;
        XV(cont,:)=0.5.*(Posb(idxs(1),:)+Posa(i,:));
        inda(cont)=i;
        indb(cont)=idxs;
    end
    
end

kdtree_delete(tree);


Posanew=Posa; Posanew(inda,:)=[];
Posbnew=Posb; Posbnew(indb,:)=[];
upnew=up;    upnew(inda)=[];
vpnew=vp;    vpnew(inda)=[];

tree=kdtree_build(Posbnew);
NP=size(Posanew,1);

for i=1:NP
    Cen=Posanew(i,:)+[upnew(i) vpnew(i)];
    range = [ Cen-[1 1]; Cen+[1 1]  ]';
    [idxs] = kdtree_range_query( tree, range );   
    if (length(idxs)==1)
        cont=cont+1;
        pa=Posanew(i,:);
        pb=Posbnew(idxs,:);
        VV(cont,:)=pb-pa;
        XV(cont,:)=0.5.*(pb+pa);
        inda(cont)=i;
        indb(cont)=idxs;
    end
end
kdtree_delete(tree);


Matches(:,1)=XV(:,1);
Matches(:,2)=XV(:,2);
Matches(:,3)=VV(:,1);
Matches(:,4)=VV(:,2);
