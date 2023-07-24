function SampleCode_V1_Elmoya
clc;clear;close all
global x_max_coverage_area x_min_coverage_area y_max_coverage_area y_min_coverage_area
global th n_radar


x_min_coverage_area = 0; % km
x_max_coverage_area = 80; % km
y_min_coverage_area = 0; % km
y_max_coverage_area = 50; % km

figure(1)
plot_area(x_min_coverage_area,x_max_coverage_area,y_min_coverage_area,y_max_coverage_area)


n_radar = 1;

r = 20;  % radar radius (km)

th = 0:pi/50:2*pi;

x1_min=x_min_coverage_area-30; % km
x1_max=x_max_coverage_area+30; % km
y1_min=y_min_coverage_area-30; % km
y1_max=y_max_coverage_area+30; % km

info = plot_radar_position_and_area(x1_min,x1_max,y1_min,y1_max,r);

xlim([-50 130])
ylim([-50 100])

end

function info = plot_radar_position_and_area(x_min,x_max,y_min,y_max,r)
global th
xc = unifrnd(x_min,x_max); % x position of circle center
yc = unifrnd(y_min,y_max); % y position of circle center
x = r * cos(th) + xc;
y = r * sin(th) + yc;

plot(x, y,'color','b','LineWidth',1);
plot(xc,yc,'o','markerfacecolor','b','markeredgecolor','b','markersize',5)

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
