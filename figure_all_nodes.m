function[]  = figure_all_nodes( nodes, data,t )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
figure(1)
    for i=1:nodes
       plot(t,data(:,i)) 
       hold on
    end
    title('Temperature Development');
    xlabel('Time [s]');
    ylabel('Node Temperature [C]');
    
end

