function myTable = meanandstdevARC(dataTable,testMatrix,dataFileName,debug)
% This function takes in a table containting raw data from the ARC static
% test campaign, the corresponding testMatrix, and the dataFileNames, as
% well as the option to set a debugger. The function outputs a table called
% myTable that contains the Quantity, the mean, the STDDEV, and the units
% for each value from the input table and specific values of the testMatrix
    
    testMatrixVars = [testMatrix.Properties.VariableNames(6),testMatrix.Properties.VariableNames(7),'Flow_Speed','PredictedWaterSpeed',"WaterDepth"];
    units=["N","N","N","N-m","N-m","N-m","N","N","N","N-m","N-m","N-m","cm","deg","deg","deg","cm/s","cm/s",""]';
    %locate the trial in the test matrix incase missaligned
    testMatrixIndex = find(strcmp(dataFileName,testMatrix.TrialName));
    if debug
        fprintf("Building myTable for %s\n", dataFileName);
        fprintf("Using data from row %0.f of test matrix, corresponding to %s\n",testMatrixIndex,testMatrix.TrialName(testMatrixIndex));
    end
    vars = fieldnames(dataTable);
    vars = vars(2:end-3); %drop last three table intrinsic properties
    vars = [vars;testMatrixVars'];
    vars(end-1:end) = ["Target Water Speed", "H/D"];
    sz = length(vars);
    varNames = ["Quantity","Mean","STDDEV","Units"];
    varTypes = ["string","double","double","string"];
    myTable = table('Size',[sz,4],'VariableTypes',varTypes,'VariableNames',varNames);
    myTable{:,4} = units;

    %body forces and moments
    meanBodyForce = mean(dataTable{:,[vars(1:6)]},1,'omitnan');
    stdBodyForce = std(dataTable{:,[vars(1:6)]},1,'omitnan');
    myTable{1:6,["Quantity","Mean","STDDEV"]} = [vars(1:6),meanBodyForce',stdBodyForce'];
    %wheel forces and moments
    tempMean = mean(dataTable{:,[vars(7:12)]},1,'omitnan');
    tempStd = std(dataTable{:,[vars(7:12)]},1,'omitnan');
    %reorder tempMean and tempStd to match coordinate system
    % WFx 1 -> 1
    % WFz 3 -> 2 to become WFy
    % WFy 2 -> 3 to become WFz
    % WMx 4 -> 4
    % WMz 6 -> 5 to become WMy
    % WMy 5 -> 6 to become WMz
    tempMean = tempMean([1 3 2 4 6 5]);
    tempStd = tempStd([1 3 2 4 6 5]);
    %multiply all but elements 3 and 6 by -1
    tempMean([1:2,4:5]) = -1*tempMean([1:2,4:5]);
    tempStd([1:2,4:5]) = -1*tempStd([1:2,4:5]);
    meanWheelForce = tempMean;
    stdWheelForce = tempStd;
    myTable{7:12,["Quantity","Mean","STDDEV"]} = [vars(7:12),meanWheelForce',stdWheelForce'];
    clear tempMean tempStd
    %water depth and port steering angle
    meanWaterDepth = mean(dataTable.WaterDepth,'omitnan');
    stdWaterDepth = std(dataTable.WaterDepth,'omitnan');
    meanSteeringAngle = mean(dataTable.PortSteeringAngle,'omitnan');
    stdSteeringAngle = std(dataTable.PortSteeringAngle,'omitnan');
    myTable{13:14,["Quantity","Mean","STDDEV"]} = [vars(13:14),[meanWaterDepth;meanSteeringAngle],[stdWaterDepth;stdSteeringAngle]];
    n = 15;
    for i=1:length(testMatrixVars)
        if i == 3
            %read both flow speeds and avg
            temp = testMatrix.Flow_U_start(testMatrixIndex);
            temp(2) = testMatrix.Flow_U_end(testMatrixIndex);
            %stddev by difference between start and end speed
            absDiff = abs(temp(1)-temp(2));
            myTable(n,:) = {vars{n},mean(temp),absDiff,units{n}};
        else
            myTable(n,:) = {vars{n},testMatrix.(testMatrixVars{i})(testMatrixIndex),0,units{n}};
        end
        n = n+1;
    end
    clear temp
    return
end