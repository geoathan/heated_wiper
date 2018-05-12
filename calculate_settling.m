function [ settling_index ] = calculate_settling(data,tolerance_fraction)
%CALCULATE_SETTLING calculates the settling index according to the
%tolerance fraction
%   The 'data' input is a nx1 matrix including a monotonically increasing
%   variable. The function detects when we reach steady state by checking
%   when the next value becomes smaller than the previous (because of
%   oscilations from the ode45 function). This method showed to always show
%   the final steady state value. Then the time for which the settling time
%   corresponds is calculated through the tolerance_fraction. If the
%   function doesnt detect a final steady state, the output values settling
%   index is sent to 1. 
k=0;
for i = 1 : (length(data)-1)
    if data(i)-data(i+1) > 0 %looks for when the function becomes completely constant (a bit unorthodox because looks for positive which should ideally not exist)
        k=i;
        break;
    end
end

if k>0
    settling_value = data(k)*tolerance_fraction; % checking when the temperature reaches 95 percent of the steady state value
    for m = 1 : (length(data)-1)
        if data(m) > settling_value
            settling_index=m;
        break
        end
    end
else
    settling_index=1;
end


end

