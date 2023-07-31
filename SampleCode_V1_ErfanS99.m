function SampleCode_V1_ErfanS99
    clc;clear;close all;
    dbstop error
    global x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area
    global th
    global xMin yMin xMax yMax
    x_min_coverage_area = 0; % km
    x_max_coverage_area = 80; % km
    y_min_coverage_area = 0; % km
    y_max_coverage_area = 50; % km



    figure('Position',[400,100,720,580])
    plot_area(x_min_coverage_area,x_max_coverage_area,y_min_coverage_area,y_max_coverage_area)


    n_radar = 5;

    r = 20;  % radar radius (km)

    th = 0:pi/5600:2*pi;

    x1_min = x_min_coverage_area - 30; % km
    x1_max = x_max_coverage_area + 30; % km
    y1_min = y_min_coverage_area - 30; % km
    y1_max = y_max_coverage_area + 30; % km



    xlim([-50 130])
    ylim([-50 100])
    %%

for n = 1:n_radar
    xMin = 130;
    yMin = 130;
    yMax = 0;
    xMax = 0;
    x_inArea = 0;
    y_inArea = 0;
    info = plot_radar_position_and_area(x1_min,x1_max,y1_min,y1_max,r);
    x = info.x;
    y = info.y;
    xc = info.xc;
    yc = info.yc;
    text(xc+3,yc-3,num2str(n));
    inArea = find(((x_min_coverage_area <= x)&(x_max_coverage_area >= x)) & ((y_min_coverage_area <= y)&(y_max_coverage_area >= y)));

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

       fill(Area.x_inArea,Area.y_inArea,'g');

       fprintf("Circle %d Intersection Area is %0.4f [km^2]\n",n,polyarea(Area.x_inArea,Area.y_inArea));
    else 
        fprintf("Circle %d has no Intersection\n",n);
    end

end
end
        
%%
function info = plot_radar_position_and_area(x_min,x_max,y_min,y_max,r)
    global th x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area

    while (true)
        xc = unifrnd(x_min,x_max); % x position of circle center
        yc = unifrnd(y_min,y_max); % y position of circle center

        x = r * cos(th) + xc;
        y = r * sin(th) + yc;
        if ((xc >= x_max_coverage_area) || (xc <= x_min_coverage_area)) && ((yc >= y_max_coverage_area) || (yc <= y_min_coverage_area))  
            break
        end
    end

    plot(x, y,'color','b','LineWidth',2);
    plot(xc,yc,'o','markerfacecolor','r','markeredgecolor','r','markersize',5)

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

