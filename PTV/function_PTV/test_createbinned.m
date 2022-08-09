clc, clear, close all
addpath('.\bin\kdtree\');
ROI=[1 1550 1 1500];
RootName='.\Output\Wing_part_';
NImg=3:50;
dx=8;
IW=80;

y=ROI(1)+IW/2-1:dx:ROI(2)-IW/2;
x=ROI(3)+IW/2-1:dx:ROI(4)-IW/2;

[X,Y]=meshgrid(x,y);
[S1,S2]=size(X);

for ii=NImg
    s=sprintf('%s%06d',RootName,ii);
    load(s);
    
    tree=kdtree_build([XP(:) YP(:)]);
    Np=numel(XP);
    Ub=0.*X;
    Vb=0.*X;
    for i=1:S1
        for j=1:S2
            Cen=[X(i,j) Y(i,j)];
            range = [ Cen-[IW/2 IW/2]; Cen+[IW/2 IW/2]  ]';
            idxs = kdtree_range_query( tree, range );
            Ub(i,j)=mean(UP(idxs));
            Vb(i,j)=mean(VP(idxs));
        end
    end
    
    kdtree_delete(tree);
    
    figure(1)
    pcolor(X,Y,Vb)
    shading interp
    caxis([5 20])
    axis equal
    colormap jet(64)
    drawnow
    pause(0.1)
end


        






