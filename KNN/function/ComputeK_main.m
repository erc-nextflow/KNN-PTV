% Code for computing the K-map: the domain is split in subdomain and for
% each of them is computed the value of K that minimise the uncertainty.
% The process is carried out on a small dataset for a certain number of K,
% the oprimal is extrapolated thanks a cubic interpolation.
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022


%% STARTING
% create folder for the minidataset
mkdir(sprintf('%sMinidataset\\%s\\',OutDir,OutName));
% name of the K-map file
s= strcat([OutDir 'Minidataset\\' OutName '\\' OutName 'Kmap.mat']);
% check if the map is already available
if ~isfile(s)
    %% CONFIGURATION
    ConfigK;
    tic
%% GENERATION OF MINIDATASET
    Minidatasetgenerator(OutDirK,OutDir,OutName,Ndig,NImgMini,NImg,GridPOD,RK,wincorr,PTV,X,Y,bref,dx,FlagRestartK,FlagLocalSavingK,Kboundary,npb,Nppp)
    toc

%% COMPUTING THE MINIMUM OF UNCERTAINTY
    tic
    % pre-allocation in memory
    sout=sprintf(strcat([OutDirK '\\LOCAL_w' num2str(wincorr) '_K' num2str(1) '\\' OutName '_K' num2str(1) '_%0' num2str(Ndig) 'd.mat']),1);
    load(sout,'UKNN');
    [Hv,Wv,~]=size(UKNN);
    Nvx=floor(Wv/wspac);                                                   % number of rows
    Nvy=floor(Hv/wspac);                                                   % number of columns
    Nt = NImgMini;                                                         % number of snapshots
    Kmap = zeros(Nvy,Nvx);                                                 % map of K
    SU = zeros([size(UKNN),numel(Nt),numel(RK)]);                           % standard deviation along U
    SV = SU;                                                               % standard deviation along V 
    UNC = SU;                                                              % uncertainty

    cont = 1;
    %for each K
    for K = RK
        sprintf(' K = %f',K)
        % for each snapshot
        for z = Nt
            %computing  standard deviation matrices
            sout=sprintf(strcat([OutDirK '\\LOCAL_w' num2str(wincorr) '_K' num2str(K) '\\' OutName '_K' num2str(K) '_%0' num2str(Ndig) 'd.mat']),z);
            load(sout,'stdu','stdv');
            stdu(isinf(stdu)) = 0;
            stdv(isinf(stdv)) = 0;
            SU(:,:,z,cont) = stdu;
            SV(:,:,z,cont) = stdv;
        end
        %computing  uncertainty matrix
        UNC(:,:,:,cont) = SU(:,:,:,cont).^2 + SV(:,:,:,cont).^2;
        cont = cont + 1;
    end
    
    %removing empty spots
    UNC(find(UNC ==0)) = nan;
 
    Kspline=1:max(RK);                                                      % spline of K values
   % for each row
    for i=1:Nvy
        %for each column
         for j=1:Nvx
            fprintf('ROW = %d of %d \t COL = %d of %d \n',i,Nvy,j,Nvx)
            % computing indexes
            i0=floor(1+(i-1)*wspac);                                       % first row index
            j0=floor(1+(j-1)*wspac);                                       % first column index
            II=i0:min([i0+wincorr-1 Hv]);                                  % row indexes
            JJ=j0:min([j0+wincorr-1 Wv]);                                  % column indexes
            for K = 1:numel(RK)
                unc = sqrt(nanmean(UNC(II,JJ,:,K),3));                     % local uncertainty for specific K averaged on snapshots 
                uncK(K) = nanmean(unc(:));                                 % local uncertainty for each K averaged on number of point
            end
            % spline of uncertainty values
            [uncspline]=interp1(RK,uncK,Kspline,'cubic');
            %search of minimum
            [val,idx] = min(uncspline);
            %computing K-map
            Kmap(i,j) = Kspline(idx);

        end
    end
      % saving Kmap
      fprintf('Saving map...\n')
      save(s,'Kmap','-v7.3');
      fprintf('Saved!\n')
    toc
else
     fprintf('Map already computed!Loading...\n')
    % loading Kmap
    load(s);
    fprintf('Loaded!\n')
end

