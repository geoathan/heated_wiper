function [] = figure_shape( rubber,output,map )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
hor_span=1.1;
ver_span=1;
max_vertical = rubber.height*1000*ver_span;
max_horizontal = max(rubber.th)*1000*hor_span;
middle_horizontal = max_horizontal/2;
vertical_increment=rubber.delta_x*1000;


steady_state_row = output(length(output),:);
max_temp = max(steady_state_row);
min_temp = min(steady_state_row);


fill([0 0 0 0], [0 0 0 0], [1,0,0]) % dummy for red color at legend
hold on;
fill([0 0 0 0], [0 0 0 0], [0,0,1]) % dummy for blue color at legend
hold on;
for i = 1 :rubber.nodes 
    left = middle_horizontal-rubber.th(i)*1000/2;
    right = middle_horizontal+rubber.th(i)*1000/2;

    top = max_vertical-vertical_increment *(i-1);
    bottom =max_vertical-vertical_increment *(i);
    
    temperature_percentage = (steady_state_row(i)-min_temp)/(max_temp-min_temp);
    
    x = [left left right right];
    y = [bottom top top bottom];
    
    if (temperature_percentage <= 0.25)
        R = 0;
        G = temperature_percentage*4;
        B = 1;            
    elseif (temperature_percentage <= 0.5)
        R = 0;
        G = 1;
        B = 1 - 4*(temperature_percentage-0.25);   
    elseif (temperature_percentage <= 0.75) 
        R = 0 + 4*(temperature_percentage-0.50);
        G=1;
        B=0; 
    else
        R = 1;
        G = 1 - 4*(temperature_percentage-0.75);
        B = 0; 
    end    
        
   
    
    %if (temperature_percentage <= 0.5)
    %    G = temperature_percentage*2;
    %else
    %    G = 2 - temperature_percentage*2;
    %end
        
    %B = 1-temperature_percentage;
    
    fill(x, y, [R,G,B])
    hold on

end
hold off
axis([0 max_horizontal 0 max_vertical]);
%title(['Wiper blade rubber profile, t=',num2str(sim_time),' seconds']  ); 
legend( 'Location','southeast', {strcat('max T : ' , num2str(max_temp,3), ' C' ),strcat('min T : ' , num2str(min_temp,3), ' C' )} );
axis off;
%xlabel('');
%ylabel('');
colorbar;


colormap(map);
caxis([min_temp max_temp]);
clear('R1','G1','B1','R','G','B','max_horizontal','max_vertical','middle_horizontal','left','right','map','color_percentage','shades','x','y','top','bottom');

% end of color script

end

