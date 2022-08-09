function [GridPOD] = LocalPODBinnedPTV(OutDir,OutName,b,Ndig,NImg,wincorr,X,wspac)

% Function for performing Lcal POD and building of training set
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022

% INPUT:
% - OutDir --> output directory name [char]
% - OutName --> output file name [char]
% - b --> bin size, in pixel ( bref ) [1x1]
% - Ndig --> number of digits in the output name [1x1]
% - NImg --> number of snapshots [1x1]
% - wincorr --> number of vector in the window for local analysis
%               wincorr x wincorr [1x1]
% -  X --> output grid [nx X ny]
% - wspac --> spacing between windows, i.e 75% overlapping --> 1 - 0.75 =
%             2.5 [1x1]


% OUTPUT:
% -  A --> training set psi*sigma
% - GridPOD --> POD grid, structure ( GridPOD.x,GridPOD.Y)


%% STARTING
fprintf('Performing Local POD...\n')
% create folder for the output
mkdir(sprintf('%sTrainingSet\\TS_%s\\',OutDir,OutName));

sout= strcat([OutDir 'TrainingSet\\TS_' OutName '\\' OutName 'TS_b' num2str(b) '_w' num2str(wincorr) '_img_' num2str(NImg(1)) '_' num2str(NImg(end)) '_Grid.mat']);

% if training set is not available
if ~isfile(sout)
    %% LOADING REFERENCE MATRIX
    cont=0;
    for i=NImg
        cont=cont+1;
        s=sprintf(strcat([OutDir 'WA_PTV\\' OutName '\\' OutName '_b' num2str(b) '_%0' num2str(Ndig) 'd.mat']),i);
        BIN=load(s,'U','V','X','Y');
        if i==NImg(1)
            U=zeros(size(BIN.U,1),size(BIN.U,2),numel(NImg));
            V=0.*U;
        end
        
        U(:,:,cont)=reshape(BIN.U(:),[size(BIN.U,1) size(BIN.U,2)]);
        V(:,:,cont)=reshape(BIN.V(:),[size(BIN.V,1) size(BIN.V,2)]);
    end
    %removing mean
    Um=mean(U,3); Vm=mean(V,3);
    u=U-Um; v=V-Vm;
    
    [Hv,Wv,~]=size(u);
    Nvx=floor(Wv/wspac); Nvy=floor(Hv/wspac);
    
    % pre-allocation in memory
    if (2*wincorr^2)<numel(NImg)
        r=2*wincorr^2;
    else
        r=numel(NImg);
    end
    Psi=zeros(numel(NImg),r);
    Sigma=zeros(r,r);
    
    
    dx=X(1,2)-X(1,1);
    %% LOCAL POD
    % for each row
    for i=1:Nvy
        % for each columns
        for j=1:Nvx
              fprintf('ROW = %d of %d \t COL = %d of %d \n',i,Nvy,j,Nvx)
               % pre-allocation in memory
                uloc=zeros(wincorr,wincorr,numel(NImg)); vloc=uloc;         % local velocity field
                % computing indexes
                i0=floor(1+(i-1)*wspac);                                    % first row index
                j0=floor(1+(j-1)*wspac);                                    % first column index
                GridPOD.Y(i,j)=0.5+(i0-1)*dx+wincorr*dx/2;                  
                GridPOD.X(i,j)=0.5+(j0-1)*dx+wincorr*dx/2;
                II=i0:min([i0+wincorr-1 Hv]);                               % row indexes
                JJ=j0:min([j0+wincorr-1 Wv]);                               % column indexes
                % computing local velocities
                uloc(1:numel(II),1:numel(JJ),:)=u(II,JJ,:);
                vloc(1:numel(II),1:numel(JJ),:)=v(II,JJ,:);
                uloc=reshape(uloc,[size(uloc,1)*size(uloc,2) numel(NImg)]);
                vloc=reshape(vloc,[size(vloc,1)*size(vloc,2) numel(NImg)]);
                % Local POD
                [Psi,Sigma,~]=svd([uloc' vloc'],'econ');
                % Computing rank
                S=diag(Sigma);                                              % singular values
                Csum=cumsum(S.^2);                                          % cumulative energy distribution
                r=find(Csum./sum(S.^2)>=0.9,1,'first');                     % rank
                %Building Training set
                A = Psi(:,1:r)*Sigma(1:r,1:r);                              % training set
                sout= strcat([OutDir 'TrainingSet\\TS_' OutName '\\' OutName 'TS_b' num2str(b) '_w' num2str(wincorr) '_img_' num2str(NImg(1)) '_' num2str(NImg(end)) '_Row' num2str(i) 'Col' num2str(j) '.mat']);
                % Saving
                save(sout,'A','-v7.3');
        end
    end
    % Saving GridPOD
    s = strcat([OutDir 'TrainingSet\\TS_' OutName '\\' OutName 'TS_b' num2str(b) '_w' num2str(wincorr) '_img_' num2str(NImg(1)) '_' num2str(NImg(end)) '_Grid.mat']);
    save(s,'GridPOD','-v7.3');

else
    fprintf('\nLocal POD already performed!\n')
    s = strcat([OutDir 'TrainingSet\\TS_' OutName '\\' OutName 'TS_b' num2str(b) '_w' num2str(wincorr) '_img_' num2str(NImg(1)) '_' num2str(NImg(end)) '_Grid.mat']);
   %Loading GridPOD
    load(s);
end