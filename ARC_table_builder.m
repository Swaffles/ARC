%% ARC Flume Experiment data table builder
% The purpose of this program is to read the data from the Hydrodata.mat 
% file created by ARC_data_cruncher_9000 and place it into either a flat 
% data table or a interpolation table. Data table structures are
% shown below.
%
% Flat data table structure:
% N x m table, each row represents a realization, each column represents a
% parameter for the test such as flow speed and Fx
% e.g.
% run name Fx   Fx stdev Fy  Fy stdev Fz   Fz stdev .....
% EFXXX    100  2        4   0.6      310  5.6
%
% Interpolation table structure:
% Nu X Nh X Nbeta X Ndelta. 


clearvars -except homePath dataPath programPath
close all
clc

debug = true;
gravity = 9.81;
length_Scale = 0.0757; %vehicle volume m^3

try 
    addpath(programPath)
catch
    programPath = uigetdir(pwd,'Select GitHub Folder');
    addpath(programPath);
end
try 
    addpath(savePath)
catch
    savePath = uigetdir(homePath,'Select Folder where table should be saved');
end

try
    addpath(homePath)
    cd(homePath)
catch
    homePath = uigetdir(pwd,'Select University of Iowa (1)\ARC 2022');
    cd(homePath)
end

list = {'Falt','Interpolation'};
[indx,tf] = listdlg("ListString",list,"SelectionMode","single",...
    'PromptString',{'Select flat table or','interpolation table output'});
if ~tf
    fprintf("No selection made!");
    TableMode = -1; %will throw error
    return
else
    TableMode = indx; %sets case, flat = 1, interpolation = 2
end

% load data
load('HydroData.mat');
fprintf("Loading saved data from disc...\n");
existingData = fieldnames(Arc);

% begin case structure
switch TableMode
    case -1
        %nothing happens here except the program stops immediately
    case 1
        %flat table
    
        %read in data from table frist. do some calcs too
        fields = fieldnames(Arc);
        for i=1:length(fields)
            yData(i,1) = Arc.(fields{i})(1,2); % mean FX
            yData(i,2) = Arc.(fields{i})(1,5); % stdev Fx
            yData(i,3) = Arc.(fields{i})(2,2); % mean Fy
            yData(i,4) = Arc.(fields{i})(2,5); % stdev Fy
            yData(i,5) = Arc.(fields{i})(3,2); % mean Fz
            yData(i,6) = Arc.(fields{i})(3,5); % stdev Fz
            yData(i,7) = Arc.(fields{i})(4,2); % mean Mx
            yData(i,8) = Arc.(fields{i})(4,5); % stdev Mx
            yData(i,9) = Arc.(fields{i})(5,2); % mean My
            yData(i,10) = Arc.(fields{i})(5,5); % stdev My
            yData(i,11) = Arc.(fields{i})(6,2); % mean Mz
            yData(i,12) = Arc.(fields{i})(6,2); % stdev Mz
            %other parameters
            temp1 = Arc.(fields{i}){13,2}/100; % mean water depth [m]
            yData(i,13) = {temp1};
            temp2 = Arc.(fields{i}){13,5}/100; % stdev water depth [m]
            yData(i,14) = {temp2};
            yData(i,15) = Arc.(fields{i})(15,2); % heading
            yData(i,16) = Arc.(fields{i})(16,2); % steering
            temp3 = Arc.(fields{i}){17,2}/100; % mean flow speed [m/s]
            yData(i,17) = {temp3};
            temp4 = Arc.(fields{i}){17,5}/100; % stdev flow speed [m/s]
            yData(i,18) = {temp4};

            %yData(i,11) = Arc.(fields{i})(18,2); %target flow speed
            %yData(i,12) = Arc.(fields{i})(19,2); %h/D
            FrH = Arc.(fields{i}){17,2}/(sqrt(gravity*yData{i,13}));
            Sr = Arc.(fields{i}){17,2}/(length_Scale^1/3);
            FrHSr = FrH*sqrt(Sr);
            yData(i,19) = {round(FrHSr,2,"significant")};
            yData(i,20) = {round(Sr,2,"decimals")};
        end
        yData.Properties.VariableNames = {'Mean Fx [N]','Std Fx [N]',...
            'Mean Fy [N]','Std Fy [N]','Mean Fz [N]','Std Fz [N]',...
            'Mean Mx [Nm]','Std Mx [Nm]','Mean My [Nm]','Std My [Nm]',...
            'Mean Mz [Nm]','Std Mz [Nm]','Mean Water Depth [m]','Std Water Depth [m]',...
            'Heading [deg]','Steering [deg]','Mean Flow Speed [m/s]',...
            'Std Flow Speed [m/s]','FrH','Sr'};

        %TODO need to extract the repeats in the table and recalculate the
        %mean and standard deviation for those conditions

    case 2
        %interpolation table
end
