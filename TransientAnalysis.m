%the area is causing the prolem the simulation object has a different area
%we can put the actual area to check it this is the case. (instead of
%generating the area by itself from the rectangle geometry we input the
%surface area)
%clear all   %caused breakpoint problems
clc
%PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set true or false to activate or deactivate heat transfer modes
options.conduction_ver = true; % set true for vertebrae conduction
options.conduction_windshield = false; % set true for windshied conduction
options.dimensions = 2; % if dimensions == 1 the simulation is one dimensional, this means that the thickness of the profile becomes constant in the height direction and is set to the average thickness, additionally the area is overiden by the mannually set area
if (options.dimensions ~= 1 && options.dimensions ~= 2)
    disp('Wrong number set for options.dimensions');
end
custom_area = false; % is set initially false and if the simulation is one dimensional then it is set to true

%temperatures
heat_transfer.T_inf = 0; % [C] ambient temperature
heat_transfer.T_source = 80; % [C] assuming steady temperature 
heat_transfer.Q_source = 13.94 ; % [W] assuming steady heat flux
heat_transfer.T_rubber_init = heat_transfer.T_inf ; % [C] initial temperature of rubber
heat_transfer.T_windshield=4; % [C] temperature of the windshield

th=[0.00552,0.00595,0.00597,0.00561,0.00101,0.001,0.001,0.001,0.00106,0.006,0.006,0.006,0.006,0.006,0.00599,0.00284,0.0028,0.00281,0.00626,0.00614,0.00062,0.00042,0.00086,0.00264,0.00354,0.00354,0.00342,0.00196,0.00172,0.00152,0.00134,0.00118,0.00104,0.00094,0.00084,0.00078,0.00072,0.0007,0.0007,0.0007]; % thicknesses of the consequent nodes, if the simulation is one dimensional the average of the thicknesses is taken
if options.dimensions == 1
    th = ones(1,rubber.nodes)*mean(th);%calculating the average of the thicknesses and creating a table with everywhere this calculated value
    custom_area = true; % overrides the area of the simulation object with a custom area that can approximate better shapes that are not close to the wall model used for the simulation object.
end
%simulation_object(height,length,t,nodes,cp,k_conduction,rho,smoothing)
rubber = simulation_object(0.0112,0.635,th,40,2100,0.35,1100,true); % creates a simulation object with the given attributes. The nodes should stay 40 because currently the convection boundary condition is defined with respect to node number, and will have to be modified if more nodes are applied in order to have the same results. Additionally the number of nodes must be the same as the length of the th table.



if (custom_area)
    profile_area = 0.032-rubber.node_exposed_area_top(1)-rubber.node_exposed_area_bottom(rubber.nodes);%[m^2] first and last node have a bigger exposed area and this is taken into account here. From the area that is distributed to the nodes as "side area" the top surface of the first node and the bottom surface of the last node is substracted. 
    rubber.node_exposed_area_sides = ones(1,rubber.nodes)*profile_area/rubber.nodes; % divides the remain area by the number of nodes and gives the value to the rubber.node_exposed_area_sides.
end

sim_time=1800; % [s] Real time for until the simulation takes place. If the settling time cannot be calculated then increase this value.

h_top=11.67;
h_bottom=11.67;
h_sides=11.67;

%CONVECTION ABOVE VERTEBRAE
heat_transfer.convection1 = convection(h_sides,1,4);%   convection1 = natural convection sides (gives the convection coefficient for heat transfer from the sides)
heat_transfer.convection2 = convection(h_bottom,1,3);%   convection2 = natural convection bottom (gives the convection coefficient for heat transfer from bottom)
heat_transfer.convection3 = convection(h_top,1,4);%   convection3 = natural convection top (goves the convection coefficient for heat transfer from top)

%CONVECTION UNDER VERTEBRAE
heat_transfer.convection4 = convection(h_sides,10,rubber.nodes);%   convection1 = natural convection sides (gives the convection coefficient for heat transfer from the sides)
heat_transfer.convection5 = convection(h_bottom,10,rubber.nodes);%   convection2 = natural convection bottom (gives the convection coefficient for heat transfer from bottom)
heat_transfer.convection6 = convection(h_top,11,rubber.nodes);%   convection3 = natural convection top (goves the convection coefficient for heat transfer from top)

heat_transfer.conduction1 = conduction(0.001,0.0035,false,heat_transfer.Q_source,rubber.nodes,rubber.height); % conduction from vertebrae
%heat_transfer.conduction2 = conduction(0.009,0.01,true,heat_transfer.T_windshield,rubber.nodes,rubber.height); % conduction from windshield


%ODE45
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    
% initialize node temperatures
init=ones(1,rubber.nodes)*heat_transfer.T_rubber_init; 
    
