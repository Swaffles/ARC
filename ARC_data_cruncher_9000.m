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

clearvars -except homePath dataPath
close all
clc

debug = true;


try 
    addpath(dataPath)
catch
    dataPath = uigetdir('Select University of Iowa\ARC\Flume Experiment\Data');
end

try
    addpath(homePath)
catch
    homePath = uigetdir('Select University of Iowa (1)\ARC 2022');
    cd(homePath)
end

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
opts.DataRange = "A4:O327";

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
%strip _EOD from eodFileNames
dataFileDates = {dataFiles.date}; %matrix ind aligns with ind in dataFiles

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
           Arc.(dataFileNames{ind}) = meanandstdevARC(T,testMatrix,dataFileNames{ind},debug);
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
                Arc.(dataFileNames{ind}) = meanandstdevARC(T,testMatrix,dataFileNames{ind},debug);
            end
        end
        clear T
    end
else
    %diff = length(dataFiles) - length(existingData)
    fprintf("No new files\n");
    saveMe = false;
end



%% BIAS for Buoyancy
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 12-6-22 Section is currently setup for EOD biasing, this will either be
% adapted or the buoyancy data will be added as a seperate row in the ARC
% table
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd(dataPath);
% fields = fieldnames(T.(dataFileNames{1}));
% %can either be done as an uncertainty or add(subtract) as a bias (mean/2)
% %12-5-22 choosing to add as a bias (mean/2)
% if length(dataFiles)>length(existingData)
%     for i=1:length(existingData)+1:length(existingData)+length(fields)
%         if debug
%             fprintf("Correcting data values for %s\n",dataFileNames{i});
%         end
%         unCorrectedData = T.(dataFileNames{i});
%         fields = fieldnames(T.(dataFileNames{i}));
%         fields = fields(2:end-3);
%         ind =ismember(eodFileNamesShort,dataFileDates{i});
%         for j = 1:length(ind)
%             if ind(j) == 0
%                 continue
%             else
%                 opts = detectImportOptions(eodFileNames{j});
%                 opts.VariableNamingRule = 'modify';
%                 opts.VariableNamesLine = 8;
%                 opts.Delimiter = '\t';
%                 opts.VariableUnitsLine = 6;
%                 opts.DataLines = 9;
%                 % Specify file level properties
%                 opts.ExtraColumnsRule = "ignore";
%                 opts.EmptyLineRule = "read";
%                 CorrectingData = readtable(eodFileNames{j});
%                 for k = 1:length(fields)
%                     M = mean(CorrectingData.(fields{k}),'omitnan');
%                     temp1 = mean(T.(dataFileNames{j}).(fields{k}));
%                     T.(dataFileNames{j}).(fields{k}) = T.(dataFileNames{j}).(fields{k}) - M/2; %half of the mean
%                     if debug
%                         fprintf("Correcting data values of %s for %s with %.2f\n",fields{k},dataFileNames{j},M)
%                         temp2 = mean(T.(dataFileNames{j}).(fields{k}));
%                         fprintf("Mean of %s for %s changed from %.2f to %.2f\n",...
%                             fields{k},dataFileNames{j}, temp1, temp2);
%                     end
%                 end
%             end
%         end
%     end
% end
% clear temp1 temp2 M fields

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
clearvars -except Arc vars homePath dataPath debug

%%
%create a figure compiling the data from each test
%one should use a function for plotting forces on y-axis and any other data
%on X, such as heading angle, steering angle, speed, etc.
if debug
    close all
end
%Body Forces
for ind = 1:6
    figname = vars{ind};
    f1 = figure("Name",strcat(figname,' v Heading'));
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
close all
for ind = 1:6
    figname = vars{ind};
    f5 = figure("Name",strcat(figname,' Polar Heading & Speed'));
    label = strcat(figname,' (N)');
    barelabel = figname;
    dims = true; %true for dimensional forces/moments
    forces = true;
    volume = 0.0757; %vehicle volume m^3
    if ind>3
        forces = false;
    end
    arcPolarFigureMaker(Arc,ind,label,barelabel,dims,forces,volume,f5);
end