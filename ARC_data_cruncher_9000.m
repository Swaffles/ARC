%ARC flume experiment data crunch
%Purpose: To build a lookup table of means and uncertainty bounds for
%shallow water hydrodynamic forces, moments, and coefficients
%INPUTS: EF### and *_EOD data collections as well as flow speed values from
%Test Matrix
%Operations: 1) Correct data with EOD bias for appropriate
%matching day. 
%2) Calculates the Mean and standard deviation for the data.
%3) Builds a large look up table (format TBD) for visualization and
%computational purposes.
%OUTPUTS: Lookup table with mean, standard deviation, and hydrodynamic
%coefficients for a ground vehicle opporating in shallow water.

clearvars -except homePath dataPath programPath
close all
clc

debug = true;

try 
    addpath(programPath)
catch
    programPath = uigetdir(pwd,'Select GitHub Folder');
    addpath(programPath);
end
try 
    addpath(dataPath)
catch
    dataPath = uigetdir(pwd,'Select University of Iowa\ARC\Flume Experiment\Data');
end

try
    addpath(homePath)
    cd(homePath)
catch
    homePath = uigetdir(pwd,'Select University of Iowa (1)\ARC 2022');
    cd(homePath)
end

savePath = uigetdir(homePath,'Select Folder for Image file Saving');

if ~isfile("HydroData.mat") || debug
    %if running for first time or if debug is on
    noData = true;
    existingData = [];
else
    load('HydroData.mat');
    fprintf("Loading saved data from disc...\n");
    existingData = fieldnames(Arc);
    noData = false; 
end

%gather all the data
cd (dataPath);

%read the exel first
cd ..
testMatrixFile = dir('ARC Test Matrix Fall 2022.xlsx');
% Specify sheet and range
opts = spreadsheetImportOptions("NumVariables", 15);

opts.Sheet = "Sheet1";
opts.DataRange = "A4:O336";

% Specify column names and types
opts.VariableNames = ["TrialName", "WaterDepth", "h/D", "PumpDutyCycle",...
    "PredictedWaterSpeed", "VehicleHeading", "WheelAngle", "Duration",...
    "Flow_U_start", "Flow_U_end", "Ultrasonic", "DOFVehicleForce",...
    "DOFWheelForce", "GoPro", "Comments"];
opts.VariableTypes = ["string", "double", "double", "double",...
    "double", "double", "double", "double",...
    "double", "double", "double", "double",...
    "double", "double", "string"];

% Specify variable properties
opts = setvaropts(opts, "TrialName", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["TrialName", "Comments"], "EmptyFieldRule", "auto");
fprintf('Reading in test matrix file...');
testMatrix = readtable(testMatrixFile.name,opts);

cd (dataPath);
dataFiles = dir('EF*');
dataFileNames = {dataFiles.name};
buoyantFiles = dir('B000*');
buoyantFileNames = {buoyantFiles.name};
%read buoyancy data into data table
%only do this if there's no data or if there's new data
if noData || length(dataFiles)>length(existingData)
    for i = 1:length(buoyantFiles)
        opts = detectImportOptions(buoyantFileNames{i});
        opts.VariableNamingRule = 'modify';
        opts.VariableNamesLine = 8;
        opts.Delimiter = '\t';
        opts.VariableUnitsLine = 6;
        opts.DataLines = 9;
        % Specify file level properties
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        if debug
            fprintf("Building buoyancy table entry for %s\n", buoyantFileNames{i});
        end
        b = readtable(buoyantFileNames{i},opts);
        temp = b.Properties.VariableNames;
        temp2 = strrep(temp,'_','-');
        b = renamevars(b,temp,temp2);
        B.(buoyantFileNames{i}) = meanandstdevARC(b,testMatrix,buoyantFileNames{i},-1,debug);
        B.(buoyantFileNames{i}){[1,2,4,6,7,8,10,12],2} = 0; %zeroing values that are due to load cell drift
    end
end