% set temperature fixed boundaries here, the values are inputed as init
% conditions in ode 45 and the dT for these nodes is set to zero, the
% the output for these fixed nodes should be zero from the 
    
%Initialization of nodes with fixed temperatures for vertebrae - only works
%if fixed temperature boundary conditions are active.
if (options.conduction_ver) && (heat_transfer.conduction1.mode)
    for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
        init(1,i) = heat_transfer.T_source;  
    end
end

%Initialization of nodes with fixed temperatures for windshield - only works
%if fixed temperature boundary conditions are active. the "mode" is a
%boolean that defines wether we have constant temperature or constant heat
%boundary condition
if (options.conduction_windshield) && (heat_transfer.conduction2.mode)
    for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
        init(1,i) = heat_transfer.T_windshield;  
    end
end

%ode45
[t,output]=ode45(@(t,P)OneDimEq(t,P,rubber,heat_transfer,options),[0 sim_time],[init]);
    

% PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%script for colors of colorbar
map=RGB_map(128); % the input for this function is the number of colorshades of the colormap

figure(1)% Shows the temperature of all nodes vs time at the same graph.
figure_all_nodes(rubber.nodes, output,t)
hold off
    
figure(2) % shows the average temperature of the matlab simulation and if comparison == true compares it with the average temperature of the ANSYS simulation
if options.dimensions == 1
    this_sim_name='1 dimensional Matlab model';
else
    this_sim_name='2 dimensional Matlab model';
end
ansys_sim_name='2 dimensional Ansys model';
comparison =true;
if comparison
    ANSYS=xlsread('ansys_data');
end
[avg , settling_index]=figure_avg_t(true,ANSYS,output,rubber,t,this_sim_name,ansys_sim_name);
hold off

figure(3) % shows the transient temperature development of all nodes. The temperature is depicted with height and color. 
mesh(output);
xlabel('Node')
ylabel('Time[s]')
zlabel('Temperature[C]')
colormap(map);
colorbar;

figure(4)
figure_shape( rubber,output,map ) % visual representation of rubber profile

clear('map','shades');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%REPORT
disp('REPORT');
disp('----------');
disp('Material properties:');
disp(['Thermal conductivity [k] = ' , num2str(rubber.k_conduction),' [W/m*K]']);
disp(['Density [rho] = ' , num2str(rubber.rho),' [kg/m^3]']);
disp(['Specific heat [cp] = ' , num2str(rubber.cp),' [j/kg*K] ']);
disp('----------');
disp('Geometric properties:');
disp(['Length [L] = ' , num2str(rubber.length),' [m] ']);
disp(['Height [h] = ' , num2str(rubber.height),' [m] ']);
disp(['Width is variable, (different for each node) ']);
disp(['Volume [V] = ' , num2str(rubber.volume),' [m^3] ']);
total_area = sum(rubber.node_exposed_area_sides) + sum(rubber.node_exposed_area_bottom) + sum(rubber.node_exposed_area_top);
disp(['Total exposed area : ', num2str(total_area),' [m^2]']);
disp('----------');
disp('Physical properties:');
disp(['Mass [m] = ' , num2str(rubber.mass),' [kg] ']);
disp('----------');
disp('Mesh properties:');
disp(['Nodes = ' , num2str(rubber.nodes)]);
disp(['Distance between two consequent nodes = ' , num2str(rubber.delta_x),'[m]']);
disp('----------');
disp('Simulation properties:');
disp(['Simulation Time = ' , num2str(sim_time),' [s] ']);
disp(['Convection coefficient for up-facing surfaces = ' , num2str(h_top),' [W/(m2*K] ']);
disp(['Convection coefficient for down-facing surfaces = ' , num2str(h_bottom),' [W/(m2*K] ']);
disp(['Convection coefficient for side-facing surfaces = ' , num2str(h_sides),' [W/(m2*K] ']);
disp(['Ambient temperature = ' , num2str(heat_transfer.T_inf),' [C] ']);
disp('----------');
disp('Results:');
disp(['Maximum temperature at end of simulation = ' , num2str(max(output(length(output),:))),' [W/(m2*K] ']);
disp(['Minimum temperature at end of simulation = ' , num2str(min(output(length(output),:))),' [W/(m2*K] ']);
disp(['Average temperature at end of simulation = ' , num2str(avg(length(avg))),' [C] ']);

        
    
    
if (settling_index==1)
    disp('no steady state could be detected, increase simulation time')
else
    disp(['Steady state reached at ', num2str(t(settling_index)), ' seconds'])
end

clear('i','k');
clear('init','settling_index','this_sim_name','ansys_sim_name')


