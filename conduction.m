classdef conduction
    %Conduction creates a 'conduction' object
    %   A conduction object has the necessary parameters to define a
    %   conduction boundary condition.
    
    properties
        L1   % length with respect to the top of where the heat transfer starts being applied in 1D simulation
        L2   % length with respect to the top of where the heat transfer stops being applied in 1D simulation
        L    % total length where the convection is applied in 1D
        node_start % if we have 1D simulation this signifies the node where the convection starts
        nodes      % if we have 1D simulation this signifies on how many nodes the convection is applied
        node_end   % if we have 1D simulation this signifies the node where the convection stops being applied
        mode       % if mode is true this is a constant temperature boundary condition if mode is false this is a constant heat boundary condition
        T          % [C] Temperature of the conduction, this temperature will fix some of the nodes at this temperature
        Q          % [W/m^2]
    end
    
    methods
        function obj = conduction(input_L1, input_L2 , mode , input, nodes, total_length)
            obj.L1=input_L1;
            obj.L2=input_L2;
            obj.L=input_L2-input_L1;
            obj.mode=mode;
            obj.node_start = round((input_L1/total_length)*nodes);
            obj.node_end = round((input_L2/total_length)*nodes);
            obj.nodes = round((input_L2/total_length)*nodes)-round((input_L1/total_length)*nodes)+1 ; % because the first node is also included in the loop
            if mode
                obj.T = input;
            else
                obj.Q =input;
            end
        end
        
    end
    
end

