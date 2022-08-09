function Posnew=CleanPos(Pos)
% function for removing particle too close that can bias the computation of
% the peak

% INPUT:
% - Pos -- > vector with the position of particles

% OUTPUT:
% - Posnew -- > vector with the position of particles after removing the
% ones too close

%% STARTING

% building kdtree of particles position
tree=kdtree_build(Pos);

Np=size(Pos,1);
qradii = 1.5;                                                              % minimum radius (1.5 pixel)                                                    
cont=0;
ij=[];
for i=1:Np
    % searching close particles
    [idxs, dists] = kdtree_ball_query( tree, Pos(i,:), qradii);
    if length(idxs)>1
        for jj=2:length(idxs)
            cont=cont+1;
            ij(cont)=idxs(jj);
        end
    end
end

% update position vector
Posnew=Pos;
Posnew(ij,:)=[];


