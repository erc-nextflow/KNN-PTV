Sample code supporting the scientific paper titled: 
 - "An end-to-end KNN-based PIV approach for high-resolution measurements and uncertainty quantification"
 - Authors: I.Tirelli, A.Ianiro, S.Discetti.
 - Corresponding author: iacopo.tirelli@uc3m.es

This folder contains:
 1:README.txt - text file with the description of the code and instructions
 2: KNNPTV_main.m - main file containing the entire algorithm
 3: settings: folder containing the configuration file for the testcase (three different example, analysed in the paper) and for the neighbours search
 4: Output: folder with the output of the algorithm. Subfolder:
 	4.1: KNN_PTV: HR fields and uncertainty estimation, sorted by different test case and configuration
	4.2: Minidataset: testing set for the evaluation of the optimal K sorted by different test case and K value
	4.3: TrainingSet: training set sorted by different test case and configuration
	4.4: WA_PTV: reference binned distribution
(Note that all these folders will appear after the first use of the algorithm)
 5: Input: PTV snapshots and grid, must be in the format X_points x Y points 



Instruction:

0:  Run the matlab file PrepWorkspace.m in order to prepare the workspace, it is useful especially if you need to import datasets, otherwise you can only create a folder following the path in 
step 1 and the code will generate all the others.
1: The path of the PTV snapshots should be Input/InputName/PTVSnapshots. You can: drag and drop the entire folder from the PTV software; import the correponding dataset available on zenodo 
(drag and drop the entire folder PTV_Snapshots and open the matlab file to convert the .hd5 into .m file, just play run); import your own snapshots.
2: Check all the configuration file in the folder settings following the template available, for the testcase configuration and the optimal K computation.
3: Run the main code.


The codes use a k-d tree function from Andrea Tagliasacchi: https://github.com/ataiya/kdtree
