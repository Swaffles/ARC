function arcPolarFigureMaker(data,index,label,barelabel,dimensional,forces,length_Scale,figureHandle)
%Inputs:
%ARC: data set containing all the necessary data for plotting
%index: Radius item
%label: Radius item name
%barelabel: label w/o units
%dimensional: toggle true false dimesionless (defualt dimensionless)
%forces: tells nondimensional part how to handle the nondimensionalization
%length scale: used for non dimensionalization
%figureHandle, the figure you wish to place the plots in

%Ydata = (data, water depth, heading, steering, flow speed)

rho = 1000; %water density

%rtick number of levels in polar plot
lvls = 4;
%how many points to use for zero level
zStep = 100;
%ALIM, limits of polar plot angle
aLim = [-22.5,190];
%ASTEP, steps for polar plot angle
aStep = 22.5;

if forces
    RUnits = 'N';
else
   RUnits = 'Nm';
end

%number of items to loop over
fields = fieldnames(data);
for i=1:length(fields)
    yData(i,1) = data.(fields{i})(index,2); %main Y-axis
    yData(i,2) = data.(fields{i})(13,2); %water depth cm
    yData(i,3) = data.(fields{i})(15,2); %heading
    yData(i,4) = data.(fields{i})(16,2); %steering
    temp2 = data.(fields{i}){17,2}/100; %flow speed m/s
    yData(i,5) = {temp2};
    yData(i,6) = data.(fields{i})(18,2); %target flow speed
    yData(i,7) = data.(fields{i})(19,2); %h/D
end
yData.Properties.VariableNames = [barelabel,"Water Depth","Heading",...
    "Steering","Flow Speed",'Target Flow Speed','h/D'];
