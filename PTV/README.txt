Simple code for PTV from raw images.

This folder contains two different MATLAB codes:
 1:README.txt - text file with the description of the code and instructions
 2: MainPIV_PTV.m - main file containing the entire algorithm
 3: ConfigInput_PIV_PTV: configuration file
 4: Output: PTV snapshots
 5: Input/img: folder with the raw pictures


Instructions:

1) Copy the PIV pictures in Input/img
2) Check the configuration file following the example, to work automatically with the KNN part of the code it's important that 
the OutputName in this code coincide with the InputName of the other one.
3) Run the main.
4) In Output there are the .plt, in Output/'OutName'/PTV_Snapshots there are the all the PTV fields, you can drag and drop the entire folder in KNN/Input/'OutName'/PTV_Snapshots.
If you prefer, you can modify line 85 and assign to the variable RootPTV the address of the folder.