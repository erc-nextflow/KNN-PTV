function KNNreconstruction(OutDir,OutName,Ndig,NImgR,NImgT,bTG,Kmap,wincorr,PTV,X,Y,GridPOD,b0,dx,FlagRestart,FlagLocalSaving,boundary)

% function for the computation of the HR snapshot
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022

% INPUT:
% - OutDir --> output directory name [char]
% - OutName --> output file name [char]
% - Ndig --> number of digits in the output name [1x1]
% - NImgR --> number of snapshots to rebuilt [1xNImgR]
% - NImgT --> number of total snapshots [1xNImgT]
% - bTG --> bin size [1x1]
% - Kmap --> map of neighbours [GridPOD]
% - wincorr --> number of vector in the window for local analysis
%               wincorr x wincorr [1x1]
% - PTV --> PTV matrix, structure format: PTV.X,PTV.Y,PTV.U...; each one is
%           an array cell [1xNt]
% - X,Y --> output grid [nx X ny]
% - GridPOD --> POD grid, structure ( GridPOD.x,GridPOD.Y)
% - b0 --> bin size [1x1]
% - dx --> grid distance [1x1]
% - FlagLocalSavingK -->  1 --> enable partial saving 0--> disable partial saving 1--> enable reloading of matrix until a specific row ( put it as first_row instead 1) 0--> no restarting
% - Kboundary --> number of rows of columns from which extraxct the map, it's in the format [ first_row last_row first_column last_column]. 
% - FlagRestart --> 1--> enable reloading of matrix until a specific row  0--> no restarting
                                                                            

% OUTPUT:
% - UKNN,VKNN,stdu,stdv --> velocity field and uncertainty for the minidataset

%% STARTING
fprintf('Performing Local KNN reconstruction...\n')
mkdir(sprintf('%sKNN_PTV\\%s\\LOCAL_w%d_adaptive\\',OutDir,OutName,wincorr));
%% PRELIMINARY STEPS
fprintf('Creating minidataset..\n')
if FlagLocalSaving == 1
    fprintf('Partial saving enabled..\n')
else
    fprintf('Partial saving disabled..\n')
end

% building kdtree
tree = kdtree_build([GridPOD.X(:) GridPOD.Y(:)]);
[SX,SY]=size(X);

%searching position of bin centers
for i=1:SX
    for j=1:SY
        idxs = kdtree_k_nearest_neighbors(tree,[X(i,j) Y(i,j)],1);
        BinPos(i,j)=idxs;
    end
end

kdtree_delete(tree);
SS3 = boundary(2);
SS4 = boundary(4);
% pre allocation in memory
UKNN=0.*X;
VKNN=0.*X;
xInd = UKNN;
yInd = UKNN;
stdu = UKNN;
stdv = stdu;
N = UKNN;
cont = 0;
%% RELOADING OR INITIALIZE MATRICES
if FlagRestart == 0
    UU = zeros([size(UKNN) numel(NImgR)]);  VV = UU; xx = UU; yy = UU; su = UU; sv = VV;
else
    fprintf('\n Reloading matrix untill ROW = %d of %d \n',boundary(1),SS3)
    UU = zeros([size(UKNN) numel(NImgR)]);  VV = UU; xx = UU; yy = UU; su = UU; sv = VV;
    fprintf('\nSnapshot ');
    for i = NImgR
        fprintf('%05d',i);
        cont = cont+1;
        sout=sprintf(strcat([OutDir '\\KNN_PTV\\' OutName '\\LOCAL_w' num2str(wincorr) '_adaptive\\' OutName '_w' num2str(wincorr) '_img_' num2str(NImgT(1)) '_' num2str(NImgT(end)) '_%0' num2str(Ndig) 'd.mat']),NImgR(i));
        load(sout,'UKNN','VKNN','stdu','stdv');
        UU(:,:,cont) = UKNN;
        VV(:,:,cont) = VKNN;
        su(:,:,cont) = stdu;
        sv(:,:,cont) = stdv;
        fprintf('\b\b\b\b\b')
    end
    fprintf('\b\b\b\b\b\b\b\b\b')
