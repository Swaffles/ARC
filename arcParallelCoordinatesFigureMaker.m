function arcParallelCoordinatesFigureMaker(data,index,barelabel,forces,length_Scale)
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

myColorMap = [100/255 143/255 255/255;...
              120/255 94/255 240/255;...
              220/255 38/255 127/255;...
              254/255 97/255 0/255;...
              255/255 176/255 0/255]; %IBM color map 

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
            depth = yData{i,"Water Depth"}/100; %get target depth in m
            %displacement Fr
            speed = yData{i,"Flow Speed"};
            FrH = speed/(sqrt(gravity*depth)); %real speed yData{i,5}
            Sr = depth/(length_Scale^1/3);
            %depth Fr
            FrD = speed/(sqrt(gravity*length_Scale^1/3));
            %scaling Fr
            FrHSr = FrH*sqrt(Sr);
            FrDSr = FrD/sqrt(Sr);
            yData(i,8) = {round(FrHSr,2,"significant")};
            yData(i,9) = {round(FrDSr,2,"significant")};
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
            yData(i,9) = {round(1/FrHSr,2,"significant")};
            yData(i,10) = {round(Sr,2,"decimals")};
            yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale);
        end
    end
    yData{:,1} = abs(yData{:,1});
    label = strcat('C',barelabel);
    yData.Properties.VariableNames = [label,"Water Depth","Heading",...
    "Steering","Flow Speed",'Target Flow Speed','h/D','FrH','1/FrD','Sr'];

    %Collect data by steering
        M = unique(yData{:,"Steering"}); %unique
        tile = tiledlayout(1,length(M));
        %User Selects which Heading angle they want to investigate
        Heading = unique(yData{:,"Heading"});
        [indH,tf] = listdlg('ListString',string(Heading),'PromptString','Select a Steering Angle to Comapre');
        if ~tf
            fprintf("No selection made, exiting function");
            return;
        end
        for j = 1:length(indH)
            ind = yData{:,"Heading"} == Heading(indH(j));
            if j == 1
                indx = ind;
            else
                indx = indx | ind;
            end
        end
        yData1 = yData(indx,:);
        for i = 1:length(M)
            indm = yData1{:,"Steering"} == M(i);
            yData2{i} = yData1(indm,:); %place current steering into next yData1 table
            nexttile;
            %make the plot
            columns = [label,"Water Depth","Sr","FrH","Flow Speed","h/D"];
            yData3 = yData2{i}(:,columns);
            yData3 = sortrows(yData3,{'Water Depth'},{'ascend'});
            coordinateDataLabels = yData3.Properties.VariableNames(1:end-1);
            p = parallelplot(yData3,"CoordinateVariables",coordinateDataLabels,...
                             'GroupVariable','h/D','Jitter',0,'DataNormalization','range');
            %make it look nice
            p.Color = myColorMap(2:end,:);
            temp = string(Heading(indH));
            if length(temp) > 1
                headingLabel = sprintf('%s ',temp);
            else
                headingLabel = temp;
            end
            p.LegendTitle = strcat({'h/D for'},{sprintf('\n')},{'steering = '},string(yData2{i}{1,"Steering"}));
            %title(strcat({'Steering= '},string(yData2{i}{1,"Steering"})));
        end %end depth for loop 
        title(tile,strcat({'Parallel Plots '},label));
        tile.Subtitle.String = strcat({'Heading(s)= '},headingLabel);
        %figHeadingLabel = strrep(headingLabel,',','_');
        %figName = strcat({'ParallelPlot_'},label,{'Heading(s)= '},figHeadingLabel);
        %print(figName,'-dpdf');

end %end function