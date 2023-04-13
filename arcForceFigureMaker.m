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
        yData(i,8) = {0}; %this will be where standard deviation gets put in
    end
    yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
        "Steering","Flow Speed",'Target Flow Speed','h/D','Stdev'];
    if dimensional
        %use tiles for water depth 
        depth = unique(yData{:,"h/D"});
        tile = tiledlayout(2,2); %2x2 layout
        counter = 1;
        colCounter = 0;
        yData1{1,4} = [];
        for i = 1:length(depth)
            %depth
            indH = yData{:,"h/D"}==depth(i);
            yData1{i} = yData(indH,:);
            n = unique(yData1{i}{:,"Target Flow Speed"});
            ax = nexttile;
            yData2{1,3} = [];
            for j = 1:length(n)
                %speed
                indn = yData1{i}{:,"Target Flow Speed"}==n(j);
                yData2{j} = yData1{i}(indn,:); %() so i can keep the table format
                q = unique(yData2{j}{:,"Steering"});
                col = [120/255 94/255 240/255;...
                       220/255 38/255 127/255;...
                       254/255 97/255 0/255]; %IBM color map
                colCounter = colCounter+1;
                for k = 1:length(q)
                    %steering
                    indq = yData2{j}{:,"Steering"}==q(k);
                    yData3{counter} = yData2{j}(indq,:);     
                    %if repeat headings we need to average these and tack
                    %on the standard deviation
                    [GC,GR] = groupcounts(yData3{counter}{:,"Heading"});
                    if any(GC>1)
                        %there are repeats, identify the value
                        indGC = find(GC>1);
                        valueGR = GR(indGC); %this may be larger than 1 value
                        %find corresponding row from yData3
                        for a = 1:length(valueGR)
                            rowsYData3 = find(yData3{counter}{:,"Heading"}==valueGR(a));
                            temp = yData3{counter}(rowsYData3,:);
                            yData3{counter}(rowsYData3,:) = []; %deletes the row
                            mu = mean(temp{:,barelabel});
                            if GC(indGC(a))>2
                                sigma = std(temp{:,barelabel});
                            else
                                sigma = abs(temp{1,barelabel}-temp{2,barelabel});
                            end
                            newYData3row = [mu,temp{1,2:end-1},sigma];
                            yData3{counter}{end+1,:} = newYData3row;
                        end
                    end
                    %sort by heading, increasing from 0 - 180
                    yData3{counter} = sortrows(yData3{counter},'Heading');
                    hold on
                    if yData3{counter}{1,4} == 0   
                         errorbar(yData3{counter}{:,"Heading"},yData3{counter}{:,barelabel},yData3{counter}{:,"Stdev"},...
                             'Marker','o','MarkerFaceColor',col(colCounter,:),'Color',col(colCounter,:),'DisplayName',...
                             strcat({'\delta= '},string(yData3{counter}{1,"Steering"}),{' deg; U= '},...
                             string(yData3{counter}{1,"Target Flow Speed"}),{' m/s'}));
                    elseif yData3{counter}{1,4} > 0
                        errorbar(yData3{counter}{:,"Heading"},yData3{counter}{:,barelabel},yData3{counter}{:,"Stdev"},...
                             'Marker','<','MarkerFaceColor',col(colCounter,:),'Color',col(colCounter,:),'DisplayName',...
                             strcat({'\delta= '},string(yData3{counter}{1,"Steering"}),{' deg; U= '},...
                             string(yData3{counter}{1,"Target Flow Speed"}),{' m/s'}));
%                          plot(yData3{counter},'Heading',barelabel,'Marker','<','MarkerFaceColor',col(colCounter,:),...
%                              'Color',col(colCounter,:),'DisplayName',strcat({'\delta= '},string(yData3{counter}{1,"Steering"}),...
%                              {' deg; U= '},string(yData3{counter}{1,"Target Flow Speed"}),{' m/s'}));
                    else
                        errorbar(yData3{counter}{:,"Heading"},yData3{counter}{:,barelabel},yData3{counter}{:,"Stdev"},...
                             'Marker','>','MarkerFaceColor',col(colCounter,:),'Color',col(colCounter,:),'DisplayName',...
                             strcat({'\delta= '},string(yData3{counter}{1,"Steering"}),{' deg; U= '},...
                             string(yData3{counter}{1,"Target Flow Speed"}),{' m/s'}));
