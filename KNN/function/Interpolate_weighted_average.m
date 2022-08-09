function Interpolate_weighted_average(PTV,Ndig,NImg,b,OutDir,OutName,X,Y)

% Function for building the reference binned matrix
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022

% INPUT:
% - PTV --> PTV matrix, structure format: PTV.X,PTV.Y,PTV.U...; each one is
%           an array cell [1xNt]
% - Ndig --> number of digits in the output name [1x1]
% - NImg --> number of snapshots [1xNImg]
% - b --> bin size, in pixel ( bref ) [1x1]
% - OutDir --> output directory name [char]
% - OutName --> output file name [char]
% -  X,Y --> output grid [nx X ny]

% OUTPUT:
% -  velocity fields for bref


%% STARTING 
% create folder for the output
mkdir(sprintf('%sWA_PTV\\%s\\',OutDir,OutName));

bm=b/2;                                                                     % half bin size

[S1,S2]=size(X);                                                            % number of grid point along X and Y direction

%% COMPUTING SNAPSHOTS
fprintf('\nSnapshot ');
for i=NImg
    sout=sprintf(strcat([OutDir 'WA_PTV\\' OutName '\\' OutName '_b' num2str(b) '_%0' num2str(Ndig) 'd.mat']),i);
     % check if already exists
    if ~isfile(sout)                                                       
        fprintf('%05d',i);
        % building kdtree
        tree=kdtree_build([PTV.X{i} PTV.Y{i}]);
        u=PTV.U{i};  v=PTV.V{i};        
        % pre-allocation
        U=0.*X;
        V=0.*Y;
        FlagPTV=0.*X;
        % for each row
        for II=1:S1
            % for each column
            for JJ=1:S2
                % searching particles distant bm from the center of the bin
                [idxs, dists] = kdtree_ball_query( tree, [X(II,JJ) Y(II,JJ)], bm); %idxs --> index, dists --> distance 
                % computing velocity for the bin ( only if particles
                % falling inside)
                if ~isempty(idxs)
                    wi=exp(-(dists/bm).^2);
                    U(II,JJ)=sum(wi.*u(idxs))./sum(wi);
                    V(II,JJ)=sum(wi.*v(idxs))./sum(wi);
                    FlagPTV(II,JJ) = 1; % flag matrix: 0 - empty bin 1- no-empty bin
                end
            end
        end
        
        %% INTERPOLATION
        IndInt=find(FlagPTV==0);                                            % Index of empty bin
        IndnotInt = find(FlagPTV==1);                                       % Index of no-empty bin
        XX = reshape(X,numel(X),1);
        YY = reshape(Y,numel(X),1);
        Fu=scatteredInterpolant(XX(IndnotInt),YY(IndnotInt),U(IndnotInt));
        Fv=scatteredInterpolant(XX(IndnotInt),YY(IndnotInt),V(IndnotInt));
        U(IndInt) = Fu(XX(IndInt),YY(IndInt));
        V(IndInt) = Fv(XX(IndInt),YY(IndInt));
        kdtree_delete(tree);
        
        %% SAVING
        save(sout,'U','V','X','Y','FlagPTV')
        fprintf('\b\b\b\b\b')
    end
end

fprintf('\b\b\b\b\b\b\b\b\b')

