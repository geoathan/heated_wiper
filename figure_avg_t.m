function [avg,settling_index] = figure_avg_t( comparison,ansys_data,data,rubber,time,this_sim_name,ansys_sim_name)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if (comparison) 
    ANSYS_t=transpose(ansys_data(:,1));
    ANSYS_T=transpose(ansys_data(:,2)-273);
end
avg = zeros(size(data,1),1);
for i=1:rubber.nodes
    avg = avg + data(:,i);
end
avg=avg/(rubber.nodes);
    
area_avg = zeros(size(data,1),1);
for i=1:rubber.nodes
    area_avg = area_avg + data(:,i)*(rubber.th(i))/mean(rubber.th);
end
area_avg=area_avg/(rubber.nodes);


if (comparison)
    plot(time,avg,'k',ANSYS_t,ANSYS_T,'k--');
    legend(this_sim_name,ansys_sim_name,'Location','southeast')
else
    plot(t,avg,'k');
    legend('Average temperature')
end
title('Average Temperature Development');
xlabel('Time [s]');
ylabel('Average Node Temperature');
%settling time calculation  
settling_index = calculate_settling(avg,0.99);
if settling_index ~= 1
    hold on;
    plot(time(settling_index),avg(settling_index),'ko');
    if (comparison)
        legend(this_sim_name,ansys_sim_name,'Steady state marker','Location','southeast')
    else
        legend('Average Temperature development','Steady state marker','Location','southeast')
    end
end    
end

