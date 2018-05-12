function [ map ] = RGB_map( shades )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
for i = 1 : shades
    color_percentage=i/shades;
    if (color_percentage <= 0.25)
            R1 = 0;
            G1 = color_percentage*4;
            B1 = 1;            
        elseif (color_percentage <= 0.5)
            R1 = 0;
            G1 = 1;
            B1 = 1 - 4*(color_percentage-0.25);   
        elseif (color_percentage <= 0.75) 
            R1 = 0 + 4*(color_percentage-0.50);
            G1=1;
            B1=0; 
        else
            R1 = 1;
            G1 = 1 - 4*(color_percentage-0.75);
            B1 = 0; 
    end    
    map(i,:)=[R1 G1 B1];
end  

end

