function arcForceComparisonFigureMaker(data,index,makeTiles,label,barelabel,vars,length_Scale)
%Inputs:
%ARC: data set containing all the necessary data for plotting
%index: Y-axis items
%label: Y-axis title
%barelabel: label w/o units

%Ydata = (data, water depth, heading, steering, flow speed)

rho = 1000; %water density
gravity = 9.81; %acceleration due to gravity
wheelDiameter = 25.4; %wheel diameter

if index == 1
    fX = 1;
    fY = 2;
    fZ = 3;
    mX = 4;
    mY = 5;
    mZ = 6;
elseif index == 2
    fX = 7;
    fY = 8;
    fZ = 9;
    mX = 10;
    mY = 11;
    mZ = 12;
else
    fprintf("Error occured\n");
    return
end
barelabelfX = vars(fX);
barelabelfY = vars(fY);
barelabelfZ = vars(fZ);
barelabelmX = vars(mX);
barelabelmY = vars(mY);
barelabelmZ = vars(mZ);
%put in cell array for graphing
barelabels = {barelabelfX,barelabelfY,barelabelfZ,barelabelmX,barelabelmY,barelabelmZ};

%number of items to loop over
fields = fieldnames(data);
    for i=1:length(fields)
        yData(i,1) = data.(fields{i})(fX,2); %main FX
        yData(i,2) = data.(fields{i})(fY,2); %main Fy
        yData(i,3) = data.(fields{i})(fZ,2); %main Fz
        yData(i,4) = data.(fields{i})(mX,2); %main MX
        yData(i,5) = data.(fields{i})(mY,2); %main My
        yData(i,6) = data.(fields{i})(mZ,2); %main Mz
        temp1 = data.(fields{i}){13,2}/100; %water depth m
        yData(i,7) = {temp1};
        yData(i,8) = data.(fields{i})(15,2); %heading
        yData(i,9) = data.(fields{i})(16,2); %steering
        temp2 = data.(fields{i}){17,2}/100; %flow speed m/s
        yData(i,10) = {temp2};
        yData(i,11) = data.(fields{i})(18,2); %target flow speed
        yData(i,12) = data.(fields{i})(19,2); %h/D
        FrH = yData{i,11}/(sqrt(gravity*yData{i,7}));
        Sr = yData{i,11}/(length_Scale^1/3);
        FrD = yData{i,11}/(sqrt(gravity*length_Scale^1/3));
        FrHSr = FrH*sqrt(Sr);
        FrDSr = FrD/sqrt(Sr);
        yData(i,13) = {round(FrDSr,2,"significant")};
        yData(i,14) = {round(FrHSr,2,"significant")};
        yData(i,15) = {round(Sr,2,"decimals")};
    end
    yData.Properties.VariableNames = [barelabelfX,barelabelfY,barelabelfZ,...
        barelabelmX,barelabelmY,barelabelmZ,"Water Depth","Heading",...
        "Steering","Flow Speed",'Target Flow Speed','h/D','FrH','FrD','Sr'];
    
    %UI Input
    %User Selects which Depth they want to compare against
    Depth = unique(yData{:,"h/D"});
    [indD,tf] = listdlg('ListString',string(Depth),'SelectionMode','single','PromptString','Select a Depth to Comapre');
    if ~tf
        fprintf("No selection made, exiting function");
        return;
    end
    %User Selects which Steering angle they want to compare against
    Steering = unique(yData{:,"Steering"});
    [indST,tf] = listdlg('ListString',string(Steering),'SelectionMode','single','PromptString','Select a Steering Angle to Comapre');
    if ~tf
        fprintf("No selection made, exiting function");
        return;
    end
    %User Selects which Speed they want to compare
    Speed = ["Slow","Medium","Fast"];
    [indS,tf] = listdlg('ListString',string(Speed),'SelectionMode','single','PromptString','Select a Depth to Comapre');
    if ~tf
        fprintf("No selection made, exiting function");
        return;
    end
    if strcmp(Speed(indS),"Fast")
        indSpeed = 3;
    elseif strcmp(Speed(indS),"Medium")
        indSpeed = 2;
    else
        indSpeed = 1;
    end
    %User Selects which Force they want to compare
    Force = yData.Properties.VariableNames(1:6);
    [indF,tf] = listdlg('ListString',Force,'SelectionMode','single','PromptString','Select a Force to Compare');
    if ~tf
        fprintf("No selection made, exiting function");
        return;
    end
    if makeTiles
        tile = tiledlayout(3,1); %3x1 layout
        yData1Color = [26/255 133/255 255/255]; %Compare color (blue)
        yData3Color = [212/255 17/255 89/255;...
                       255/255 194/255 10/255;...
                       230/255 97/255 0/255]; %Accessible color palette   
        indx = yData{:,"h/D"} == Depth(indD); 
        yData1 = yData(indx,:); %data held constant
        %find the unique target flow speeds for this depth. The value in
        %position 1 will be the slowest and correspond with indS = 1 (Slow), the value
        %in position 3 will be quickest and correspond with indS = 3 (Fast)
        uniqueSpeed1 = unique(yData1{:,"Target Flow Speed"});
        indx = yData1{:,"Target Flow Speed"} == uniqueSpeed1(indSpeed);
        yData1 = yData1(indx,:);
        %steering
        indx = yData1{:,"Steering"} == Steering(indST);
        yData1 = yData1(indx,:);
        X = categorical(unique(yData1{:,"Heading"}));
        yData1 = sortrows(yData1,"Heading");
        %other depths data
        indx = yData{:,"Steering"} == Steering(indST);
        yData2 = yData(indx,:);
        temp = unique(yData1{:,"Heading"});
        for h=1:length(temp)
            indx = yData2{:,"Heading"} == temp(h);
            if h == 1
                indH = indx;
            else
                indH = indH | indx;
            end
        end
        yData2 = yData2(indH,:);
        indx = Depth ~= Depth(indD);  
        otherDepths = Depth(indx);
        for i=1:3
            ax = nexttile;
            %first select the depth
            indx = yData2{:,"h/D"} == otherDepths(i);
            yData3 = yData2(indx,:); 
            %now narrow down the speed
            uniqueSpeed2 = unique(yData3{:,"Target Flow Speed"});
            indx = yData3{:,"Target Flow Speed"} == uniqueSpeed2(indSpeed);
            yData3 = yData3(indx,:);
            yData3 = sortrows(yData3,"Heading");
            
            Forces2Plot(1:2,:) = [yData1{:,Force{indF}}';yData3{:,Force{indF}}'];
            %Forces2Plot = flip(Forces2Plot);
            legendLabel(1,1:2) = [strcat({'h/D = '},string(Depth(indD)),{', U = '},string(uniqueSpeed1(indSpeed)),{' m/s'}),...
                                  strcat({'h/D = '},string(otherDepths(i)),{', U = '},string(uniqueSpeed2(indSpeed)),{' m/s'})];
            bar(X,Forces2Plot,0.9);
            colororder(ax,[yData1Color;yData3Color(i,:)]); %keeps comapred depth color constant, changes others according to color map
            title(strcat({'h/D = '},string(Depth(indD)),{' V. h/D ='},string(otherDepths(i))));
            if contains(Force{indF},'F')
                unitLabel = 'N';
            else
                unitLabel = 'Nm';
            end
            xlabel("Heading (deg)");
            ylabel(sprintf("Magnitude %s (%s)",Force{indF},unitLabel));
            paddingMinus = abs(std(min(Forces2Plot),[],"all"));
            paddingPlus = abs(std(max(Forces2Plot),[],"all"));
            ylim([min(Forces2Plot,[],"all")-paddingMinus,...
                  max(Forces2Plot,[],"all")+paddingPlus]);
            legend(legendLabel,'Location','bestoutside');
        end
        tiledFigureTitle = strcat({'Depth Comparison for: '},Force{indF},...
            {', U = '},string(Speed(indS)),{' \delta = '},string(Steering(indST)));
        title(tile,tiledFigureTitle,"Interpreter","tex");
        
        figName = strcat({'Depth Comparison for_'},Force{indF},...
            {'_U_'},string(Speed(indS)),{'_Delta_'},string(Steering(indST)));
        print(figName,'-dmeta');
    else
        myColorMap = [100/255 143/255 255/255;...
                      220/255 38/255 127/255;...
                      254/255 97/255 0/255;...
                      255/255 176/255 0/255]; %IBM color map  
        indx = yData{:,"h/D"} == Depth(indD); 
        yData1 = yData(indx,:); %data held constant
        %find the unique target flow speeds for this depth. The value in
        %position 1 will be the slowest and correspond with indS = 1 (Slow), the value
        %in position 3 will be quickest and correspond with indS = 3 (Fast)
        uniqueSpeed1 = unique(yData1{:,"Target Flow Speed"});
        indx = yData1{:,"Target Flow Speed"} == uniqueSpeed1(indSpeed);
        yData1 = yData1(indx,:);
        %steering
        indx = yData1{:,"Steering"} == Steering(indST);
        yData1 = yData1(indx,:);
        X = categorical(unique(yData1{:,"Heading"}));
        yData1 = sortrows(yData1,"Heading");
        %other depths data
        indx = yData{:,"Steering"} == Steering(indST);
        yData2 = yData(indx,:);
        temp = unique(yData1{:,"Heading"});
        for h=1:length(temp)
            indx = yData2{:,"Heading"} == temp(h);
            if h == 1
                indH = indx;
            else
                indH = indH | indx;
            end
        end
        yData2 = yData2(indH,:);
        indx = Depth ~= Depth(indD);  
        otherDepths = Depth(indx);
        Forces2Plot(1,:) = yData1{:,Force{indF}}';
        legendLabel(1,1) = strcat({'h/D = '},string(Depth(indD)),{', U = '},string(uniqueSpeed1(indSpeed)),{' m/s'});
        for i=1:3
            %first select the depth
            indx = yData2{:,"h/D"} == otherDepths(i);
            yData3 = yData2(indx,:); 
            %now narrow down the speed
            uniqueSpeed2 = unique(yData3{:,"Target Flow Speed"});
            indx = yData3{:,"Target Flow Speed"} == uniqueSpeed2(indSpeed);
            yData3 = yData3(indx,:);
            yData3 = sortrows(yData3,"Heading");
            
            Forces2Plot(i+1,:) = yData3{:,Force{indF}}';
            legendLabel(1,i+1) = strcat({'h/D = '},string(otherDepths(i)),{', U = '},string(uniqueSpeed2(indSpeed)),{' m/s'});
        end
            
            bar(X,Forces2Plot,0.9);
            colororder(myColorMap); %keeps comapred depth color constant, changes others according to color map
            if contains(Force{indF},'F')
                unitLabel = 'N';
            else
                unitLabel = 'Nm';
            end
            xlabel("Heading (deg)");
            ylabel(sprintf("Magnitude %s (%s)",Force{indF},unitLabel));
            paddingMinus = abs(std(min(Forces2Plot),[],"all"));
            paddingPlus = abs(std(max(Forces2Plot),[],"all"));
            ylim([min(Forces2Plot,[],"all")-paddingMinus,...
                  max(Forces2Plot,[],"all")+paddingPlus]);
            legend(legendLabel,'Location','bestoutside');
        figureTitle = strcat({'Depth Comparison for: '},Force{indF},...
            {', U = '},string(Speed(indS)),{' \delta = '},string(Steering(indST)));
        title(figureTitle,"Interpreter","tex");
        
        figName = strcat({'NoTiles_Depth_Comparison'},Force{indF},...
            {'_U_'},string(Speed(indS)),{'_Delta_'},string(Steering(indST)));
        print(figName,'-dmeta');
    end
   
end