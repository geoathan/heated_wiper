classdef simulation_object
    %In this class a one dimensional wall simulation object is defined
    %   The simulation object includes geometrical and material properties
    %   of the object. The object is assumed to be a wall.
    %
    % exposed area marked with x, and also from the oposite side, the front
    % and back area are not exposed because the material continues in that
    % direction. The exposed area is used for convection boundary
    % conditions. The edje of the wall that defines the exposed area could
    % be of any height, then the area corresponding to one node would grow,
    % but the mass corresponding to the node would also grow
    % proportionally. 
    % as a result the cross section of the object is a rectangle of edge
    % height L and t and each node coresponds to a cuboid of dimensions
    % L*dx*t. t is the thickness of the wall and should be defined 
    % according to the thickness or the average thickness of the wall
    %In this case, the totax exposed surface would be 2*?x*L
    %            ______            _             _______ 
    % -->      /      /| <--        |           /      /|
    % -->     /_____ /x| <--        |          /      / |  Delta_x
    % -->    |   0  |xx| <--        |         /    0 / /  <- volume for 1 node
    % -->    |   |  |xx| <--        |        /______/ / L 
    % -->    |   0  |xx| <--        | height|_______|/  
    % -->    |   |  |xx| <--        |           t
    % -->    |   0  |xx| <--        |
    % -->    |   |  |xx| <--        |
    % -->    |   0  |x/  <--       _|    
    % -->    |______|/ L               
    %            t
    properties
    
    %geometric properties
    height;  %[m] height from top to bottom of the profile (1D dimension)
    length; % [m] total length in the logitudinal direction. direction through which the profile has constant shape
    %exposed_area; % [m^2] area of the simulated 1D object that is in contact with (see figure)
    
    delta_x; % [m] height of th cross section.
    volume; % [m^3]
    mass; %[kg]
    th;% dynamic thickneses of each node [m]
    A; %common width between two nodes [m] (one dimensional!)
    
    
    %material properties
    cp; % specific heat [j/kg*K] !!!!
    k_conduction; % [W/mK]
    rho; % material density [kg/m^3]
    alpha; % alpha = k_conduction/(cp*rho)
    
    %mesh
    nodes; 
    node_mass;  %[kg]
    node_volume; %[m^3]
    node_exposed_area_sides; %[m^2]
    node_exposed_area_top; %[m^2]
    node_exposed_area_bottom; %[m^2]
    
   
    end
    
    methods
        function obj=simulation_object(height,length,t,nodes,cp,k_conduction,rho,smoothing) 
            obj.cp = cp;
            obj.k_conduction = k_conduction;
            obj.rho = rho;
            obj.alpha=k_conduction/(cp*rho);
            
            obj.height=height;
            obj.length=length;
           % obj.exposed_area= 2*height*length;
            obj.delta_x=height/nodes;
            obj.volume=length*t*height;
            obj.mass = length*t*height*rho;
            obj.nodes= nodes;
           % obj.node_mass= length*delta_x*t*rho;
           % obj.node_volume=length*delta_x*t;
            obj.node_exposed_area_sides= ones(1,nodes)*(2*length*(height/nodes));
            obj.th=t;
            th=t;
                
            for i= 1 : (nodes-1)
                A(i) = min(th(i),th(i+1)); % common contact widrth between the nodes
            end                
            obj.A=A;  
            
            A_top(1)=th(1);
            for i= 1 : (nodes-1)
                if (th(i+1)-th(i))>0 % top exposed width of each node
                    A_top(i+1)=(th(i+1)-th(i));
                else
                    A_top(i+1)=0;
                end
            end 
            obj.node_exposed_area_top=length*A_top; % top exposed area of each node
          
            
            for i= 1 : (nodes-1)
                if (th(i)-th(i+1))>0
                    A_bottom(i)=th(i)-th(i+1);% bottom exposed width of each node
                else
                    A_bottom(i)=0;
                end
            end
            A_bottom(nodes)=th(nodes);
            obj.node_exposed_area_bottom=length*A_bottom;% bottom exposed area of each node
           
            
            volume=0;
            mass=0;
                
            for i = 1 : nodes;
                volume = volume + (height/nodes)*th(i)*length; %total object volume is the sum of all node volumes
                mass = mass +(height/nodes)*th(i)*length*rho; % total object mass is the mass of all node masses
                obj.node_mass(i) = (height/nodes)*th(i)*length*rho; % mass for one node
                obj.node_volume(i) = (height/nodes)*th(i)*length; % volume for one node
            end
            obj.volume = volume;
            obj.mass = mass;
             
            %calculation of inclined top surfaces
            
            temporary = zeros(1,obj.nodes);
            for i=1:obj.nodes-1
               if (obj.node_exposed_area_top(i+1) ~= 0) %if the below node top exposed surface its not zero, we have to calculate the inclined surface, so we make pythagorean with the exposed top of the node below and the side surface.
                 temporary(i)= 2* sqrt( (obj.node_exposed_area_sides(i)/2).^2 + (obj.node_exposed_area_top(i+1)/2).^2)     ;
               end  
            end
            temporary(1)=temporary(1)+obj.node_exposed_area_top(1);
            inclined_top_area = temporary;
            %calculation of inclined bottom surfaces
            temporary = zeros(1,obj.nodes);
            for i=2:obj.nodes
                if (obj.node_exposed_area_bottom(i-1) ~= 0)
                    temporary(i) = 2* sqrt( (obj.node_exposed_area_sides(i)/2).^2 + (obj.node_exposed_area_bottom(i-1)/2).^2)     ;
                end  
            end
            temporary(obj.nodes)=temporary(obj.nodes)+obj.node_exposed_area_bottom(obj.nodes);
            inclined_bottom_area = temporary;
            %calculation of vertical surface nodes
            temporary=zeros(1,obj.nodes);
            for i = 1:obj.nodes
                if ((inclined_bottom_area(i)==0) && (inclined_top_area(i)==0)) %checking if the top facing and down facing inclined for a node is zero and if they are set side facing
                    temporary(i) = obj.node_exposed_area_sides(i);
                end
            end
            non_inclined_area=temporary;
            sum(non_inclined_area)+sum(inclined_bottom_area)+sum(inclined_top_area);
            
            debug_original_areas=([obj.node_exposed_area_sides;obj.node_exposed_area_bottom;obj.node_exposed_area_top]);
            debug_smoothed_areas=([non_inclined_area ; inclined_bottom_area ; inclined_top_area]);
            % END OF INCLINED CALCULATIONS

            
            if (smoothing)
                obj.node_exposed_area_top=inclined_top_area;
                obj.node_exposed_area_bottom=inclined_bottom_area;
                obj.node_exposed_area_sides=non_inclined_area;
            end
        end
      
    end
    
   
    
end


