function [totalmethane, tankmass, total_heat, wmin, winitial, totalexhauststeam, burnerheat, time, cells] = SOFCdriver(T, pH2, dt, PowerSplit)

    load("FC_power_required.mat");
    E = thrust_power_required(2,:).*1000;
    for j = 1:8640
        if E(j)<0
            E(j)=0;
        end
    end
    
    % splitting power load
    E = PowerSplit.*E;
    
    load("mission_t_v_h.mat");
    M = mission_t_v_h(3,:);
    V = mission_t_v_h(2,:);
   
    cells = SOFCsize(E,T,pH2);
    [H2dot,vapordot,heatdot,total_H2,total_vapor,total_heat,pdens,voltagedraw,currentdraw,airdot,total_air] = SOFC(E,T,pH2,dt,cells);


    time_scale = 0:(length(E)-1);
    time = time_scale.*dt;

    [LNGflowrate,  H2Oflowrate, unreactedmethaneflowrate, COflowrate, CO2flowrate, H2Ounreactedflowrate, heatflowrate, H2Ocheckfr, H2fr] = FuelReformer(H2dot);
    
    % display totals
    totalmethane = sum(LNGflowrate.*dt); % each flow rate is at a time of one second so the sum 
    % of the flow rate is the total mass
    totalheatfromreformer = sum(heatflowrate.*dt);

    
    %% LNG Tank
    % mass fraction = mass of fuel/(mass of fuel and mass of tank)
    [tankmass] = LNGTank(LNGflowrate, dt);

     %% steam recycle
    
    [warray,wtank, wmin, winitial, SOFCvapordot, FRneeddot, FRreleasedot, t2, excessH2O, totalexhauststeam, wtankflow] = steamrecyclewatertank(vapordot,H2Oflowrate,H2Ounreactedflowrate, 30, 15);

    
    %% Heat Balance
    % enthalpy calculations
    efficiency = 0.8; % randomly chosen for now
    Ti_air = -50 + 273.15;  % air at 35000 ft is around -50 deg C, to be changed
    % assuming air flow rate and final temp for air is given from SOFC
    
    [totalheatflowrate, LNGheatingdot, H2Oheatingdot, airheatingdot, burnerheat] = HeatExchanger(LNGflowrate, heatflowrate, heatdot, wtankflow, efficiency, Ti_air, T, airdot);
    total_heat = sum(totalheatflowrate.*dt);
  

end
