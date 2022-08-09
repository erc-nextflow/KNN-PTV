% Code from: "An end-to-end KNN-based PTV approach for high-resolution measurements and uncertainty quantification"
% Authors: I.Tirelli, A.Ianiro, S.Discetti.
% Version 1.001 of 16/05/2022


% This is the main file, it calls all the other function necessary for the
% computation 

clc, clear, close all
fprintf('Starting\n');
addpath('.\settings\')                                                     % path of the folder with the setting files
addpath('.\function\')                                                     % path of the folder with the functions
addpath('.\function\KDTREE')                                               % path of the folder with the KD TREE functions                                                   % path of the folder with the setting files
addpath('.\Input')     
%% SETTING FILE
ConfigurationKNN_PTV;
mkdir(OutDir)  
addpath(OutDir)   
%% ALGORITHM
%% STEP 1
%counting particles for N_PPP estimation
Np=0;
for i=NImg
    Np=Np+numel(PTV.X{i});
end
% computing particles density per pixel
Nppp=Np/numel(NImg)/H/W;
%% STEP 2 
% computing bin size for reference distribution (Eq.1) 
bref=ceil(sqrt(npb/Nppp));                                                 % bin size for reference distribution
Interpolate_weighted_average(PTV,Ndig,NImg,bref,OutDir,OutName,X,Y);       % function for building the reference matrix
%% STEP 3
% Performing local POD and computing training set
[GridPOD] = LocalPODBinnedPTV(OutDir,OutName,bref,Ndig,NImg,wincorr,X,wspac); % function for performing local POD
%% STEP 4
% Computing K-map
ComputeK_main;
% computing target particle density
NpppHR=Nppp*Kmap;                                                           % particles density artificially increased by K
% computing HR bin size
bHR=(sqrt(npb./NpppHR));                                                     % HR bin size, assuming npb particles per bin
%% STEP 5
boundary = [1 size(GridPOD.X,1) 1 size(GridPOD.X,2)];                       % number of rows of columns for the reconstruction of HR snapshots, it's in the format [ first_row last_row first_column last_column]. 
                                                                            % Modify it if you need to restart a partial computation of the full snapshot.
KNNreconstruction(OutDir,OutName,Ndig,NImgR,NImg,bHR,Kmap,wincorr,PTV,X,Y,GridPOD,bref,dx,FlagRestart,FlagLocalSaving,boundary)
                                                                            
