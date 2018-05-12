classdef convection
    %UNTITLED Summary of this class goes here
    %convection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   
    % L1 -> where the heat transfer starts being applied with respect to the top
    % L2 -> where the heat transfer stops being applied with respect to the top
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        h    % convection coefficient
        node_start % if we have 1D simulation this signifies the node where the convection starts
        nodes      % if we have 1D simulation this signifies on how many nodes the convection is applied
        node_end   % if we have 1D simulation this signifies the node where the convection stops being applied
    end
    
    methods
        function obj = convection(  input_h, node_start, node_end )
           
                
            obj.h=input_h;
            obj.node_start = node_start;
            obj.node_end = node_end;
            obj.nodes = node_end-node_start+1;
            
        end
        
    end
    
end