end

%% PARTIAL SAVING OPTION ENABLED
if FlagLocalSaving == 1
    % for each row
    for II = boundary(1):boundary(2)
        % partial saving each 5 rows, you can modify the parameter if you
        % prefer
        if mod(II,5)==0
            fprintf('\n Saving results untill ROW = %d of %d \n',II,SS3)
            su(isinf(su)) = nan;
            sv(isinf(sv)) = nan;
            
            cont = 0;
            for i = NImgR
                cont = cont+1;
                IndInt=find(xx(:,:,cont)==1);
                IndnotInt=find(xx(:,:,cont)==0);
                UKNN = UU(:,:,cont);
                VKNN = VV(:,:,cont);
                Fu=scatteredInterpolant(XX(IndnotInt),YY(IndnotInt),UKNN(IndnotInt));
                Fv=scatteredInterpolant(XX(IndnotInt),YY(IndnotInt),VKNN(IndnotInt));
                UKNN(IndInt) = Fu(XX(IndInt),YY(IndInt));
                VKNN(IndInt) = Fv(XX(IndInt),YY(IndInt));
                %     MaskApplication;
                stdu = su(:,:,cont);
                stdv = sv(:,:,cont);
                sout=sprintf(strcat([OutDir '\\KNN_PTV\\' OutName '\\LOCAL_w' num2str(wincorr) '_adaptive\\' OutName '_w' num2str(wincorr) '_img_' num2str(NImgT(1)) '_' num2str(NImgT(end)) '_%0' num2str(Ndig) 'd.mat']),NImgR(i));
                save(sout,'UKNN','VKNN','X','Y','N','wincorr','stdu','stdv','-v7.3')
            end
            fprintf('\n Partial saving completed, continuing computation \n')
        end
        %for each column
        for JJ=boundary(3):boundary(4)
            tic
            fprintf('\nROW = %d of %d \t COL = %d of %d \n',II,SS3,JJ,SS4)
            %identification of corresponding bin
            bquery=sub2ind([SS3,SS4],II,JJ);
            IJ=find(BinPos==bquery);
            sout= strcat([OutDir 'TrainingSet\\TS_' OutName '\\' OutName 'TS_b' num2str(b0) '_w' num2str(wincorr) '_img_' num2str(NImgT(1)) '_' num2str(NImgT(end)) '_Row' num2str(II) 'Col' num2str(JJ) '.mat']);
            % loading training set
            load(sout);
            [III,JJJ]=ind2sub([SX,SY],IJ);
            cont=0;
            %for each snapshot
            for i=NImgR
                invNA=1./norm(A(i,:));                                      % parameter for dimensionless distance in feature space
                cont=cont+1;
                % KNN
                K = Kmap(II,JJ);
                [mIdx,d] = knnsearch(A,A(i,:),'K',K);
                u=0; v=0;  x=0; y=0; dist = 0;
                %for each K
                for ii=1:K
                    if ii==1
                        % function for removing the particles distant from
                        % the center
                        [x,y,u,v,dist]=RemoveDistantParticles(PTV.X{i},PTV.Y{i},GridPOD.X(II,JJ),GridPOD.Y(II,JJ),PTV.U{i},PTV.V{i},d(ii)*ones(size(PTV.U{i})),dx);
                        % pre allocation of variables, for speedup the
                        % computation
                        np=numel(u); guess=zeros((K-1)*3*np,1);
                        u=[u; guess];  v=[v; guess];  x=[x; guess];  y=[y; guess];  dist=[dist; guess];
                        npnew = guess;
                        npv(1)=np;
                    else
                        % function for removing the particles distant from
                        % the center
                        [ax,ay,au,av,adist]=RemoveDistantParticles(PTV.X{mIdx(ii)},PTV.Y{mIdx(ii)},GridPOD.X(II,JJ),GridPOD.Y(II,JJ),PTV.U{mIdx(ii)},PTV.V{mIdx(ii)},d(ii).*invNA*ones(size(PTV.U{mIdx(ii)})),dx);
                        npnew=np+numel(au);                                % counter of particles
                        u(np+1:npnew)=au; v(np+1:npnew)=av; x(np+1:npnew)=ax; y(np+1:npnew)=ay; dist(np+1:npnew)=adist;         %velocity and position vectors
                        np=npnew;
                        npv(ii)=numel(au);
                    end
                end
                
                cumsumnpv=cumsum(npv);
                
                %removing the preallocated memory tha is not used
                u(npnew+1:end)=[];  v(npnew+1:end)=[];  x(npnew+1:end)=[];  y(npnew+1:end)=[];  dist(npnew+1:end)=[];
                u=u(:); v=v(:); x=x(:); y=y(:); dist=dist(:);
                
                
                %check if the bin is empty
                if isempty(x)
                    xInd(IJ) = 1;
                    yInd(IJ) = 1;
                else
                    % computing velocity for each bin
                    [UKNN(IJ),VKNN(IJ),xInd(IJ),yInd(IJ),stdu(IJ),stdv(IJ)]=weightedaverage(x,y,u,v,dist,X(IJ),Y(IJ),bTG(II,JJ));
                    [c] = find(isnan(UKNN(IJ)));
                    % mark empty spot
                    if ~isempty(c)
                        xInd(IJ) = 1;
                        yInd(IJ) = 1;
                    end
                end
                % building the 4D matrix
                UU(III,JJJ,cont) = UKNN(III,JJJ);
                VV(III,JJJ,cont) = VKNN(III,JJJ);
                xx(III,JJJ,cont) = xInd(III,JJJ);
                yy(III,JJJ,cont) = yInd(III,JJJ);
                su(III,JJJ,cont) = stdu(III,JJJ);
                sv(III,JJJ,cont) = stdv(III,JJJ);
                NN(III,JJJ,cont) = N(III,JJJ);
                clear mIdx d
            end
            toc
            
        end
        
    end