%read dataFiles into Table for processing
if length(dataFiles)>length(existingData)
    saveMe = true;
    for ind = 1:length(dataFiles)
        if noData
           opts = detectImportOptions(dataFileNames{ind});
           opts.VariableNamingRule = 'modify';
           opts.VariableNamesLine = 8;
           opts.Delimiter = '\t';
           opts.VariableUnitsLine = 6;
           opts.DataLines = 9;
           % Specify file level properties
           opts.ExtraColumnsRule = "ignore";
           opts.EmptyLineRule = "read";
           fprintf("Building data table entry for %s\n", dataFileNames{ind});
           T = readtable(dataFileNames{ind},opts);
           temp = T.Properties.VariableNames;
           temp2 = strrep(temp,'_','-');
           T = renamevars(T,temp,temp2);
           Arc.(dataFileNames{ind}) = meanandstdevARC(T,testMatrix,dataFileNames{ind},B,debug);
        else
            %if the file isn't already a part of T add it
            if ind>length(existingData)
                opts = detectImportOptions(dataFileNames{ind});
                opts.VariableNamingRule = 'modify';
                opts.VariableNamesLine = 8;
                opts.Delimiter = '\t';
                opts.VariableUnitsLine = 6;
                opts.DataLines = 9;
                % Specify file level properties
                opts.ExtraColumnsRule = "ignore";
                opts.EmptyLineRule = "read";
                if debug
                    fprintf("Building data table entry for %s\n", dataFileNames{ind});
                end
                T = readtable(dataFileNames{ind},opts);
                temp = T.Properties.VariableNames;
                temp2 = strrep(temp,'_','-');
                T = renamevars(T,temp,temp2);
                Arc.(dataFileNames{ind}) = meanandstdevARC(T,testMatrix,dataFileNames{ind},B,debug);
            end
        end
        clear T
    end
else
    %diff = length(dataFiles) - length(existingData)
    fprintf("No new files\n");
    saveMe = false;
end

%%
%Saving
cd (homePath);
%get the vars
vars = Arc.EF001{:,"Quantity"};
%save in ARC 2022
if saveMe
    if debug
        fprintf("Saving tables to HydroData.mat...\n");
    end
    save("HydroData.mat","Arc",'-v7.3');
end
clearvars -except Arc vars homePath dataPath programPath savePath debug 
cd(programPath);

%%
%create a figure compiling the data from each test
%one should use a function for plotting forces on y-axis and any other data
%on X, such as heading angle, steering angle, speed, etc.
if debug
    close all
end
%Body Forces
cd(savePath);
for ind = 1:6
    figname = vars{ind};
    f1 = figure("Name",strcat(figname,' v Heading'),'units','normalized','OuterPosition',[0 0 1 1]); %makes full screen size
    label = strcat(figname,' (N)');
    barelabel = figname;
    dims = false; %true for dimensional forces/moments
    forces = true;
    volume = 0.0757; %vehicle volume m^3
    %length = 1.287; %length in m
    if ind>3
        forces = false;
    end
    arcForceFigureMaker(Arc,ind,label,barelabel,dims,forces,volume);
end
cd(programPath);
%%
%Wheel Forces
for ind = 7:12
    figname = vars{ind};
    figname = strrep(figname,'_','-');
    f2 = figure("Name",strcat(figname,' v Heading'));
    label = strcat(figname,' (N)');
    barelabel = figname;
    dims = true;
    forces = true;
    wheel_vol = 0.254^2*pi/4*100; %check wheel width
    if ind>3
        forces = false;
    end
    arcForceFigureMaker(Arc,ind,label,barelabel,dims,forces,wheel_vol);
end

%%
%Force Contour Plots. Heading v. U_inf contours of force for single depth
if debug
    close all
end
for ind = 1:6
    figname = vars{ind};
    f3 = figure("Name",strcat(figname,' Contours, Heading v. Speed'));
    label = strcat(figname,' (N)');
    barelabel = figname;
    dims = true; %true for dimensional forces/moments
    forces = true;
    volume = 0.0757; %vehicle volume m^3
    if ind>3
        forces = false;
    end
    arcContourFigureMaker(Arc,ind,label,barelabel,dims,forces,volume);