%                          plot(yData3{counter},'Heading',barelabel,'Marker','>','MarkerFaceColor',col(colCounter,:),...
%                              'Color',col(colCounter,:),'DisplayName',strcat({'\delta= '},string(yData3{counter}{1,"Steering"}),...
%                              {' deg; U= '},string(yData3{counter}{1,"Target Flow Speed"}),{' m/s'}));
                    end
                    counter = counter+1;
                end %end k for loop
            end %end j for loop
            title(strcat(barelabel,{' V. h/d= '},string(yData3{counter-1}{1,"h/D"})));
            xlabel("Heading (deg)");
            xticks(0:22.5:max(yData{:,"Heading"}));
            axis padded
            ylabel(label);
            legend('Location','bestoutside','NumColumns',1,"Interpreter","tex");
            hold off
            colCounter = 0;
            
        end
        %fix later!!!!!
        %figName = strcat(barelabel,{'_V_Heading_TiledLayout'});
        %print(figName,'-dmeta');
    else
        %Froude number instead of speed
        for i=1:length(fields)
            %depth froude number
            depth = yData{i,"Water Depth"}/100; %get target depth in m
            Fr = yData{i,"Flow Speed"}/(sqrt(gravity*depth)); %real speed yData{i,5}
            Sr = depth/(length_Scale^1/3);
            %scaling Fr
            FrSr = Fr*sqrt(Sr);
            yData(i,8) = {round(FrSr,1,"significant")};
            yData(i,9) = {round(Sr,2,"decimals")};
        
            if forces
                yData{i,1} = yData{i,barelabel}/(0.5*rho*yData{i,"Flow Speed"}^2*length_Scale^(2/3)*Sr^2); 
            else
                yData{i,1} = yData{i,barelabel}/(0.5*rho*yData{i,"Flow Speed"}^2*length_Scale*Sr^2);
            end
        end
        if forces
            label = strcat(barelabel,'/','$\frac{1}{2}*\rho*U^2*Vol^{2/3}*SR^2$');
                if strcmp(barelabel,'Fx')
                    barelabel = 'CFx';
                elseif strcmp(barelabel,'Fy')
                    barelabel = 'CFy';
                else
                    barelabel = 'CFz';
                end
        else
            label = strcat(barelabel,'/','$\frac{1}{2}*\rho*U^2*Vol*SR^2$');
                if strcmp(barelabel,'Mx')
                    barelabel = 'CMx';
                elseif strcmp(barelabel,'My')
                    barelabel = 'CMy';
                else
                    barelabel = 'CMz';
                end
        end

        yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
        "Steering","Flow Speed",'Target Flow Speed','h/D','Fr','Sr'];
        tiles = tiledlayout(3,3); %9 total angles
        depth = unique(yData{:,"Heading"});
        counter = 1;
        %figure out a better way to do this line coloring
        Froudes = unique(yData{:,"Fr"});
        col = lines(length(Froudes));
        colCounter = 0;
        yData1{1,4}=[];
        for i = 1:length(depth)
            %heading
            indH = yData{:,"Heading"}==depth(i);
            yData1{i} = yData(indH,:);
            n = unique(yData1{i}{:,"Fr"});
            yData2{1,3} = [];
            nexttile;
            for j = 1:length(n)
                %Froude number
                colCounter = colCounter+1;
                indn = yData1{i}{:,"Fr"}==n(j);
                yData2{j} = yData1{i}(indn,:);
                q = unique(yData2{j}{:,"Steering"});    
                for k = 1:length(q)
                    %steering
                    indq = yData2{j}{:,"Steering"}==q(k);
                    yData3{counter} = yData2{j}(indq,:);
                    %sort by Sr low to high
                    yData3{counter} = sortrows(yData3{counter},'Sr');
                    if yData3{counter}{1,4} == 0
                        hold on
                        plot(yData3{counter},'Sr',barelabel,'Marker','o','Color',col(colCounter,:),...
                            'DisplayName',strcat({'Fr= '},string(yData3{counter}{1,"Fr"}),...
                            {' \delta= '},string(yData3{counter}{1,"Steering"}),{' deg'}));
                    elseif yData3{counter}{1,4} > 0
                         plot(yData3{counter},'Sr',barelabel,'Marker','<','Color',col(colCounter,:),...
                            'DisplayName',strcat({'Fr= '},string(yData3{counter}{1,"Fr"}),...
                            {' \delta= '},string(yData3{counter}{1,"Steering"}),{' deg'}));
                    else
                         plot(yData3{counter},'Sr',barelabel,'Marker','>','Color',col(colCounter,:),...
                            'DisplayName',strcat({'Fr= '},string(yData3{counter}{1,"Fr"}),...
                            {' \delta= '},string(yData3{counter}{1,"Steering"}),{' deg'}));
                    end
                    counter = counter+1;
                end %end steering
                clear yData3
            end %end froude
            colCounter = 0;
            clear yData2
            title(strcat(barelabel,{' V. Submergence Ratio for \beta = '},string(depth(i))),Interpreter="tex");
            xLABEL = "Submergence Ratio ($\frac{H}{Volume^{\frac{1}{3}}}$)";
            xlabel(xLABEL,'Interpreter','latex');
            %xticks(0:22.5:max(yData{:,"Sr"}));
            ylabel(label,'Interpreter','latex');
            legend('Location','southoutside','NumColumns',j,Interpreter='tex');
            hold off
            %fix later !!!!!
            %figName = strcat(barelabel,{'SR_Heading'},string(Headings(i)));
            %savefig(gca,figName);
        end %end depth
            
    end

end