else
    %% PARTIAL SAVING OPTION DISABLED
    % for each row
    for II = boundary(1):boundary(2)
        %for each column
        for JJ=boundary(3):boundary(4)
            tic
            fprintf('\nROW = %d of %d \t COL = %d of %d \n',II,SS3,JJ,SS4)
            %identification of corresponding bin
            bquery=sub2ind([SS3,SS4],II,JJ);
            IJ=find(BinPos==bquery);
            sout= strcat([OutDir '\\TrainingSet\\TS_' OutName '\\' OutName 'TS_b' num2str(b0) '_w' num2str(wincorr) '_img_' num2str(NImgT(1)) '_' num2str(NImgT(end)) '_Row' num2str(II) 'Col' num2str(JJ) '.mat']);
            % loading training set
            load(sout);
            [III,JJJ]=ind2sub([SX,SY],IJ);
            cont=0;
            %for each snapshot
            for i=NImgR
                invNA=1./norm(A(i,:));                                      % parameter for dimensionless distance in feature space
                cont=cont+1;
                % KNN
                K = Kmap(II,JJ);
                [mIdx,d] = knnsearch(A,A(i,:),'K',K);
                u=0; v=0;  x=0; y=0; dist = 0;
                %for each K
                for ii=1:K
                    if ii==1
                        % function for removing the particles distant from
                        % the center
                        [x,y,u,v,dist]=RemoveDistantParticles(PTV.X{i},PTV.Y{i},GridPOD.X(II,JJ),GridPOD.Y(II,JJ),PTV.U{i},PTV.V{i},d(ii)*ones(size(PTV.U{i})),dx);
                        % pre allocation of variables, for speedup the
                        % computation
                        np=numel(u); guess=zeros((K-1)*3*np,1);
                        u=[u; guess];  v=[v; guess];  x=[x; guess];  y=[y; guess];  dist=[dist; guess];
                        npnew = guess;
                        npv(1)=np;
                    else
                        % function for removing the particles distant from
                        % the center
                        [ax,ay,au,av,adist]=RemoveDistantParticles(PTV.X{mIdx(ii)},PTV.Y{mIdx(ii)},GridPOD.X(II,JJ),GridPOD.Y(II,JJ),PTV.U{mIdx(ii)},PTV.V{mIdx(ii)},d(ii).*invNA*ones(size(PTV.U{mIdx(ii)})),dx);
                        npnew=np+numel(au);                                % counter of particles
                        u(np+1:npnew)=au; v(np+1:npnew)=av; x(np+1:npnew)=ax; y(np+1:npnew)=ay; dist(np+1:npnew)=adist;         %velocity and position vectors
                        np=npnew;
                        npv(ii)=numel(au);
                    end
                end
                
                cumsumnpv=cumsum(npv);
                
                %removing the preallocated memory tha is not used
                u(npnew+1:end)=[];  v(npnew+1:end)=[];  x(npnew+1:end)=[];  y(npnew+1:end)=[];  dist(npnew+1:end)=[];
                u=u(:); v=v(:); x=x(:); y=y(:); dist=dist(:);
                
                
                %check if the bin is empty
                if isempty(x)
                    xInd(IJ) = 1;
                    yInd(IJ) = 1;
                else
                    % computing velocity for each bin
                    [UKNN(IJ),VKNN(IJ),xInd(IJ),yInd(IJ),stdu(IJ),stdv(IJ)]=weightedaverage(x,y,u,v,dist,X(IJ),Y(IJ),bTG(II,JJ));
                    [c] = find(isnan(UKNN(IJ)));
                    % mark empty spot
                    if ~isempty(c)
                        xInd(IJ) = 1;
                        yInd(IJ) = 1;
                    end
                end
                % building the 4D matrix
                UU(III,JJJ,cont) = UKNN(III,JJJ);
                VV(III,JJJ,cont) = VKNN(III,JJJ);
                xx(III,JJJ,cont) = xInd(III,JJJ);
                yy(III,JJJ,cont) = yInd(III,JJJ);
                su(III,JJJ,cont) = stdu(III,JJJ);
                sv(III,JJJ,cont) = stdv(III,JJJ);
                NN(III,JJJ,cont) = N(III,JJJ);
                clear mIdx d
            end
            toc
            
        end
        
    end
