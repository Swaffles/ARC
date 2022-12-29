function arcContourFigureMaker(data,index,label,barelabel,dimensional,forces,length_Scale)
%Inputs:
%ARC: data set containing all the necessary data for plotting
%index: Contour Z item
%label: Contour Z item name
%barelabel: label w/o units
%dimensional: toggle true false dimesionless (defualt dimensionless)
%forces: tells nondimensional part how to handle the nondimensionalization
%length scale: used for non dimensionalization

%Ydata = (data, water depth, heading, steering, flow speed)

rho = 1000; %water density

%number of points for countour
np = 100;

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
        n = unique(yData{:,4});
        tile = tiledlayout(length(m),length(n)); %4x3 layout
        counter = 1;
        %levels of contour
        med = round(median(yData{:,1}));
        step = round(std(yData{:,1}));
        lvl = med-3*step:step:med+3*step;
        for i = 1:length(m)
            %depth
            indm = find(yData{:,7}==m(i));
            yData1{i} = yData(indm,:);
            q = unique(yData1{i}{:,4});
            %ax = nexttile;
            for k = 1:length(q)
                %steering
                ax = nexttile;
                indq = find(yData1{i}{:,4}==q(k));
                yData3{counter} = yData1{i}(indq,:);
                tempX = linspace(min(yData3{counter}{:,3}),max(yData3{counter}{:,3}),np);
                tempY = linspace(min(yData3{counter}{:,5}),max(yData3{counter}{:,5}),np);
                [X,Y] = meshgrid(tempX,tempY);
                Z = griddata(yData3{counter}{:,3},yData3{counter}{:,5},yData3{counter}{:,1},X,Y);
                hold on
                if yData3{counter}{1,4} == 0
                    colormap(ax,parula)
                    contour(X,Y,Z,lvl,'ShowText','on'); %10 levels
                    title(strcat(barelabel,' Contours for h/d= ',string(yData3{counter}{1,7}),' and steering= ',string(yData3{counter}{1,4})));
                    xlabel("Heading (deg)");
                    xticks(0:22.5:max(yData{:,3}));
                    ylabel("Flow Speed (m/s)");
                    hold off
                elseif yData3{counter}{1,4} > 0
                     colormap(ax,"jet")
                     contour(X,Y,Z,lvl,'ShowText','on');
                     title(strcat(barelabel,' Contours for h/d= ',string(yData3{counter}{1,7}),' and steering= ',string(yData3{counter}{1,4})));
                     xlabel("Heading (deg)");
                     xticks(0:22.5:max(yData{:,3}));
                     ylabel("Flow Speed (m/s)");
                     hold off
                else
                     colormap(ax,"cool")
                     contour(X,Y,Z,lvl,'ShowText','on');
                     title(strcat(barelabel,' Contours for h/d= ',string(yData3{counter}{1,7}),' and steering= ',string(yData3{counter}{1,4})));
                     xlabel("Heading (deg)");
                     xticks(0:22.5:max(yData{:,3}));
                     ylabel("Flow Speed (m/s)");
                     hold off
                end
                counter = counter+1;
                %ax = nexttile;
            end
        end
    else
%         if forces
%             for i=1:height(yData)
%                 yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale^(2/3));
%             end
%             label = strcat(barelabel,'/1/2*rho*U^2*Vol^2/3'); %TODO make latex
%             if strcmp(barelabel,'Fx')
%                 barelabel = 'CFx';
%             elseif strcmp(barelabel,'Fy')
%                 barelabel = 'CFy';
%             else
%                 barelabel = 'CFz';
%             end
%         else
%             for i=1:height(yData)
%                 yData{i,1} = yData{i,1}/(0.5*rho*yData{i,5}^2*length_Scale);
%             end
%             label = strcat(barelabel,'/1/2*rho*U^2*Vol'); %TODO make latex
%             if strcmp(barelabel,'Mx')
%                 barelabel = 'CMx';
%             elseif strcmp(barelabel,'My')
%                 barelabel = 'CMy';
%             else
%                 barelabel = 'CMz';
%             end
%         end
%         yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
%         "Steering","Flow Speed",'Target Flow Speed','h/D'];
%         %use tiles for water depth 
%         m = unique(yData{:,7});
%         tile = tiledlayout(length(m),1); %4x1 layout
%         col = lines(length(m)*length(unique(yData{:,4})));
%         counter = 1;
%         colCounter = 0;
%         for i = 1:length(m)
%             %depth
%             indm = find(yData{:,7}==m(i));
%             yData1{i} = yData(indm,:);
%             q = unique(yData1{i}{:,4});   
%             nexttile;
%             for k = 1:length(q)
%                 %steering
%                 indq = find(yData1{i}{:,4}==q(k));
%                 yData3{counter} = yData1{i}(indq,:);
%                 colCounter = colCounter+1;
%                 if yData3{counter}{1,4} == 0
%                     hold on
%                     plot(yData3{counter},'Heading',barelabel,'LineStyle','none','Marker','o','Color',col(colCounter,:),...
%                         'DisplayName',strcat("Steering= ",string(yData3{counter}{1,4}),'deg'));
%                 elseif yData3{counter}{1,4} > 0
%                      plot(yData3{counter},'Heading',barelabel,'LineStyle','none','Marker','<','Color',col(colCounter,:),...
%                         'DisplayName',strcat("Steering= ",string(yData3{counter}{1,4}),'deg'));
%                 else
%                      plot(yData3{counter},'Heading',barelabel,'LineStyle','none','Marker','>','Color',col(colCounter,:),...
%                         'DisplayName',strcat("Steering= ",string(yData3{counter}{1,4}),'deg'));
%                 end
%                 counter = counter+1;
%             end
%             title(strcat(barelabel,' V. h/d= ',string(yData3{counter-1}{1,7})));
%             xlabel("Heading (deg)");
%             xticks(0:22.5:max(yData{:,3}));
%             ylabel(label);
%             legend('Location','southoutside','NumColumns',k);
%             hold off
%         end
          fprintf("Nondimensional not yet built\n");
    end

end