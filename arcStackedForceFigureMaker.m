function arcStackedForceFigureMaker(data,index,label,barelabel,vars)
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
    end
    yData.Properties.VariableNames = [barelabelfX,barelabelfY,barelabelfZ,...
        barelabelmX,barelabelmY,barelabelmZ,"Water Depth","Heading",...
        "Steering","Flow Speed",'Target Flow Speed','h/D'];
    
    %UI Input
    %User first a depth they want to investigate
    m = unique(yData{:,12});
    [indx,tf] = listdlg('ListString',string(m),'SelectionMode','single','PromptString','Select a Depth');
    if ~tf
        fprintf("No selection made, exiting function");
        return;
    end
    tile = tiledlayout(3,3); %3x3 layout
    counter = 1;
    colCounter = 0;
    indm = yData{:,12} == m(indx);
    yData1 = yData(indm,:);
    %find which column 1-6 is largest and reorder
    for columns = 1:6-1
        for i=1:6-columns-1
            temp = sum(yData1{:,i});
            temp2 = sum(yData1{:,i+1});
            if temp<temp2
                temp = yData1{:,i};
                yData1{:,i} = yData1{:,i+1};
                yData1{:,i+1} = temp;
                temp2 = barelabels{i};
                barelabels{i} = barelabels{i+1};
                barelabels{i+1} = temp2;
                %fprintf("Swapped col %d with %d\n",i,i+1);
            end
        end
    end
    barelabels = barelabels';
    fprintf("Final Order %s %s %s %s %s %s\n", barelabels{:});
    newNames = [barelabels{:}];
    oldNames = yData1.Properties.VariableNames(1:6);
    yData1 = renamevars(yData1,oldNames,newNames);
    n = unique(yData1{:,11});
    yData2{1,3} = [];
    for i = 1:length(n)
        %speed
        indn = yData1{:,11}==n(i);
        yData2{i} = yData1(indn,:);
        q = unique(yData2{i}{:,9});
        yData3{1,3} = [];
        for j = 1:length(q)
            nexttile;
            %steering
            indq = yData2{i}{:,9}==q(j);
            yData3{j} = yData2{i}(indq,:); %() so i can keep the table format
            yData3{j} = sortrows(yData3{j},'Heading','descend');
            myColorMap = [100/255 143/255 255/255;...
                   120/255 94/255 240/255;...
                   220/255 38/255 127/255;...
                   254/255 97/255 0/255;...
                   255/255 176/255 0/255]; %IBM color map   
            %barelabels = convertStringsToChars(newNames);
            area(yData3{j}{:,8},yData3{j}{:,1:6});
            %colororder(myColorMap);
            title(strcat('h/D= ',string(yData3{j}{1,12}),' U = ',string(yData3{j}{1,11}),' Steering = ',string(yData3{j}{1,9})));
            xlabel("Heading (deg)");
            xticks(0:22.5:max(yData{:,8}));
            xlim([0,max(yData{:,8})]);
            ylabel(label);
            legend(barelabels,'Location','southoutside','NumColumns',2);
        end %end steering    
    end %end speed
    
   
end