if dimensional
    %use tiles for water depth  
    m = unique(yData{:,7}); %number of unique water depths (max 4)
    n = unique(yData{:,4}); %number of unique steering angles (3)
    counter = 1;
    subplotCounter = 1;
    tile = tiledlayout(length(m),length(n)); %4x3 layout
    tile.Padding = 'compact';
    tile.TileSpacing = 'compact';
    ax = nexttile;
    yData1{1,length(m)} = [];
    
    for i = 1:length(m)
        %Water depth loop
        indm = yData{:,7}==m(i);
        yData1{i} = yData(indm,:); %yData1 sorts water depth
        n = unique(yData1{i}{:,4});
        yData2{1,length(n)} = [];
        for j = 1:length(n)
            %steering loop
            indn = yData1{i}{:,4}==n(j);
            yData2{j} = yData1{i}(indn,:);
            q = unique(yData2{j}{:,6});
            rmin = round(min(yData2{j}{:,1}))-1;
            rmax = round(max(yData2{j}{:,1}))+1;
            if rmax<0
                step = (rmax-rmin)/lvls;
            else
                step = (abs(rmax)+abs(rmin))/lvls; %makes scaled steps
            end
            %this puts rmin at center of circle
            yData2{j}{:,1} = yData2{j}{:,1}+abs(rmin);
            subplotCounter = subplotCounter + 1;
            fig1 = figure;
            ph = makePolarGrid('Adir','cw','AZeroPos','top','ALim',aLim,...
                    'ATicks',0:aStep:aLim(2),'AMinorTicks',aStep,'RUnits',RUnits,...
                    'RLim',[(rmin+abs(rmin)), (rmax+abs(rmin))],...
                    'RTicks',step,'RLabelFormat','%.1f','RLabelAngle',aLim(1)-9.5);
            for s = 1:length(ph.RLabels)-1
                if s == lvls
                    temp = str2double(ph.RLabels(s+1).String(1:4))-abs(rmin);
                    temp = num2str(temp);
                    ph.RLabels(s+1).String = strcat(temp,{' '},RUnits);
                else
                    temp = str2double(ph.RLabels(s+1).String)-abs(rmin);
                    temp = num2str(temp);
                    ph.RLabels(s+1).String = temp;
                end
                clear temp
            end
            for k = 1:length(q)
                %speed
                indq = yData2{j}{:,6}==q(k);
                yData3{counter} = yData2{j}(indq,:);
                %sort by heading, increasing from 0 - 180
                yData3{counter} = sortrows(yData3{counter},'Heading');
                if yData3{counter}{1,6}==q(1)
                    [px,py] = polgrid2cart(yData3{counter}{:,3},yData3{counter}{:,1},ph);
                    p1 = plot(px,py,'r','Marker','o','LineWidth',1.5,...
                        'DisplayName',strcat('Target Speed= ',string(yData3{counter}{1,6}),' m/s')); 
                    clear px py
                    hold on
                elseif yData3{counter}{1,6}==q(2)
                    [px,py] = polgrid2cart(yData3{counter}{:,3},yData3{counter}{:,1},ph);
                    p2 = plot(px,py,'g','Marker','diamond','LineWidth',1.5,...
                        'DisplayName',strcat('Target Speed= ',string(yData3{counter}{1,6}),' m/s')); 
                    clear px py
                elseif yData3{counter}{1,6}==q(3)
                    [px,py] = polgrid2cart(yData3{counter}{:,3},yData3{counter}{:,1},ph);
                    p3 = plot(px,py,'b','Marker','*','LineWidth',1.5,...
                        'DisplayName',strcat('Target Speed= ',string(yData3{counter}{1,6}),' m/s')); 
                    clear px py
                else
                    [px,py] = polgrid2cart(yData3{counter}{:,3},yData3{counter}{:,1},ph);
                    p4 = plot(px,py,'k','Marker','^','LineWidth',1.5,...
                        'DisplayName',strcat('Target Speed= ',string(yData3{counter}{1,6}),' m/s')); 
                    clear px py
                end
                counter = counter+1;
            end
            %zero level, only make this if rmax is positive
            if rmax >= 0 && rmin<=0 
                theta = linspace(aLim(1),aLim(2),zStep);
                zerolvl = zeros(1,zStep)+abs(rmin);
                [px,py] = polgrid2cart(theta,zerolvl,ph);
                plot(px,py,'k:','HandleVisibility','off','LineWidth',3); clear px py
                %contour plot for dividing positive and negative regions
                [mt,mr]=meshgrid(theta,[0 abs(rmin) abs(rmin)+0.01 abs(rmax)+abs(rmin)]);
                [px,py] = polgrid2cart(mt,mr,ph);
                [~,hc] = contourf(px,py,mr,[0 abs(rmin) inf]);
                colormap([0 0 1;1 0 0]);
                uistack(hc,'bottom');
                hc.LineStyle = 'none';
                eventFcn = @(srcObj, e) updateTransparency(srcObj);
                addlistener(hc, 'MarkedClean', eventFcn);
            elseif rmin>0
                %contour plot for positive only
                [mt,mr]=meshgrid(theta,[0 abs(rmin) abs(rmin)+0.01 abs(rmax)+abs(rmin)]);
                [px,py] = polgrid2cart(mt,mr,ph);
                [~,hc] = contourf(px,py,mr,[0 abs(rmin) inf]); %[0 abs(rmin) inf]
                colormap([1 0 0]); %colormap([0 0 1;1 0 0]);
                uistack(hc,'bottom');
                hc.LineStyle = 'none';
                eventFcn = @(srcObj, e) updateTransparency(srcObj);
                addlistener(hc, 'MarkedClean', eventFcn);
            else
                %contour plot for negative only
                [mt,mr]=meshgrid(theta,[0 abs(rmin)-abs(rmax)]); %abs(rmin)+0.01 abs(rmax)+abs(rmin)
                [px,py] = polgrid2cart(mt,mr,ph);
                %hc = area(theta,py);
                [~,hc] = contourf(px,py,mr,[0 abs(rmin) inf]); %[0 abs(rmin) inf]
                colormap([0 0 1]); %colormap([0 0 1;1 0 0]);
                uistack(hc,'bottom');
                hc.LineStyle = 'none';
                eventFcn = @(srcObj, e) updateTransparency(srcObj);
                addlistener(hc, 'MarkedClean', eventFcn);
            end
            title(strcat(barelabel,' for h/d= ',string(yData3{counter-1}{1,7}),' and steering= ',string(yData3{counter-1}{1,4})));

            %legend handeling
            if exist('p1') && exist('p2') && exist('p3') && exist('p4')
                legend([p1 p2 p3 p4],Location = 'southoutside')
            elseif exist('p1') && exist('p2') && exist('p3')
                legend([p1 p2 p3],Location = 'southoutside')
            elseif exist('p1') && exist('p2')
                legend([p1 p2],Location = 'southoutside')
            else
                legend(p1,Location = 'southoutside')
            end
            hold off
            clear p4 %this is used ONLY to compare for old data 12-13-22
            %copy polar plot to tiledlayout
            if i==length(m) && j == length(n)
                 axcp = copyobj(gca,figureHandle,'legacy');
                 if rmin>0
                    colormap(axcp,[1 0 0]); %red for positive
                 elseif rmax<0
                     colormap(axcp,[0 0 1]); %blue for negative
                 else
                     colormap(axcp,[0 0 1;1 0 0]);
                 end
                 eventFcn = @(srcObj, e) updateTransparency(srcObj);
                 hc = axcp.Children(end);
                 addlistener(hc, 'MarkedClean', eventFcn);
                 uistack(hc,'bottom');
                 hc.LineStyle = 'none';
                 hc.HandleVisibility = 'off';
                 legend(axcp,Location="bestoutside")
                 set(axcp,'Position',get(ax,'position'));
                 delete(ax); 
                 close(fig1);
                break
            else
                 axcp = copyobj(gca,figureHandle,'legacy');
                 if rmin>0
                    colormap(axcp,[1 0 0]); %red for positive
                 elseif rmax<0
                     colormap(axcp,[0 0 1]); %blue for negative
                 else
                     colormap(axcp,[0 0 1;1 0 0]);
                 end
                 eventFcn = @(srcObj, e) updateTransparency(srcObj);
                 hc = axcp.Children(end);
                 addlistener(hc, 'MarkedClean', eventFcn);
                 uistack(hc,'bottom');
                 hc.LineStyle = 'none';
                 hc.HandleVisibility = 'off';
                 legend(axcp,Location="bestoutside")
                 set(axcp,'Position',get(ax,'position'));
                 delete(ax); 
                 close(fig1);
                 ax = nexttile(tile,subplotCounter);
                 clear p1 p2 p3
            end %end of speed loop
        end %end of steering loop
        clear yData2
    end %end of depth loop
else
      fprintf("Nondimensional not yet built\n");
end %end of if dimensional

end




% function to handle contour transparency.
function updateTransparency(contourObj)
    contourFillObjs = contourObj.FacePrims;
    for i = 1:length(contourFillObjs)
        % Have to set this. The default is 'truecolor' which ignores alpha.
        contourFillObjs(i).ColorType = 'truecoloralpha';
        % The 4th element is the 'alpha' value. First 3 are RGB. Note, the
        % values expected are in range 0-255.
        contourFillObjs(i).ColorData(4) = 50;
    end
end

