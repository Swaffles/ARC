function arcForceFigureMaker(data,index,label,barelabel,dimensional,forces,length_Scale)
%Inputs:
%ARC: data set containing all the necessary data for plotting
%index: Y-axis item
%label: Y-axis title
%barelabel: label w/o units
%dimensional: toggle true false dimesionless (defualt dimensionless)
%forces: tells nondimensional part how to handle the nondimensionalization
%length scale: used for non dimensionalization

%Ydata = (data, water depth, heading, steering, flow speed)

rho = 1000; %water density
gravity = 9.81; %acceleration due to gravity
wheelDiameter = 25.4; %wheel diameter

%number of items to loop over
fields = fieldnames(data);
    for i=1:length(fields)
        yData(i,1) = data.(fields{i})(index,2); %main Y-axis
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
    if dimensional
        %use tiles for water depth 
        m = unique(yData{:,7});
        tile = tiledlayout(2,2); %2x2 layout
        counter = 1;
        colCounter = 0;
        yData1{1,4} = [];
        for i = 1:length(m)
            %depth
            indm = yData{:,7}==m(i);
            yData1{i} = yData(indm,:);
            n = unique(yData1{i}{:,6});
            nexttile;
            yData2{1,3} = [];
            for j = 1:length(n)
                %speed
                indn = yData1{i}{:,6}==n(j);
                yData2{j} = yData1{i}(indn,:); %() so i can keep the table format
                q = unique(yData2{j}{:,4});
                col = [100/255 143/255 255/255;...
                       220/255 38/255 127/255;...
                       255/255 176/255 0/255]; %IBM color map
                colCounter = colCounter+1;
                for k = 1:length(q)
                    %steering
                    indq = yData2{j}{:,4}==q(k);
                    yData3{counter} = yData2{j}(indq,:);
                    %sort by heading, increasing from 0 - 180
                    yData3{counter} = sortrows(yData3{counter},'Heading');
                    if yData3{counter}{1,4} == 0
                        hold on
                        plot(yData3{counter},'Heading',barelabel,'LineStyle','-','Marker','o','Color',col(colCounter,:),...
                            'DisplayName',strcat("Steering= ",string(yData3{counter}{1,4}),'deg; Target Speed= ',string(yData3{counter}{1,6}),' m/s'));
                    elseif yData3{counter}{1,4} > 0
                         plot(yData3{counter},'Heading',barelabel,'Marker','<','Color',col(colCounter,:),...
                            'DisplayName',strcat("Steering= ",string(yData3{counter}{1,4}),'deg; Target Speed= ',string(yData3{counter}{1,6}),' m/s'));
                    else
                         plot(yData3{counter},'Heading',barelabel,'Marker','>','Color',col(colCounter,:),...
                            'DisplayName',strcat("Steering= ",string(yData3{counter}{1,4}),'deg; Target Speed= ',string(yData3{counter}{1,6}),' m/s'));
                    end
                    counter = counter+1;
                end
            end
            title(strcat(barelabel,' V. h/d= ',string(yData3{counter-1}{1,7})));
            xlabel("Heading (deg)");
            xticks(0:22.5:max(yData{:,3}));
            ylabel(label);
            legend('Location','southoutside','NumColumns',k);
            hold off
            colCounter = 0;
        end
    else
        if forces
            for i=1:height(yData)
                yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale^(2/3));
            end
            label = strcat(barelabel,'/','$\frac{1}{2}*\rho*U^2*Vol^{2/3}$');
            if strcmp(barelabel,'Fx')
                barelabel = 'CFx';
            elseif strcmp(barelabel,'Fy')
                barelabel = 'CFy';
            else
                barelabel = 'CFz';
            end
        else
            for i=1:height(yData)
                yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale);
            end
            label = strcat(barelabel,'/','$\frac{1}{2}*\rho*U^2*Vol$');
            if strcmp(barelabel,'Mx')
                barelabel = 'CMx';
            elseif strcmp(barelabel,'My')
                barelabel = 'CMy';
            else
                barelabel = 'CMz';
            end
        end
        %Froude number instead of speed
        for i=1:length(fields)
            %depth froude number
            depth = yData{i,2}/100; %get target depth in m
            Fr = yData{i,6}/(sqrt(gravity*depth)); %real speed yData{i,5}
            Sr = sqrt(depth)/(length_Scale^1/3);
            %scaling Fr
            FrSr = Fr*Sr;
            %displacement froude number
            %Fr = yData{i,6}/(sqrt(gravity*(length_Scale)^(1/3)));
            yData(i,8) = {round(FrSr,2,"significant")};
        end
        yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
        "Steering","Flow Speed",'Target Flow Speed','h/D','Fr'];
        %use tiles for water depth 
        m = unique(yData{:,7});
        counter = 1;
        col = [100/255 143/255 255/255;...
               120/255 94/255 240/255;...
               220/255 38/255 127/255;...
               255/255 176/255 0/255]; %IBM color map
        colCounter = 0;
        yData1{1,4}=[];
        for i = 1:length(m)
            %depth
            indm = yData{:,7}==m(i);
            yData1{i} = yData(indm,:);
            n = unique(yData1{i}{:,8}); 
            colCounter = colCounter+1;
            yData2{1,3} = [];
            for j = 1:length(n)
                %Froude number
                indn = yData1{i}{:,8}==n(j);
                yData2{j} = yData1{i}(indn,:);
                q = unique(yData2{j}{:,4});    
                for k = 1:length(q)
                    %steering
                    indq = yData2{j}{:,4}==q(k);
                    yData3{counter} = yData2{j}(indq,:);
                    %sort by heading, increasing from 0 - 180
                    yData3{counter} = sortrows(yData3{counter},'Heading');
                    if yData3{counter}{1,4} == 0
                        hold on
                        plot(yData3{counter},'Heading',barelabel,'LineStyle','-','Marker','o','Color',col(colCounter,:),...
                            'DisplayName',strcat("H/d= ",string(yData3{counter}{1,7})," Steering= ",string(yData3{counter}{1,4}),'deg',' Fr = ',string(yData3{counter}{1,8})));
                    elseif yData3{counter}{1,4} > 0
                         plot(yData3{counter},'Heading',barelabel,'LineStyle','-','Marker','<','Color',col(colCounter,:),...
                            'DisplayName',strcat("H/d= ",string(yData3{counter}{1,7})," Steering= ",string(yData3{counter}{1,4}),'deg',' Fr = ',string(yData3{counter}{1,8})));
                    else
                         plot(yData3{counter},'Heading',barelabel,'LineStyle','-','Marker','>','Color',col(colCounter,:),...
                            'DisplayName',strcat("H/d= ",string(yData3{counter}{1,7})," Steering= ",string(yData3{counter}{1,4}),'deg',' Fr = ',string(yData3{counter}{1,8})));
                    end
                    counter = counter+1;
                end %end steering
                clear yData3
            end %end froude
            clear yData2
        end %end depth
            title(strcat(barelabel,' V. Heading'));
            xlabel("Heading (deg)");
            xticks(0:22.5:max(yData{:,3}));
            ylabel(label,'Interpreter','latex');
            legend('Location','southoutside','NumColumns',k);
            hold off
    end

end