end

for ind=7:12
    figname = vars{ind};
    figname = strrep(figname,'_','-');
    f4 = figure("Name",strcat(figname,' Contours, Heading v. Speed'));
    label = strcat(figname,' (N)');
    barelabel = figname;
    dims = true; %true for dimensional forces/moments
    forces = true;
    wheel_vol = 0.254^2*pi/4*100; %check wheel width
    if ind>3
        forces = false;
    end
    arcContourFigureMaker(Arc,ind,label,barelabel,dims,forces,volume);
end

%%
%Force polar plots. Heading as theta, force as radius. Plot different
%speed on same polar plot. New plot for each steering angle
if debug
    close all
end
cd(savePath);
for ind = 1:6
    figname = vars{ind};
    f5 = figure("Name",strcat(figname,' Polar Heading & Speed'));
    label = strcat(figname,' (N)');
    barelabel = figname;
    dims = true; %true for dimensional forces/moments
    forces = true;
    %volume = 0.0757; %vehicle volume m^3
    if ind>3
        forces = false;
    end
    arcPolarFigureMaker(Arc,ind,barelabel,dims,forces,f5);
end
cd(programPath);

%%
%CF v Fr plots
if debug
    close all
end
%Body Forces
for ind = 1:6
    figname = vars{ind};
    figname = strcat('C',figname);
    f6 = figure("Name",strcat(figname,' v Froude Number'));
    label = figname;
    barelabel = vars{ind};
    forces = true; %changed automatically by program
    %function booleans%
    depthBased = true;
    tiles = false;
    excludeShallow = false;
    %function booleans%
    volume = 0.0757; %vehicle volume m^3
    %length = 1.287; %length in m
    if ind>3
        forces = false;
    end
    arcCoefficientForceFigureMaker(Arc,ind,label,barelabel,depthBased,forces,volume,tiles,excludeShallow);
end
%%
%Parallel coordinates plot
if debug
    close all
end
cd(savePath);
for ind = 1:6
    figname = vars{ind};
    f3 = figure("Name",strcat(figname,' Parallel Coordinates'),'units','normalized','OuterPosition',[0 0 1 1]); %makes full screen size
    barelabel = figname;
    dims = true; %true for dimensional forces/moments
    forces = true;
    volume = 0.0757; %vehicle volume m^3
    if ind>3
        forces = false;
    end
    arcParallelCoordinatesFigureMaker(Arc,ind,barelabel,forces,volume);
end
cd(programPath);
%%
%Stacked area force and moment charts
if debug
    close all
end
%Each loop creates a new stacked area chart
%1 = body forces/moments
%2 - Wheel forces/moments
%cd(savePath);
for ind = 1:2
    if ind == 1
        figname = 'Body Forces/Moments';
    elseif ind == 2
        figname = 'Wheel Forces/Moments';
    else
        fprintf("Error Ocurred\n");
        break;
    end
    f1 = figure("Name",strcat(figname,' v Heading'));
    label = strcat(figname,' (N, Nm)');
    barelabel = figname;
    arcStackedForceFigureMaker(Arc,ind,label,barelabel,vars);
end
%cd(programPath);

%%
%Stacked horizontal bar comparison chart
if debug
    close all
end
%Each loop creates a new stacked area chart
%1 = body forces/moments
%2 - Wheel forces/moments
cd(savePath);
for ind = 1:2
    if ind == 1
        figname = 'Body Forces/Moments';
    elseif ind == 2
        figname = 'Wheel Forces/Moments';
    else
        fprintf("Error Ocurred\n");
        break;
    end
    volume = 0.0757; %vehicle volume m^3
    figHeight = 600;
    figWidth = 1.618 *figHeight;
    f1 = figure("Name",strcat(figname,' v Heading'),"Position",[50 50 figWidth figHeight]);
    label = strcat(figname,{' (N, Nm)'});
    tiles = false;
    barelabel = figname;
    arcForceComparisonFigureMaker(Arc,ind,tiles,label,barelabel,vars,volume);
end
cd(programPath);