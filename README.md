# ARC Shallow Water
This repository contains of list of MATLAB tools, functions, files, and a standalone application all for use to compute data related to the 2022-2023 ARC
Shallow water experimental campaign. The testing campaign was carried out at the IIHR Environmental Flume in Iowa City, IA. The goal of the campaign was to 
statically test a model ground vehicle in shallow water conditions to measure the hydrodynamic forces and moments on the model. The model used was the ARC variant 
of the IIHR Model Quadski, a model scale amphibian fitted with four wheels, a V-shaped bottom, and a fairing to more closely mimic a ground vehicle. The Model was 
captively (fully static) mounted on a crossbar fixed both to the floor of the flume as well as to overhead support structure of the flume. The model was hung from
the crossbar on a steel pipe that could be rotated through 180 degrees and locked in place with clamps. A 6 degree-of-freedom load cell was mounted between the tube
and the model to measure the hydrodynamic loads on the model. The model is suspended in free air over a false-floor, a PVC table like structure that was used to
increase the depth of the water in the flume to enable faster flow speeds to be able to be measured. The model's wheels were roughly 1 cm from touching the floor.

Forces and moments were collected for both the vehicle itself and the front port wheel. Test were carried out at nondimensional depths 0.2, 0.4, 0.6, and 0.8 
and are defined by the ratio of the depth of the water to the height of the ground vehicle's wheels. Three flow speeds were conducted at each depth, a slow speed 
at ~0.25 m/s, a medium speed at ~0.50 m/s, and a fast speed between ~0.7 - 0.9 m/s (depending on the depth the pumps were run as fast as possible before significant
air entrainment into the flow would occur, this resulted in the top speeds increasing as the water depth did). Nine vehicle heading angles were also tested at each 
depth ranging from 0 - 180 degrees clockwise (bow to starboard) in increments of 22.5 degrees. Finally the model's front wheels were remotely steering via a remote
control resulting in three steering angles for each depth, speed, and heading, steer to port, center and steer to starboard. This results in a collected data set of
324 unique runs. Additionally, 74 repeat and repetition tests were conducted to measure the repeatability of tests. We show good repeatability test to test, but
repeats of an earlier condition are difficult due to trying to match testing conditions exactly from several weeks prior when things like outside temperatrue affect
the ability to match water deptha and speed conditions exactly.

## Getting Started
### Prerequisites
- MATLAB 2022a or higher (for any of the matlab scripts)
- PC running an operating systems such as Windows 10, Mac OSX, or linux

### Installation (Interpolation Appliction)
1. Navigate to interpolation_app/for_redistribution.
2. Download MyAppInstaller_web.exe, NOTE: you will need administrator privalleges to install the application.
3. The installer will prompt you to download the MATLAB Runtime if it cannot find one on the PC you are installing the application on.
4. Follow all instructions in the installer.
5. To use the file interpolation function you must download ARC_Interpolation_Table.mat, it can be found under interpolation_app/for_redistribution_files_only.

### Installation (Interpolation Function)
1. Clone or download the Interpolation Function folder.
2. Open MATLAB and add the repository folder to the MATLAB path or set it as your working folder
3. You can see how the standalone function, <b>'arcInterpolator.m'</b>, works by running <b>'test_interpolator_script.m'</b>.

### Installation (all other functions or tools)
1. Clone or download the repository.
2. Open MATLAB and add the repository folder and subfolders to the MATLAB path.

## Usage
### MQS_Shallow_Water
The Interpolation Application, <b>MQS_Shallow_Water</b>, is a standalone application that provides a graphical user interface (GUI) for interpolating data point
between the experimental data points collected during the testing campaign. In V0.6, ARC_Interpolation_Table.mat must be downloaded on your machine. The following 
functionalities are available:
- Interpolation between any specified points within the GUI input limits
- Sliders and spinners for accessing single interpolation values
- Checkbox tree to select which loads to return, checking no boxes returns all of the hdyrodynamic loads
- Interpolating from a file of points.
- Saving the output to a text file (space delimited)

### Interpolation Function
The interpolation function, <b>arcInterpolator.m</b>, is a standalone function that allows a developer the ability to rapidly and repeatidly interpolate points
between the experimental samples points from the testing campaign. It is built to be run inside another script (such as is demonstated in 
<b>'test_interpolator_script.m'</b>. The following functionalities are available:
- Interpolation of sample points in batch process or continuous loop.
- Internal function for viewing the Delaunay triangulation. 

### Other Functions
The other MATLAB functions may be used to view and process data from the experiment. Currently the raw data is not made widely available. An update will be added
when the corresponding paper(s) have been published.

## Limitations
### MQS_Shallow_Water.exe
The following are the limitations of the MQS_Shallow_Water application:
- V0.6, you must load in the ARC_Interpolation_Table.mat manually each time the application is opened. This limitation will be fixed in V0.7.
- V0.6, you must press the interpolate button for an interpolated output to be generated.
- V0.6 only supports text files for interpolating from a file and expects the following format, Steering, Heading, Depth, Speed. Values must be between the
limits shown in the GUI, depth and speed must be entered in m and m/s respectively. Values outside of the limits will be capped to the limits, V0.6 only shows a
warning that this has happened but does not tell the user which element in the interpolation file is at fault.
- The GUI slider and spinner tools can be used back to back to interpolate, however, similar functionality is limited for the interpolate from file. Usually,
after you have interpolated from one file the next time the interpolate button is pushed it will interpolate from the GUI tools (sliders). If you wish to interpolate
the same file again you must reload the file into the GUI by pressing the Interpolate from File button and reslecting the file. 
- The save function will always output a text file named <b>'ARC_Interpolated_File.txt'</b>, it's best practice to rename this file if you are going to batch process
several interpolations from file. This limitation will be fixed in V0.7

### arcInterpolator.m
The following are the limitations of the arcInterpolator.m function
- Not gauranteed real time compute. Function runs in less than 0.1 seconds on a Windows 10 machine with Intel(R) Core(TM) i7-8700 CPU @ 3.20GHz and 15.8 GB of 
usable RAM.

## Contributing
Contributions to the ARC Shallow Water are welcome. To contribute:
1. Fork the repository
2. Create a new branch.
3. Make your changes and commit them.
4. Push your changes to your fork.
5. Create a pull request.

## License
This project is licensed under the Apache 2.0 License - see the [LICENSE](https://github.com/Swaffles/ARC/blob/main/LICENSE) file for details.

## Acknowledgements
- The ARC Shallow Water experiment was funded by the U.S. Army Ground Vehicle Research Center in Warren, MI.
