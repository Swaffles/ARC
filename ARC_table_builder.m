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
% Replicated or repeated data are subsorted and reduced to the original run
% by taking the mean of all values down the relevant columns.
%
% Interpolation table structure:
% Nu X Nh X Nbeta X Ndelta cell array. Each element of the cell array
% contains all of the values for that parameter. 
% e.g.
% {1,:,:,:} represents all of the test conditions for the first index of
% water speed as a matrix. {:,1,:,:} contains all test conditions for the 
% first index of water depth again as a matrix. 
%
% though there are repeated values in each matrix, more efficient search is
% possible with this structure.


clearvars -except homePath dataPath programPath
close all
clc

debug = true;
gravity = 9.81;
length_Scale = 0.0757; % vehicle volume m^3

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
    fprintf("No selection made!\n");
    TableMode = -1; % will throw error
    return
else
    TableMode = indx; % sets case, flat = 1, interpolation = 2
end

% load data
load('HydroData.mat');
fprintf("Loading saved data from disc...\n");
existingData = fieldnames(Arc);

% begin case structure
switch TableMode
    case -1
        % nothing happens here except the program stops immediately
    case 1
        % flat table
    
        % read in data from table frist. do some calcs too
        fields = fieldnames(Arc);
        tableSize = [length(existingData), 23];
        varTypes = {'string','double','double','double','double','double',...
            'double','double','double','double','double','double','double',...
            'double','double','double','double','double','double','double',...
            'double','double','double'};
        varNames = {'Run Name','Mean Fx [N]','Std Fx [N]',...
            'Mean Fy [N]','Std Fy [N]','Mean Fz [N]','Std Fz [N]',...
            'Mean Mx [Nm]','Std Mx [Nm]','Mean My [Nm]','Std My [Nm]',...
            'Mean Mz [Nm]','Std Mz [Nm]','Mean Water Depth [m]','Std Water Depth [m]',...
            'Heading [deg]','Steering [deg]','Mean Flow Speed [m/s]',...
            'Std Flow Speed [m/s]','FrH','Sr','Target Flow Speed [m/s]','H/D'};
        yData = table('Size',tableSize,'VariableTypes',varTypes,'VariableNames',varNames);
        for i=1:length(fields)
            yData(i,1) = fields(i);
            yData(i,2) = Arc.(fields{i})(1,2); % mean FX
            yData(i,3) = Arc.(fields{i})(1,5); % stdev Fx
            yData(i,4) = Arc.(fields{i})(2,2); % mean Fy
            yData(i,5) = Arc.(fields{i})(2,5); % stdev Fy
            yData(i,6) = Arc.(fields{i})(3,2); % mean Fz
            yData(i,7) = Arc.(fields{i})(3,5); % stdev Fz
            yData(i,8) = Arc.(fields{i})(4,2); % mean Mx
            yData(i,9) = Arc.(fields{i})(4,5); % stdev Mx
            yData(i,10) = Arc.(fields{i})(5,2); % mean My
            yData(i,11) = Arc.(fields{i})(5,5); % stdev My
            yData(i,12) = Arc.(fields{i})(6,2); % mean Mz
            yData(i,13) = Arc.(fields{i})(6,2); % stdev Mz
            % other parameters
            temp1 = Arc.(fields{i}){13,2}/100; % mean water depth [m]
            yData(i,14) = {temp1};
            temp2 = Arc.(fields{i}){13,5}/100; % stdev water depth [m]
            yData(i,15) = {temp2};
            yData(i,16) = Arc.(fields{i})(15,2); % heading
            yData(i,17) = Arc.(fields{i})(16,2); % steering
            temp3 = Arc.(fields{i}){17,2}/100; % mean flow speed [m/s]
            yData(i,18) = {temp3};
            temp4 = Arc.(fields{i}){17,5}/100; % stdev flow speed [m/s]
            yData(i,19) = {temp4};

            % flow speed
            FrH = yData{i,18}/(sqrt(gravity*yData{i,14}));
            Sr = yData{i,18}/(length_Scale^1/3);
            FrHSr = FrH*sqrt(Sr);
            yData(i,20) = {round(FrHSr,2,"significant")};
            yData(i,21) = {round(Sr,2,"decimals")};
            yData(i,22) = Arc.(fields{i})(18,2); % target flow speed
            yData(i,23) = Arc.(fields{i})(19,2); % h/D
            
        end
        fprintf("YData table created!\n");
        fprintf("Subsorting and reducing repeats\n")
        % Extract the repeats in the table and recalculate the mean and 
        % standard deviation for those conditions. Uses the heading, target
        % flow speed, and H/D to find the indecies
        depths = unique(yData{:,"H/D"});
        count = 1;
        for i=1:length(depths)
            indD = yData{:,"H/D"} == depths(i); 
            yData1{i} = yData(indD,:);
            speeds = unique(yData1{i}{:,"Target Flow Speed [m/s]"});
            for j = 1:length(speeds)
                indS = yData1{i}{:,"Target Flow Speed [m/s]"} == speeds(j);
                yData2{j} = yData1{i}(indS,:);
                steering = unique(yData2{j}{:,"Steering [deg]"});
                for k = 1:length(steering)
                    indSt = yData2{j}{:,"Steering [deg]"} == steering(k);
                    yData3{count} = yData2{j}(indSt,:);
                    % for repeat headings we need to average the values
                    % across all the rows
                    [GC,GR] = groupcounts(yData3{count}{:,"Heading [deg]"});
                    if any(GC>1)
                        % there are repeats, identify the value
                        indGC = find(GC>1);
                        valueGR = GR(indGC); % this may be larger than 1 value
                        % find corresponding row from yData3
                        for a = 1:length(valueGR)
                            rowsYData3 = find(yData3{count}{:,"Heading [deg]"}==valueGR(a));
                            temp = yData3{count}(rowsYData3,:);
                            yData3{count}(rowsYData3,:) = []; % deletes the rows
                            % average all the cols
                            mu = mean(temp{:,2:end},1); % 2:end ignores the string
                            % find the original run name that was
                            % replicated or repeated
                            %name = strfind(temp{:,1},"EFR");
                            name = 1; % original EF always first
                            newYData3row = temp(1,:);
                            newYData3row{1,1} = temp{name,1}; %should write to the correct place
                            newYData3row{1,2:end} = mu;
                            yData3{count}(end+1,:) = newYData3row;
                        end
                        yData3{count} = sortrows(yData3{count},'Heading [deg]');
                    end
                    count = count + 1;
                end % k for loop
            end % j for loop
        end % i for loop
        fprintf("Concatenating yData3 tables\n");
        yData(:,:) = []; %deletes values in array
        yData = yData3{1};
        for i = 2:length(yData3) 
            yData = [yData;yData3{i}]; 
        end
        yData = sortrows(yData,'Run Name');
        save("HydroData_FLAT","yData",'-v7.3');
        fprintf("YData successfully saved to %s as HydroData_FLAT.m\n",pwd);
        clearvars -except homePath dataPath programPath Arc yData savePath

    case 2
        % interpolation table
        
        % read in values from flat table
        load HydroData_FLAT.mat %loads in as yData
        Uvel = unique(yData{:,"Mean Flow Speed [m/s]"});
        Nu = length(Uvel);
        Depth = unique(yData{:,"Mean Water Depth [m]"});
        Nh = length(Depth);
        Heading = unique(yData{:,"Heading [deg]"});
        Nb = length(Heading);
        Steering = unique(yData{:,"Steering [deg]"});
        Ns = length(Steering);
        fprintf("Creating empty interpHydro cell array...\n");
        interpHydro = struct;
        for i = 1:Nu
            indU = yData{:,"Mean Flow Speed [m/s]"} == Uvel(i);
            find(indU)
            interpHydro.Velocity{1,i} = Uvel(i);
            interpHydro.Velocity{2,i} = yData(indU,2:end);
        end
        for i = 1:Nh
            indH = yData{:,"Mean Water Depth [m]"} == Depth(i);
            find(indH)
            interpHydro.Depth{1,i} = Depth(i);
            interpHydro.Depth{2,i} = yData(indH,2:end);
        end
        for i = 1:Nb
            indB = yData{:,"Heading [deg]"} == Heading(i);
            find(indB)
            interpHydro.Heading{1,i} = Heading(i);
            interpHydro.Heading{2,i} = yData(indB,2:end);
        end
        for i = 1:Ns
            indS = yData{:,"Steering [deg]"} == Steering(i);
            find(indS)
            interpHydro.Steering{1,i} = Steering(i);
            interpHydro.Steering{2,i} = yData(indS,2:end);
        end
        % 4-17-22 I don't think the cell array will work...too confusing to
        % build, memory inefficient, don't think lookups/interpolations
        % will actually be that fast
%         interpHydro = cell(Nu,Nh,Nb,Ns);
%         for i=1:Nu
%             indU = yData{:,"Mean Flow Speed [m/s]"} == Uvel(i);
%             find(indU)
%             interpHydro{i,1,1,1} = yData(indU,2:end);
%             interpHydro(i,1,1,1)
%         end
%         for i = 1:length(Nh)
%             indH = yData{:,"Mean Water Depth [m]"} == Depth(i);
%             interpHydro{1,i,1,1} = yData(indH,2:end);
%         end
%         for i = 1:length(Nb)
%             indB = yData{:,"Heading [deg]"} == Heading(i);
%             interpHydro{1,1,i,1} = yData(indB,2:end);
%         end
%         for i = 1:length(Ns)
%             indS = yData{:,"Steering [deg]"} == Steering(i);
%             interpHydro{1,1,1,i} = yData(indS,2:end);
%         end

end
