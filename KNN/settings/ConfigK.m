%% CONFIGURATION FOR THE COMPUTATION OF K-MAP

OutDirK =  strcat([OutDir 'Minidataset\\' OutName ]);                       % output directory name for testing dataset
NImgMini=1:10;                                                             % vector of snapshots for testing 
FlagLocalSavingK = 0;                                                       % 1 --> enable partial saving 0--> disable partial saving
FlagRestartK = 0;                                                            % 1--> enable reloading of matrix until a specific row ( put it as first_row instead 1) 0--> no restarting
RK = 1:10:bref; RK(end) = bref;                                             % Range of K for Kopt, you can choose manually and decide how much refine (you can modify only the step). Finest vector implies high computational costs, that you can avoid thanks the cubic interpolation.
Kboundary = [1 size(GridPOD.X,1) 1 size(GridPOD.X,2)];                      % number of rows of columns from which extraxct the map, it's in the format [ first_row last_row first_column last_column]. 
                                                                            % Modify it if you need to restart a partial computation of the full map or if you want to compute only a profile and after extend it imposing homogeneity
   