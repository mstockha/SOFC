function [totalmethane, tankmass_primary, total_heat, total_air, totalCO, totalCO2, wmin, winitial, totalexhauststeam, burnerheat, turbine_LNG, turbine_air, turbine_steam, turbine_CO2, tankmass_turbine, cells] = SOFCdriver(T, E, pH2, dt, A)

%% SOFC Cell Sizing
% Note: outputs two figure (101, 102) to verify the i-V and i-P curves

[cells, i, V, power] = SOFCsize(E, T, pH2, A);


%% SOFC Performance - Cell/Stack power analysis, Reactant flows, Heat

[H2dot,vapordot,heatdot,total_H2,total_vapor,total_heat,pdens,voltagedraw,currentdraw,airdot,total_air] = SOFC(E, T, dt, A, cells, i, V, power);


%% Fuel Reformer Performance - Reactant & heat flows

[LNGflowrate,  H2Oflowrate, unreactedmethaneflowrate, COflowrate, CO2flowrate, H2Ounreactedflowrate, heatflowrate, H2Ocheckfr, H2fr] = FuelReformer(H2dot);

% calculate totals from flow
    % LNG
totalmethane = sum(LNGflowrate.*dt);            % integrate LNG (kg)
totalheatfromreformer = sum(heatflowrate.*dt);  % integrate heat (kJ)
    % CO
totalCO = sum(COflowrate.*dt);                  % integrate CO (kg)
    % CO2
totalCO2 = sum(CO2flowrate.*dt);                % integrate CO2 (kg)


%% steam recycle

[warray,wtank, wmin, winitial, SOFCvapordot, FRneeddot, FRreleasedot, t2, excessH2O, totalexhauststeam, wtankflow] = steamrecyclewatertank(vapordot,H2Oflowrate,H2Ounreactedflowrate, 30, 15);


%% Heat Balance

% enthalpy calculations
efficiency = 0.8; % randomly chosen for now
Ti_air = -50 + 273.15;  % air at 35000 ft is around -50 deg C, to be changed
% assuming air flow rate and final temp for air is given from SOFC

[totalheatflowrate, LNGheatingdot, H2Oheatingdot, airheatingdot, burnerheat] = HeatExchanger(LNGflowrate, heatflowrate, heatdot, wtankflow, efficiency, Ti_air, T, airdot);

total_heat = sum(totalheatflowrate.*dt);


%% LNG Turbine/Burner

[turbine_LNG, turbine_air, turbine_steam, turbine_CO2] = LNGburner(burnerheat);


%% LNG Tank

% mass fraction = mass of fuel/(mass of fuel and mass of tank)
[tankmass_primary, tankmass_turbine] = LNGTank(LNGflowrate, turbine_LNG, dt);


end
