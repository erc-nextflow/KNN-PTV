% Code for PTV on PIV pictures
% Code from: "An end-to-end KNN-based PTV approach for high-resolution measurements and uncertainty quantification"
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022


% clc, clear, close all
addpath('.\function_PTV\')
% ConfigInput_PIV_PTV;

%% Computing statistics for SR approach (Keane et al., 1995)
if strcmp(FlagSR,'YES')
    addpath('.\function_PTV\kdtree\')
    s=sprintf('%sImStat_Img%d_%d.mat',OutDir,SR.ImStat(1),SR.ImStat(end));
    if isfile(s)
        load(s)
    else
        [MeanImgA, STDImgA, MeanImgB, STDImgB]=CalcStatImg(SR.ImStat,FileName,ROI,Ndig);
        save(s,'MeanImgA','STDImgA','MeanImgB','STDImgB')
    end
    h=fspecial('Gaussian',[30 30],5);
    MeanImgA=imfilter(MeanImgA,h);MeanImgB=imfilter(MeanImgB,h);
    STDImgA=imfilter(STDImgA,h);STDImgB=imfilter(STDImgB,h);
end

%% Starting PTV
f = waitbar(0,'1','Name','Computing PTV...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);
cont=0;
N=numel(NImg);
t1=cputime;

mkdir(sprintf(strcat(['.\\Output\\' OutName '\\PTV_Snapshots'])));
for i=NImg
    fprintf('***************************\n')
    fprintf('***************************\n')
    % Reading Input from PIV pictures
    fprintf('Reading input %d of %d ...\n',i,numel(NImg))
    [ImgA,ImgB]=ReadInput2F(FileName,Ndig,i,ROI);
    % Computing predictor for validation
    fprintf('Computing predictor...\n')
    tic;[XP,YP,UP,VP,Fc,SN,Info]=Predictor2F(ImgA,ImgB,IW(1),Ov(1),ValPar);toc
    fprintf('Average Fc = %1.3f\n',mean(Fc(:)));
    if FlagOutIter==1
        Output(sprintf('%s%s_predictor_img%06d.plt',OutDir,OutName,i),XP,YP,UP,VP,Fc,SN,Info);
    end
    
    if numel(IW)>1
        for iter=2:length(IW)
            fprintf('\n\nIter %d of %d \t IW=%d\t Overlap %d%%\n',iter,length(IW),IW(iter),Ov(iter)*100);
            tic
            % smoothing predictor
            [Up,Vp]=smooth_predictor(UP,VP);
            % performing image deformation
            [ImgAd,ImgBd,Ud,Vd]=DewarpImages2F(ImgA,ImgB,Up,Vp,XP,YP);
            Xp=XP; Yp=YP;
            % updating velocity vectors
            [XP,YP,UP,VP,Fc,SN]=Corrector(ImgAd,ImgBd,IW(iter),Ov(iter));
            [UP,VP]=UpdateVelocity(Ud,Vd,UP,VP,XP,YP,IW(iter));
            % performing cross validation
            [UP,VP,Info]=Validation(UP,VP,XP,YP,ValPar);
            
            fprintf('Average Fc = %1.3f\n',mean(Fc(:)));
            if FlagOutIter==1
                Output(sprintf('%s%s_img%06d_iter%d.plt',OutDir,OutName,i,iter),XP,YP,UP,VP,Fc,SN,Info);
            end
            toc
        end
    end
%     Output(sprintf('%splt\\%s_%06d.plt',OutDir,OutName,i),X,Y,U,V,Fc,SN,Info);
    Output(sprintf('%s%s_%06d.plt',OutDir,OutName,i),XP,YP,UP,VP,Fc,SN,Info);
    
    if i==NImg(1)
        mkdir(sprintf(strcat(['.\\Output\\' OutName '\\PTV_Snapshots'])));
        % saving grid
        save(sprintf('%sGrid_%s',OutDir,OutName),'XP','YP')
    end
    
    if strcmp(FlagSR,'YES')
        % performing SR PTV
        [X,Y,U,V]=PTV_2F(ImgA,ImgB,MeanImgA,MeanImgB,STDImgA,STDImgB,XP,YP,UP,VP);
        %         PTV.X{i} = XP; PTV.Y{i} = YP; PTV.U{i} = UP; PTV.V{i} = VP;
        RootPTVSnapshot = sprintf(strcat(['.\\Output\\' OutName '\\PTV_Snapshots\\PTVSnapshot_%0' num2str(Ndig) 'd.mat']),i);  % Root of the PTV snapshots
        save(RootPTVSnapshot,'X','Y','U','V')
        
    end
    cont=cont+1;
    t2=cputime;
    waitbar(cont/N,f,sprintf('%1.1fs to finish',(t2-t1)/cont*(N-cont)))
    
end
delete(f)
clear X Y;
X = XP; Y = YP;
% saving grid
mkdir(sprintf('.\\Output\\%s\\PTV_Snapshots\\Grid',OutName,OutName));
RootGrid = sprintf('.\\Output\\%s\\PTV_Snapshots\\Grid\\Grid_%s.mat', OutName,OutName); % Root of the grid
save(RootGrid,'X','Y')
