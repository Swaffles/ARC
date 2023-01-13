function arcCoefficientForceFigureMaker(data,index,Label,barelabel,depthBased,forces,length_Scale,makeTiles,excludeShallow)
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
if excludeShallow
    %remove all trials with h/D = 0.2 from fields
    temp = fields;
    for i=1:length(fields)
        indx = data.(temp{i}){19,2} == 0.2
        if indx
            indf = find(strcmp(fields,temp{i}));
            fields(indf) = [];
        end
    end
end
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
   
    %Froude number instead of speed
    for i=1:length(fields)
        %depth froude number
        depth = yData{i,2}/100; %get target depth in m
        if ~depthBased
            %displacement Fr
            Fr = yData{i,6}/(sqrt(gravity*depth)); %real speed yData{i,5}
            Sr = depth/(length_Scale^1/3);
        else
            %depth Fr
            Fr = yData{i,6}/(sqrt(gravity*length_Scale^1/3));
            Sr = (length_Scale^1/3)/depth;
        end
        %scaling Fr
        FrSr = Fr*sqrt(Sr);
        %displacement froude number
        %Fr = yData{i,6}/(sqrt(gravity*(length_Scale)^(1/3)));
        yData(i,8) = {round(FrSr,2,"significant")};
    end
    if forces
        for i=1:height(yData)
            yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale^(2/3)*Sr^1);
        end
        label = strcat(barelabel,'/','$\frac{1}{2}*\rho*U^2*Vol^{2/3}*(\frac{h}{Vol^{1/3}})^1$');
    else
        for i=1:height(yData)
            yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale*Sr);
        end
        label = strcat(barelabel,'/','$\frac{1}{2}*\rho*U^2*Vol*(frac{h}{Vol^{1/3}})^1$');
    end
    
    yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
    "Steering","Flow Speed",'Target Flow Speed','h/D','Fr'];
  
    %Collect data by heading to graph
    if makeTiles
        tile = tiledlayout(2,2);
        L = unique(yData{:,7}); %unique depths
        M = unique(yData{:,3}); %unique headings
        lineColors = lines(length(M));
        counter = 1;
        lineColorsCounter = 0;
        yData1{1,4} = []; %cols == diff depth
        for i = 1:length(L)
            indL = yData{:,7} == L(i);
            yData1{i} = yData(indL,:); %place current depth into next yData1 table
            m = unique(yData1{i}{:,3}); %unique headings
            yData2{1,length(m)} = [];
            nexttile;
            for j = 1:length(m)
                %heading
                indm = yData1{i}{:,3} == m(j);
                yData2{j} = yData1{i}(indm,:); %place current heading into new yData2 table
                n = unique(yData2{j}{:,4}); %steering selection
                yData3{1,3} = [];
                lineColorsCounter = lineColorsCounter+1; %increment line color for new heading
                for k=1:length(n)
                    %steering
                    indn = yData2{j}{:,4} == n(k);
                    yData3{counter} = yData2{j}(indn,:); %place current steering angle into new yData3 table 
                    yData3{counter} = sortrows(yData3{counter},'Fr');
                    hold on
                    if yData3{counter}{1,4} == 0 
                    plot(yData3{counter},'Fr',barelabel,'LineStyle','-','Marker','o','Color',lineColors(lineColorsCounter,:),...
                        'DisplayName',strcat("Heading= ",string(yData3{counter}{1,3}),"deg"," Steering= ",string(yData3{counter}{1,4}),'deg'));
                    elseif yData3{counter}{1,4} > 0
                        plot(yData3{counter},'Fr',barelabel,'LineStyle','-','Marker','<','Color',lineColors(lineColorsCounter,:),...
                            'DisplayName',strcat("Heading= ",string(yData3{counter}{1,3}),"deg"," Steering= ",string(yData3{counter}{1,4}),'deg'));
                    else
                        plot(yData3{counter},'Fr',barelabel,'LineStyle','-','Marker','>','Color',lineColors(lineColorsCounter,:),...
                            'DisplayName',strcat("Heading= ",string(yData3{counter}{1,3}),"deg"," Steering= ",string(yData3{counter}{1,4}),'deg'));
                    end
                    counter = counter+1;
                end %end steering for loop
                clear yData3
            end %end heading for loop
            clear yData2
            title(strcat(Label,' V. Froude Number for h/D= ',string(yData1{i}{1,7})));
            if depthBased
                xlabel("Froude Number based on Depth");
            else
                xlabel("Froude Number based on displacement");
            end
            %xticks(0:22.5:max(yData{:,3}));
            ylabel(label,'Interpreter','latex');
            hold off
            lineColorsCounter = 0;
        end %end depth for loop
        legend('Location','southoutside','NumColumns',length(M));
        
    else
        m = unique(yData{:,3}); %unique headings
        lineColors = lines(length(m));
        counter = 1;
        lineColorsCounter = 0;
        yData1{1,length(m)}=[];
        for i = 1:length(m)
            %heading
            indm = yData{:,3} == m(i);
            yData1{i} = yData(indm,:);
            n = unique(yData1{i}{:,4}); %steering selection
            yData2{1,3} = [];
            lineColorsCounter = lineColorsCounter+1;
            for j = 1:length(n)
                %steering
                indn = yData1{i}{:,4} == n(j);
                yData2{counter} = yData1{i}(indn,:);
                yData2{counter} = sortrows(yData2{counter},'Fr');
                hold on
                if yData2{counter}{1,4} == 0 
                    plot(yData2{counter},'Fr',barelabel,'LineStyle','-','Marker','o','Color',lineColors(lineColorsCounter,:),...
                        'DisplayName',strcat("Heading= ",string(yData2{counter}{1,3}),"deg"," Steering= ",string(yData2{counter}{1,4}),'deg'));
                elseif yData2{counter}{1,4} > 0
                    plot(yData2{counter},'Fr',barelabel,'LineStyle','-','Marker','<','Color',lineColors(lineColorsCounter,:),...
                        'DisplayName',strcat("Heading= ",string(yData2{counter}{1,3}),"deg"," Steering= ",string(yData2{counter}{1,4}),'deg'));
                else
                    plot(yData2{counter},'Fr',barelabel,'LineStyle','-','Marker','>','Color',lineColors(lineColorsCounter,:),...
                        'DisplayName',strcat("Heading= ",string(yData2{counter}{1,3}),"deg"," Steering= ",string(yData2{counter}{1,4}),'deg'));
                end
                counter = counter+1;
            end %end steering for loop
        end %end heading for loop
        title(strcat(Label,' V. Froude Number'));
        if depthBased
            xlabel("Froude Number based on Depth");
        else
            xlabel("Froude Number based on displacement");
        end
        xticks(0:0.2:max(yData{:,8}));
        ylabel(label,'Interpreter','latex');
        legend('Location','southoutside','NumColumns',j);
        hold off
    end %end makeTiles else
end %end function