function [Matches]=ReadCoordPredEnhanced(Posa,Posb,X,Y,U,V,ImgA,ImgB)

% This function construct the particles pairs
% some inputs are required within the function

% kdtree function set to perform the matchings
ImgA=double(ImgA);
ImgB=double(ImgB);
[H,W]=size(ImgA);

rad=2;
tree=kdtree_build(Posb);

NP=size(Posa,1);
cont=0;
VV=[0 0];
XV=VV;

[Hv,Wv]=size(X);
X=[zeros(Hv,1) X (X(end)+X(1)).*ones(Hv,1)];
X=[X(1,:);X;X(1,:)];
Y=[zeros(1,Wv); Y;(Y(end)+Y(1)).*ones(1,Wv)];
Y=[Y(:,1) Y Y(:,1)];

U=[U(:,1) U U(:,end)]; U=[U(1,:);U;U(end,:)];
V=[V(:,1) V V(:,end)]; V=[V(1,:);V;V(end,:)];


up=griddata(X,Y,U,Posa(:,1),Posa(:,2),'cubic');
vp=griddata(X,Y,V,Posa(:,1),Posa(:,2),'cubic');
    
for i=1:NP
    
    Cen=Posa(i,:)+[up(i) vp(i)];
%     range = [ Cen-[3 1]; Cen+[1.5 1]  ]';
    range = [ Cen-[1 1]; Cen+[1 1]  ]';
    [idxs] = kdtree_range_query( tree, range );   
    if (length(idxs)==1)
        pa=round(Posa(i,:));
        pb=round(Posb(idxs(1),:));
        if (pa(2)-rad>0 && pb(2)-rad>0 && pa(1)-rad>0 && pb(1)-rad>0 &&...
                pa(2)+rad<=H && pb(2)+rad<=H && pa(1)+rad<=W && pb(1)+rad<=W)
            ImA=ImgA(pa(2)-rad:pa(2)+rad,pa(1)-rad:pa(1)+rad);
            ImB=ImgB(pb(2)-rad:pb(2)+rad,pb(1)-rad:pb(1)+rad);
            ImA=ImA-mean(ImA(:));
            ImB=ImB-mean(ImB(:));
            dum2=normxcorr2(ImA,ImB);
            [pip,M]=max(dum2(:));
            [I J]=ind2sub([(rad*2+1)*2-1,(rad*2+1)*2-1],M);
            if(I>1 && I<(rad*2+1)*2-1 && J>1 && J<(rad*2+1)*2-1)
                i0=I+(dum2(I-1,J)-dum2(I+1,J))/(2*dum2(I-1,J)+2*dum2(I+1,J)-4.*dum2(I,J));
                j0=J+(dum2(I,J-1)-dum2(I,J+1))/(2*dum2(I,J-1)+2*dum2(I,J+1)-4.*dum2(I,J));
                
                cont=cont+1;
                VV(cont,:)=pb-pa+[j0-J i0-I];
                XV(cont,:)=0.5.*(Posb(idxs(1),:)+Posa(i,:));
            end
        end
    end
    
end


kdtree_delete(tree);


Matches(:,1)=XV(:,1);
Matches(:,2)=XV(:,2);
Matches(:,3)=VV(:,1);
Matches(:,4)=VV(:,2);


return
% figure(1)
clf
plot(Posa(:,1),Posa(:,2),'.r')
hold on
plot(Posb(:,1),Posb(:,2),'.k')
% plot(Posa(:,1)+up,Posa(:,2)+vp,'.b')
quiver(XV(:,1)-VV(:,1)*0.5,XV(:,2)-VV(:,2)*0.5,VV(:,1),VV(:,2),'AutoScale','off')
quiver(Posa(:,1),Posa(:,2),up,vp,'Autoscale','off')
axis equal

% % % axis([500 700 1900 2160])
% 
% pause