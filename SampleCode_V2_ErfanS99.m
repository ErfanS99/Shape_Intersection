function SampleCode_V2_ErfanS99
    %% Variable introducing
    tic
    clc;clear;close all;
    dbstop error
    global x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area
    global th

    x_min_coverage_area = 0; % km
    x_max_coverage_area = 80; % km
    y_min_coverage_area = 0; % km
    y_max_coverage_area = 50; % km



    figure('Position',[400,100,720,580])
    plot_area(x_min_coverage_area,x_max_coverage_area,y_min_coverage_area,y_max_coverage_area)


    n_radar = 5;

    r = 20;  % radar radius (km)

    th = 0:pi/5600:2*pi;
    
    xlim([-50 130])
    ylim([-50 100])

    x1_min = x_min_coverage_area - 30; % km
    x1_max = x_max_coverage_area + 30; % km
    y1_min = y_min_coverage_area - 30; % km
    y1_max = y_max_coverage_area + 30; % km
    
    color = zeros(5,3);
    inCircles = 1;
    outCircles = 0;
    xy_and_c = cell(5,n_radar);
    inBoxCircles = cell(5,1);
    %% Primary calculation
    
    for n = 1:n_radar
        
        % Finding Random Color for every circle
        while 1                                                            
            color(n,:) = rand(1,3);
            if ~isequal(color(n,:),[1 1 1]) && ~isequal(color(n,:),[0 0 0])
                break
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Ploting box the finding coordinates of the circles
        info = radar_position_and_area(x1_min,x1_max,y1_min,y1_max,r);
        [inOrout, Area] = findCoordinates(info);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Storing the Circles Coordinates in a variable for later use
        xy_and_c(:,n) =  struct2cell(info);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Checking the in box and out box circles
        if inOrout
            Area.n = n;
            % Storing the Circles Coordinates in a variable for later use
            inBoxCircles(:,inCircles) = struct2cell(Area);
            inCircles = inCircles + 1;
        else
            outCircles = outCircles + 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %% Circles area calculations and plotting instersection areas
    if outCircles ~= n_radar
        inBoxCircles = cell2struct(inBoxCircles,{'x';'y';'area';'Corner';'N'},1);
        inBoxCircles = sortStruct(inBoxCircles,'area');
        
        % Filling the in box circles
        for n = 1:(length(inBoxCircles))
            fill(inBoxCircles(n).x,inBoxCircles(n).y,color(inBoxCircles(n).N,:));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        xy_and_c = cell2struct(xy_and_c, {'xc';'yc';'r';'x';'y'}, 1);
        
        % Plotting and filling the circles
        for n = 1:n_radar
            text(xy_and_c(n).xc+3,xy_and_c(n).yc-3,num2str(n));
            plot(xy_and_c(n).x, xy_and_c(n).y,'color',color(n,:),'LineWidth',2);
            plot(xy_and_c(n).xc, xy_and_c(n).yc,'o','markerfacecolor','r'...
                ,'markeredgecolor','r','markersize',5) 
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        inBoxCircles = intersectionSubstraction(inBoxCircles);

        % Printing the results
        for n=1:n_radar
            for nn = 1 : length(inBoxCircles)
                if n == inBoxCircles(nn).N
                    fprintf("Circle %d Intersection Area is %0.4f [km^2]\n",n,inBoxCircles(nn).area);
                    break;
                elseif nn == length(inBoxCircles)
                    fprintf("Circle %d has no Intersection\n",n);
                    continue;
                end
            end
        end
        
        
    else
        close all;
        fprintf("No Circle has any Intersection\n");
    end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    toc
end
        
%%
function info = radar_position_and_area(x_min,x_max,y_min,y_max,r)
    global th x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area

    while (true)
        xc = unifrnd(x_min,x_max); % x position of circle center
        yc = unifrnd(y_min,y_max); % y position of circle center

        x = r * cos(th) + xc;
        y = r * sin(th) + yc;
        if ((xc >= x_max_coverage_area) || (xc <= x_min_coverage_area)) ...
                && ((yc >= y_max_coverage_area) || (yc <= y_min_coverage_area))  
            break
        end
    end
 
    info.xc = xc;
    info.yc = yc;
    info.r = r;
    info.x = x;
    info.y = y;

end


