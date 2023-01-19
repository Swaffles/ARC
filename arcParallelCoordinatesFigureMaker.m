function arcParallelCoordinatesFigureMaker(data,index,Label,barelabel,forces,length_Scale)
%Inputs:
%ARC: data set containing all the necessary data for plotting
%index: Y-axis item
%label: Y-axis title
%barelabel: label w/o units
%depthBased: tells whether to use depth based or volume based Froude #
%forces: tells nondimensional part how to handle the nondimensionalization
%length scale: used for non dimensionalization

%Ydata = (data, water depth, heading, steering, flow speed)

rho = 1000; %water density
gravity = 9.81; %acceleration due to gravity
wheelDiameter = 25.4; %wheel diameter

%number of items to loop over
fields = fieldnames(data);
    for i=1:length(fields)
        yData(i,1) = data.(fields{i})(index,2); %main Y-axis variable
        yData(i,2) = data.(fields{i})(13,2); %water depth cm
        yData(i,3) = data.(fields{i})(15,2); %heading
        yData(i,4) = data.(fields{i})(16,2); %steering
        temp = data.(fields{i}){17,2}/100; %flow speed m/s
        yData(i,5) = {temp};
        yData(i,6) = data.(fields{i})(18,2); %target flow speed
        yData(i,7) = data.(fields{i})(19,2); %h/D
    end
    yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
        "Steering","Flow Speed",'Target Flow Speed','h/D'];
   
    %nondimensionalization
    if forces
        for i=1:height(yData)
            %depth
            depth = yData{i,2}/100; %get target depth in m
            %displacement Fr
            speed = yData{i,6}; %5 for real speed, 6 for target
            FrD = speed/(sqrt(gravity*depth)); %real speed yData{i,5}
            Sr = depth/(length_Scale^1/3);
            %depth Fr
            FrH = speed/(sqrt(gravity*length_Scale^1/3));
            %scaling Fr
            FrDSr = FrD*sqrt(Sr);
            FrHSr = FrH/sqrt(Sr);
            yData(i,8) = {round(FrDSr,2,"significant")};
            yData(i,9) = {round(FrHSr,2,"significant")};
            yData(i,10) = {round(Sr,2,"decimals")};
            yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale^(2/3));
        end
    else
        for i=1:height(yData)
            %depth
            depth = yData{i,2}/100; %get target depth in m
            %displacement Fr
            speed = yData{i,6}; %5 for real speed, 6 for target
            FrD = speed/(sqrt(gravity*depth)); %real speed yData{i,5}
            Sr = depth/(length_Scale^1/3);
            %depth Fr
            FrH = speed/(sqrt(gravity*length_Scale^1/3));
            %scaling Fr
            FrDSr = FrD*sqrt(Sr);
            FrHSr = FrH/sqrt(Sr);
            yData(i,8) = {round(FrDSr,2,"significant")};
            yData(i,9) = {round(FrHSr,2,"significant")};
            yData(i,10) = {round(Sr,2,"decimals")};
            yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale);
        end
    end
    yData{:,1} = abs(yData{:,1});
    label = strcat('C',barelabel);
    yData.Properties.VariableNames = [label,"Water Depth","Heading",...
    "Steering","Flow Speed",'Target Flow Speed','h/D','FrD','FrH','Sr'];

    %Collect data by steering
        tile = tiledlayout(2,3);
        L = unique(yData{:,7}); %unique depths
        M = unique(yData{:,3}); %unique heading
        yData1{1,4} = []; %cols == diff depth
        for i = 1:length(M)
            indm = yData{:,3} == M(i);
            yData1{i} = yData(indm,:); %place current depth into next yData1 table
            nexttile;
            %make the plot
            columns = [1,2,10,5,9,4,8];
            yData2 = yData1{i}(:,columns);
            yData2 = sortrows(yData2,{'Water Depth'},{'ascend'});
            coordinateDataLabels = yData2.Properties.VariableNames(1:end-1);
            parallelplot(yData2,"CoordinateVariables",coordinateDataLabels,'GroupVariable','FrD','Jitter',0);
            %make it look nice
            title(strcat('Heading= ',string(yData1{i}{1,3})));
        end %end depth for loop
        %legend('Location','southoutside','NumColumns',length(M));

end %end function