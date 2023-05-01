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
% Nu X Nh X Nbeta


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
    addpath(homePath)
    cd(homePath)
catch
    homePath = uigetdir(pwd,'Select University of Iowa (1)\ARC 2022');
    cd(homePath)
end
try 
    addpath(savePath)
catch
    savePath = uigetdir(homePath,'Select Folder where table should be saved');
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
        tableSize = [length(existingData), 22];
        varTypes = {'string','double','double','double','double','double',...
                    'double','double','double','double','double','double',...
                    'double','double','double','double','double','double',...
                    'double','double','double','double'};
        varNames = {'Run Name','Fx [N]','Fy [N]','Fz [N]','Mx [Nm]',...
                    'My [Nm]','Mz [Nm]','Wheel Fx [N]','Wheel Fy [N]',...
                    'Wheel Fz [N]','Wheel Mx [N]','Wheel My [N]',...
                    'Wheel Mz [N]','Water Depth [m]','Port Steering [deg]',...
                    'Flow Speed [m/s]','Heading [deg]','FrH','Sr',...
                    'Target Flow Speed [m/s]','H/D','WheelAngle'};
        yData = table('Size',tableSize,'VariableTypes',varTypes,'VariableNames',varNames);
        A = struct;
        for j = 1:4
            if j == 1
                item = 2; % select total
                yData.Properties.VariableNames = {'Run Name','Total Fx [N]','Total Fy [N]',...
                    'Total Fz [N]','Total Mx [Nm]','Total My [Nm]',...
                    'Total Mz [Nm]','Total Wheel Fx [N]','Total Wheel Fy [N]',...
                    'Total Wheel Fz [N]','Total Wheel Mx [N]','Total Wheel My [N]',...
                    'Total Wheel Mz [N]','Water Depth [m]','Port Steering [deg]',...
                    'Flow Speed [m/s]','Heading [deg]','FrH','Sr',...
                    'Target Flow Speed [m/s]','H/D','WheelAngle'};
            elseif j == 2
                item = 3; % select dynamic
                yData.Properties.VariableNames = {'Run Name','Dynamic Fx [N]','Dynamic Fy [N]',...
                    'Dynamic Fz [N]','Dynamic Mx [Nm]','Dynamic My [Nm]',...
                    'Dynamic Mz [Nm]','Dynamic Wheel Fx [N]','Dynamic Wheel Fy [N]',...
                    'Dynamic Wheel Fz [N]','Dynamic Wheel Mx [N]','Dynamic Wheel My [N]',...
                    'Dynamic Wheel Mz [N]','Water Depth [m]','Port Steering [deg]',...
                    'Flow Speed [m/s]','Heading [deg]','FrH','Sr',...
                    'Target Flow Speed [m/s]','H/D','WheelAngle'};
            elseif j == 3
                item = 4; % select hydrostatic
                yData.Properties.VariableNames = {'Run Name','Hydrostatic Fx [N]','Hydrostatic Fy [N]',...
                    'Hydrostatic Fz [N]','Hydrostatic Mx [Nm]','Hydrostatic My [Nm]',...
                    'Hydrostatic Mz [Nm]','Hydrostatic Wheel Fx [N]','Hydrostatic Wheel Fy [N]',...
                    'Hydrostatic Wheel Fz [N]','Hydrostatic Wheel Mx [N]','Hydrostatic Wheel My [N]',...
                    'Hydrostatic Wheel Mz [N]','Water Depth [m]','Port Steering [deg]',...
                    'Flow Speed [m/s]','Heading [deg]','FrH','Sr',...
                    'Target Flow Speed [m/s]','H/D','WheelAngle'};
            else
                item = 5; % select stdev
                yData.Properties.VariableNames = {'Run Name','STDEV Fx [N]','STDEV Fy [N]',...
                    'STDEV Fz [N]','STDEV Mx [Nm]','STDEV My [Nm]',...
                    'STDEV Mz [Nm]','STDEV Wheel Fx [N]','STDEV Wheel Fy [N]',...
                    'STDEV Wheel Fz [N]','STDEV Wheel Mx [N]','STDEV Wheel My [N]',...
                    'STDEV Wheel Mz [N]','Water Depth [m]','STDEV Port Steering [deg]',...
                    'Flow Speed [m/s]','Heading [deg]','FrH','Sr',...
                    'Target Flow Speed [m/s]','H/D','WheelAngle'};
            end
            for i=1:length(fields)
                yData(i,1) = fields(i);
                yData(i,2) = Arc.(fields{i})(1,item); % FX
                yData(i,3) = Arc.(fields{i})(2,item); % Fy
                yData(i,4) = Arc.(fields{i})(3,item); % Fz
                yData(i,5) = Arc.(fields{i})(4,item); % Mx
                yData(i,6) = Arc.(fields{i})(5,item); % My
                yData(i,7) = Arc.(fields{i})(6,item); % Mz
                yData(i,8) = Arc.(fields{i})(7,item); % Wheel Fx
                yData(i,9) = Arc.(fields{i})(8,item); % Wheel Fy
                yData(i,10) = Arc.(fields{i})(9,item); % Wheel Fz 
                yData(i,11) = Arc.(fields{i})(10,item); % Wheel Mx
                yData(i,12) = Arc.(fields{i})(11,item); % Wheel My
                yData(i,13) = Arc.(fields{i})(12,item); % Wheel Mz
                % other parameters
                temp1 = Arc.(fields{i}){13,item}/100; % mean water depth [m]
                yData(i,14) = {temp1};
                yData(i,15) = Arc.(fields{i})(14,item); % Port steering
                temp3 = Arc.(fields{i}){17,item}/100; % mean flow speed [m/s]
                yData(i,16) = {temp3};
                yData(i,17) = Arc.(fields{i})(15,2); % heading
                % non dimensional
                FrH = yData{i,16}/(sqrt(gravity*yData{i,14})); % V/sqrt(g*depth)
                Sr = yData{i,14}/(length_Scale^1/3); % depth/Vol^1/3
                FrHSr = FrH*sqrt(Sr);
                yData(i,18) = {round(FrHSr,2,"significant")};
                yData(i,19) = {round(Sr,2,"decimals")};
                % internal sorting use
                yData(i,20) = Arc.(fields{i})(18,2); % target flow speed
                yData(i,21) = Arc.(fields{i})(19,2); % h/D
                yData(i,22) = Arc.(fields{i})(16,2); % steering
            end % i for loop
            if j == 1
                A.Total = yData;
            elseif j == 2
                A.Dynamic = yData;
            elseif j == 3
                A.Hydrostatic = yData;
            else
                A.STDEV = yData;
            end
        end %j for loop
        fprintf("YData table created!\n");
        fprintf("Subsorting and reducing repeats\n")
        % Extract the repeats in the table and recalculate the mean and 
        % standard deviation for those conditions. Uses the heading, target
        % flow speed, and H/D to find the indecies
        for indx = 1:4
            if indx == 1
                yData = A.Total;
            elseif indx == 2
                yData = A.Dynamic;
            elseif indx == 3
                yData = A.Hydrostatic;
            else
                 yData = A.STDEV;
            end
            depths = unique(yData{:,"H/D"});
            count = 1;
            for i=1:length(depths)
                indD = yData{:,"H/D"} == depths(i); 
                yData1{i} = yData(indD,:);
                speeds = unique(yData1{i}{:,"Target Flow Speed [m/s]"});
                for j = 1:length(speeds)
                    indS = yData1{i}{:,"Target Flow Speed [m/s]"} == speeds(j);
                    yData2{j} = yData1{i}(indS,:);
                    steering = unique(yData2{j}{:,"WheelAngle"});
                    for k = 1:length(steering)
                        indSt = yData2{j}{:,"WheelAngle"} == steering(k);
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
                                if indx == 4
                                    mu = rms(temp{:,2:end},1);
                                else
                                    % average all the cols
                                    mu = mean(temp{:,2:end},1); % 2:end ignores the string, 1 works on cols
                                end
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
            if indx == 1
                A.Total = yData;
            elseif indx == 2
                A.Dynamic = yData;
            elseif indx == 3
                A.Hydrostatic = yData;
            else
                A.STDEV = yData;
            end
            clear yData1 yData2 yData3 %must clear for correct loop function
        end % indx outer loop
        save("HydroData_FLAT","A",'-v7.3');
        fprintf("Data successfully saved to %s as HydroData_FLAT.m\n",pwd);
        fprintf("Writing Data to Excel file\n");
        sheet = 'Total';
        writetable(A.Total,"Hydrodata_Summary.xlsx",'Sheet',sheet,'Range','A1');
        sheet = 'Dynamic';
        writetable(A.Dynamic,"Hydrodata_Summary.xlsx",'Sheet',sheet,'Range','A1');
        sheet = 'Hydrostatic';
        writetable(A.Hydrostatic,"Hydrodata_Summary.xlsx",'Sheet',sheet,'Range','A1');
        sheet = 'STDEV';
        writetable(A.STDEV,"Hydrodata_Summary.xlsx",'Sheet',sheet,'Range','A1');
        fprintf("Successfully created Hydrodata_Summary.xlxs in %s\n",pwd);
        clearvars -except homePath dataPath programPath Arc yData savePath A

    case 2
        % interpolation table
        
        % read in values from flat table
        load HydroData_FLAT.mat %loads in as yData
        ROUND2 = 4; %4 original values no rounding, 3 moderate rounding (values for interpolation will not be correct!)
        yData = A.Total; %just want to operate on the totals
        Uvel = round(yData{:,"Flow Speed [m/s]"},ROUND2); % round to nearest mm/s
        Depth = round(yData{:,"Water Depth [m]"},ROUND2); % round to nearest mm
        Heading = yData{:,"Heading [deg]"};
        [L,W] = size(yData);
        fprintf("Creating empty interpHydro...\n");
        interpHydro = struct;
        vars = ["Fx","Fy","Fz","Mx","My","Mz","WheelFx","WheelFy",...
                "WheelFz","WheelMx","WheelMy","WheelMz"];
        tablevars = fieldnames(yData);
        tablevars = tablevars(2:13);
        steering = unique(yData{:,"WheelAngle"});
        steeringString = ["Starboard","Center","Port"]; % port is Positive 15
        count = 1;
        for v = 1:length(vars)
            for s = 1:length(steering)
                interpHydro.(vars{v}).(steeringString{s}).Values = zeros(L/length(steering),1);
                indSteering = yData{:,"WheelAngle"} == steering(s);
                yData1 = yData(indSteering,:);
                % fill with relevant data
                Heading1 = unique(yData1{:,"Heading [deg]"}); % ensure all headings exist  
                for i = 1:length(Heading1) 
                    indx = yData1{:,"Heading [deg]"} == Heading1(i);
                    yData2 = yData1(indx,:);
                    yData2 = sortrows(yData2,"Water Depth [m]");
                    Depth1 = unique(round(yData2{:,"Water Depth [m]"},ROUND2));
                    % loop over all speeds, will place 0 where no data exists
                    for j = 1:length(Depth1) 
                        indy = round(yData2{:,"Water Depth [m]"},ROUND2) == Depth1(j);
                        yData3 = yData2(indy,:);
                        yData3 = sortrows(yData3,"Flow Speed [m/s]");
                        Uvel1 = unique(round(yData3{:,"Flow Speed [m/s]"},ROUND2));
                        %again loop over the whole set
                        for k = 1:length(Uvel1)
                            indz = round(yData3{:,"Flow Speed [m/s]"},ROUND2) == Uvel1(k);
                            interpHydro.(vars{v}).(steeringString{s}).Values(count)= yData3{indz,tablevars{v}};
                            interpHydro.(vars{v}).(steeringString{s}).P(count,:) = [Heading1(i),Depth1(j),Uvel1(k)];
                            count = count + 1;
                        end %k loop
                    end %j loop
                end %i loop
                count = 1;
            end % s loop
        end % v loop
        save('ARC_Interpolation_Table.mat',"interpHydro");
        fprintf("InterpHydro Table Created Successfully\n");
        clearvars -except A yData interpHydro homePath programPath savePat

end