function plot_area(x_min,x_max,y_min,y_max)
plot([x_min x_min],[y_min,y_max],'k','Linewidth',2)
hold on
plot([x_min x_max],[y_max,y_max],'k','Linewidth',2)
plot([x_max x_max],[y_max,y_min],'k','Linewidth',2)
plot([x_max x_min],[y_min,y_min],'k','Linewidth',2)
end

function findIntersection(x,y)
    global xMin yMin xMax yMax

    if (xMin >= x) 
        xMin = x;
    end
    if (xMax <= x)
        xMax = x;
    end
    if (yMin >= y)
        yMin = y;
    end
    if (yMax <= y)
        yMax = y;
    end
end

function corner = findCorner(xc, yc)
global x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area
    
    RC=0;LC=0;UC=0;DC=0;

   if abs(xc - x_max_coverage_area) > abs(xc - x_min_coverage_area) % Left Corener
       LC = true;
   elseif abs(xc - x_max_coverage_area) < abs(xc - x_min_coverage_area) % Right Corner
       RC = true;
   end
   
   if abs(yc - y_max_coverage_area) > abs(yc - y_min_coverage_area) % Down Corener
       DC = true;
   elseif abs(yc - y_max_coverage_area) < abs(yc - y_min_coverage_area) % Upper Corner
       UC = true;
   end
   
   if RC && UC
       corner = "UR";
   elseif RC && DC
       corner = "DR";
   elseif LC && UC
       corner = "UL";
   elseif LC && DC
       corner = "DL";
   end
   
end

function out = merging(corner, x_inArea, y_inArea)
global x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area

   if corner == "UR"
       x_inArea(end+1) = x_max_coverage_area;
       x_inArea(end+1) = x_inArea(1);
       y_inArea(end+1) = y_max_coverage_area;
       y_inArea(end+1) = y_inArea(1);
   elseif corner == "UL"
       x_inArea(end+1) = x_min_coverage_area;
       x_inArea(end+1) = x_inArea(1);
       y_inArea(end+1) = y_max_coverage_area;
       y_inArea(end+1) = y_inArea(1);
   elseif corner == "DR"
       x_inArea(end+1) = x_max_coverage_area;
       x_inArea(end+1) = x_inArea(1);
       y_inArea(end+1) = y_min_coverage_area;
       y_inArea(end+1) = y_inArea(1);
   elseif corner == "DL"
       x_inArea(end+1) = x_min_coverage_area;
       x_inArea(end+1) = x_inArea(1);
       y_inArea(end+1) = y_min_coverage_area;
       y_inArea(end+1) = y_inArea(1);
   end
   out.x_inArea = x_inArea;
   out.y_inArea = y_inArea;
end

function [inOrout, Area] = findCoordinates(info)
    global xMin yMax yMin xMax
    global x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area
    
    xMin = 130;
    yMin = 130;
    yMax = 0;
    xMax = 0;
    x_inArea = 0;
    y_inArea = 0;

    x = info.x;
    y = info.y;
    inArea = find(((x_min_coverage_area <= x)&(x_max_coverage_area >= x))...
        & ((y_min_coverage_area <= y)&(y_max_coverage_area >= y)));
    
    if inArea
        j = 0;
        for i=inArea
            j = j + 1;
            findIntersection(x(i),y(i));
            x_inArea(j) = x(i);
            y_inArea(j) = y(i);
        end

       corner = findCorner(info.x,info.y);
       Area = merging(corner,x_inArea,y_inArea);
       Area.area = polyarea(Area.x_inArea,Area.y_inArea);
       Area.corner = corner;
       inOrout = true;
    else
       Area = nan;
       inOrout = false;
    end

end

function strc = sortStruct(strc,header)
    strc = struct2table(strc);
    strc = sortrows(strc,header);
    strc = table2struct(strc);
end

function inBoxCircles = intersectionSubstraction(inBoxCircles)
        if length(inBoxCircles) > 1
            for i=1:floor(length(inBoxCircles)/2)
               for j=1:length(inBoxCircles)
                   if inBoxCircles(i).Corner == inBoxCircles(j).Corner
                       if (inBoxCircles(i).area == inBoxCircles(j).area) || (i==j)
                           continue;
                       elseif inBoxCircles(i).area > inBoxCircles(j).area
                           inBoxCircles(i).area = inBoxCircles(i).area - inBoxCircles(j).area;
                           break;
                       else
                           inBoxCircles(j).area = inBoxCircles(j).area - inBoxCircles(i).area;
                           break;
                       end
                   end
               end
            end
        end
end