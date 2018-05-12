function T_dot = OneDimEq(t,P,rubber,heat_transfer,options)
%ONEDIMEQ function for one dimensional analysis
%   All the heat transfers Q between the nodes and from the enviroment to
%   the nodes are calculated. First the differential heat transfer via
%   conduction in the material is calculated. Then the differential heat
%   transfer for convection conduction etc. The outside heat transfers
%   should be applied to the correct nodes. The rubber is modeled as a one
%   dimensional wall.

% dT/dt=(1/a)* d^2T/dX^2 Fourrier
% for each node: T_dot= ( T_i-1 + T_i+1 - 2*T_i ) * a/(delta_x^2)
% a=alpha=diffusivity 
% T_dot = dT/dt
% Q_dot = dQ/dt
% Q=m*cp*?T <=> Q_dot = m*cp*??_dot

%INITIALIZATION OF OUTPUT TABLE BY DEFINING A ZERO TABLE
T_dot=zeros(rubber.nodes,1); 

%INTERNAL CONDUCTION 
%dT/dt = (T_m-1 - 2*T_m + T_m+1)*a/(delta_x)^2 , where a=k/(rho*cp)
%equation 5-43 , page 334 , Cengel - Heat Transfer
T_dot(1,1)=((P(2)-P(1))*rubber.alpha)*(rubber.A(1)/rubber.th(1))/(rubber.delta_x^2); %first node
    for i = 2 : rubber.nodes-1
        T_dot(i,1)=( ((P(i+1)-P(i))*(rubber.A(i)/rubber.th(i))+(P(i-1)-P(i))*(rubber.A(i-1)/rubber.th(i)) )*rubber.alpha)/(rubber.delta_x^2); % derived from Fourrier eq. the differential for each node is proportional to the difeerence of temperature with it's neighbouring nodes times difussivity divided by delta_x
    end
T_dot(rubber.nodes,1)=((P(rubber.nodes-1)-P(rubber.nodes))*(rubber.A(rubber.nodes-1)/rubber.th(rubber.nodes))*rubber.alpha)/(rubber.delta_x^2); %last node

%%%% ABOVE VERTEBRAE
%CONVECTION FOR EACH NODE FROM SIDES ABOVE VERTEBRAE
conv_tabl=zeros(rubber.nodes,1);
for i = heat_transfer.convection1.node_start : heat_transfer.convection1.node_end
    q_dot_node=heat_transfer.convection1.h*(rubber.node_exposed_area_sides(i))*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
    conv_tabl(i,1)= q_dot_node/(rubber.cp*rubber.node_mass(i)); %q_dot_node = m_node*cp*deltaT
end
T_dot=T_dot+conv_tabl;

%CONVECTION FOR EACH NODE FROM BOTTOM ABOVE VERTEBRAE
conv_tabl=zeros(rubber.nodes,1);
for i = heat_transfer.convection2.node_start : heat_transfer.convection2.node_end
    q_dot_node=heat_transfer.convection2.h*(rubber.node_exposed_area_bottom(i))*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
    conv_tabl(i,1)= q_dot_node/(rubber.cp*rubber.node_mass(i)); %q_dot_node = m_node*cp*deltaT
end
T_dot=T_dot+conv_tabl;

%CONVECTION FOR EACH NODE FROM TOP ABOVE VERTEBRAE
conv_tabl=zeros(rubber.nodes,1);
for i = heat_transfer.convection3.node_start : heat_transfer.convection3.node_end
    q_dot_node=heat_transfer.convection3.h*(rubber.node_exposed_area_top(i))*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
    conv_tabl(i,1)= q_dot_node/(rubber.cp*rubber.node_mass(i)); %q_dot_node = m_node*cp*deltaT
end
T_dot=T_dot+conv_tabl;


%%%% UNDER VERTEBRAE
%CONVECTION FOR EACH NODE FROM SIDES UNDER VERTEBRAE
conv_tabl=zeros(rubber.nodes,1);
for i = heat_transfer.convection4.node_start : heat_transfer.convection4.node_end
    q_dot_node=heat_transfer.convection4.h*(rubber.node_exposed_area_sides(i))*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
    conv_tabl(i,1)= q_dot_node/(rubber.cp*rubber.node_mass(i)); %q_dot_node = m_node*cp*deltaT
end
T_dot=T_dot+conv_tabl;

%CONVECTION FOR EACH NODE FROM BOTTOM UNDER VERTEBRAE
conv_tabl=zeros(rubber.nodes,1);
for i = heat_transfer.convection5.node_start : heat_transfer.convection5.node_end
    q_dot_node=heat_transfer.convection5.h*(rubber.node_exposed_area_bottom(i))*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
    conv_tabl(i,1)= q_dot_node/(rubber.cp*rubber.node_mass(i)); %q_dot_node = m_node*cp*deltaT
end
T_dot=T_dot+conv_tabl;

%CONVECTION FOR EACH NODE FROM TOP UNDER VERTEBRAE
conv_tabl=zeros(rubber.nodes,1);
for i = heat_transfer.convection6.node_start : heat_transfer.convection6.node_end
    q_dot_node=heat_transfer.convection6.h*(rubber.node_exposed_area_top(i))*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
    conv_tabl(i,1)= q_dot_node/(rubber.cp*rubber.node_mass(i)); %q_dot_node = m_node*cp*deltaT
end
T_dot=T_dot+conv_tabl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CONDUCTION VERTEBRAE
if (options.conduction_ver) 
    if (heat_transfer.conduction1.mode) %fixing temperatures for vertebrae if we have constant temperature boundary
%conduction
        for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
           T_dot(i,1)=0;
        end
    else % script for constant heat input
        cond_tabl=zeros(rubber.nodes,1); % initializion of table with differential temperatures due to constant Q
        for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
           q_dot_node = heat_transfer.conduction1.Q/heat_transfer.conduction1.nodes;
           cond_tabl(i,1)= q_dot_node/(rubber.node_mass(i)*rubber.cp); % q_dot = m*cp*deltaT
        end
        T_dot=T_dot+cond_tabl;
    end
end
    
if (options.conduction_windshield) 
    if (heat_transfer.conduction2.mode) %fixing temperatures for vertebrae if we have constant temperature boundary
%condition
        for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
           T_dot(i,1)=0;
        end
    else % constant Q
        cond_tabl=zeros(rubber.nodes,1); % initializion of table with differential temperatures due to constant Q
        for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
           q_dot_node = heat_transfer.conduction2.Q/heat_transfer.conduction2.nodes; 
           cond_tabl(i,1)= q_dot_node/((rubber.node_mass(i))*rubber.cp);
        end
        T_dot=T_dot+cond_tabl(i,1);
    end
end



end