end

%% SAVING OUTPUT
XX = reshape(X,numel(X),1);
YY = reshape(Y,numel(X),1);
su(isinf(su)) = nan;
sv(isinf(sv)) = nan;

for i = 1:numel(NImgR)
    IndInt=find(xx(:,:,i)==1);
    IndnotInt=find(xx(:,:,i)==0);
    UKNN = UU(:,:,i); 
    VKNN = VV(:,:,i); 
    Fu=scatteredInterpolant(XX(IndnotInt),YY(IndnotInt),UKNN(IndnotInt));
    Fv=scatteredInterpolant(XX(IndnotInt),YY(IndnotInt),VKNN(IndnotInt));
    UKNN(IndInt) = Fu(XX(IndInt),YY(IndInt));
    VKNN(IndInt) = Fv(XX(IndInt),YY(IndInt));
    %     MaskApplication;
    stdu = su(:,:,i);
    stdv = sv(:,:,i);
    N = NN(:,:,i);
    sout=sprintf(strcat([OutDir '\\KNN_PTV\\' OutName '\\LOCAL_w' num2str(wincorr) '_adaptive\\' OutName '_w' num2str(wincorr) '_img_' num2str(NImgT(1)) '_' num2str(NImgT(end)) '_%0' num2str(Ndig) 'd.mat']),NImgR(i));
    save(sout,'UKNN','VKNN','X','Y','N','wincorr','stdu','stdv','-v7.3')
    
end
