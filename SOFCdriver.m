function [Turbine_Model, SOFC_Model, FuelReformation, SteamRecycling, HeatFlow, DuctBurnHeater, TankMass, SystemReactants] = SOFCdriver(T, E, P, pH2, dt, A)

%% Turbine Flows

[turbine_LNG, turbine_air, turbine_steam, turbine_CO2, turbine_heat] = Turbine(P);

% inflow values
Turbine_Model.Inflow.LNG = turbine_LNG;
Turbine_Model.Inflow.Air = turbine_air;
% outflow values
Turbine_Model.Outflow.Steam = turbine_steam;
Turbine_Model.Outflow.CarbonDiox = turbine_CO2;
Turbine_Model.Outflow.Heat = turbine_heat;


%% SOFC Cell Sizing

% Note: outputs two figure (101, 102) to verify the i-V and i-P curves
[cells, i, V, power] = SOFCsize(E, T, pH2, A);

% Struct for specifications: geometry and theoretical cell performance
SOFC_Model.Specs.Area = A;
SOFC_Model.Specs.CellNum = cells;
SOFC_Model.Specs.i = i;
SOFC_Model.Specs.Vcell = V;
SOFC_Model.Specs.Power = power;


%% SOFC Performance - Cell/Stack power analysis, Reactant flows, Heat

[H2dot,vapordot,heatdot,total_H2,total_vapor,total_heat_rejected,pdens,voltagedraw,currentdraw,airdot,total_air] = SOFC(E, T, dt, A, cells, i, V, power);

% add performance to SOFC struct
SOFC_Model.Performance.Current = currentdraw;
SOFC_Model.Performance.CellVoltage = voltagedraw;
SOFC_Model.Performance.CellPowerDensity = pdens;
SOFC_Model.Performance.H2Inflow = H2dot;
SOFC_Model.Performance.AirInflow = airdot;
SOFC_Model.Performance.HeatFlow = heatdot;
SOFC_Model.Performance.SteamRequired = vapordot;
% add reactant totals to SOFC struct
SOFC_Model.Reactants.TotalInflow_H2 = total_H2;
SOFC_Model.Reactants.TotalInflow_Air = total_air;
SOFC_Model.Reactants.TotalSteam = total_vapor;
SOFC_Model.Reactants.TotalHeat = total_heat_rejected;


%% Fuel Reformer Performance - Reactant & heat flows

[LNGflowrate,  H2Oflowrate, unreactedmethaneflowrate, COflowrate, CO2flowrate, H2Ounreactedflowrate, heatflowrate, H2Ocheckfr, H2fr] = FuelReformer(H2dot);

% calculate totals from flow
    % LNG
totalmethane = sum(LNGflowrate.*dt);            % integrate LNG (kg)
totalheatFR= sum(heatflowrate.*dt);             % integrate heat (kJ)
    % CO
totalCO = sum(COflowrate.*dt);                  % integrate CO (kg)
    % CO2
totalCO2 = sum(CO2flowrate.*dt);                % integrate CO2 (kg)

% assign inflow/outflow values to struct for fuel reformer
FuelReformation.Inflow.LNG_FlowRate = LNGflowrate;
FuelReformation.Inflow.H2O_FlowRate = H2Oflowrate;
FuelReformation.Inflow.HeatRequired = heatflowrate;
FuelReformation.Outflow.CarbonDiox_FlowRate = CO2flowrate;
FuelReformation.Outflow.CarbonMonox_FlowRate = COflowrate;
FuelReformation.Outflow.Unreacted_H2O_FlowRate = H2Ounreactedflowrate;
FuelReformation.Outflow.Unreacted_LNG_FlowRate = unreactedmethaneflowrate;
% assign reactant totals to struct for fuel reformer
FuelReformation.ReactantTotals.LNG = totalmethane;
FuelReformation.ReactantTotals.CarbonDiox = totalCO2;
FuelReformation.ReactantTotals.CarbonMonox = totalCO;
FuelReformation.ReactantTotals.HeatRequired = totalheatFR;
% assign verification values to struct (confirm stoichiometric balance)
FuelReformation.Verification.H2Inflow = H2fr;
FuelReformation.Verification.SteamInflow = H2Ocheckfr;


%% steam recycle

[warray,wtank, winitial, SOFCvapordot, FRneeddot, FRreleasedot, excessH2O, totalexhauststeam, wtankflow] = steamrecyclewatertank(vapordot, H2Oflowrate, H2Ounreactedflowrate, 30, 15);

% add struct for steam recycling flow performance
SteamRecycling.Performance.TankLevel = wtank;
SteamRecycling.Performance.WaterBalance = warray;
SteamRecycling.Performance.WaterCarriage = winitial;
SteamRecycling.Performance.ExhaustFlow = excessH2O;
SteamRecycling.Performance.TotalExhaust = totalexhauststeam;
% add station flows to steam recycling struct
SteamRecycling.Stations.SOFC_Outflow = SOFCvapordot;
SteamRecycling.Stations.FR_InflowRequired = FRneeddot;
SteamRecycling.Stations.FR_Outflow = FRreleasedot;


%% Heat Balance

% enthalpy calculations
efficiency = 0.8; % randomly chosen for now
Ti_air = -50 + 273.15;  % air at 35000 ft is around -50 deg C, to be changed
% Note: assuming air flow rate and final temp for air is given from SOFC

[totalheatflowrate, LNGheatingdot, H2Oheatingdot, airheatingdot, burnerheat] = HeatExchanger(turbine_heat, LNGflowrate, heatflowrate, heatdot, wtankflow, efficiency, Ti_air, T, airdot);

total_heat_rejected = sum(totalheatflowrate.*dt);

% build output struct for heat balance
HeatFlow.LNG = LNGheatingdot;
HeatFlow.Steam = H2Oheatingdot;
HeatFlow.Air = airheatingdot;
HeatFlow.Burner = burnerheat;
HeatFlow.TotalFlow = totalheatflowrate;
HeatFlow.NetHeat_Rejected = total_heat_rejected;


%% Duct LNG Burner

[duct_burn_LNG, duct_air, duct_steam, duct_CO2] = DuctBurner(burnerheat);

% duct burn data struct
DuctBurnHeater.InflowLNG = duct_burn_LNG;
DuctBurnHeater.InflowAir = duct_air;
DuctBurnHeater.OutflowSteam = duct_steam;
DuctBurnHeater.OutflowCarbonDiox = duct_CO2;


%% LNG Tank

% mass fraction = mass of fuel/(mass of fuel and mass of tank)
[tankmass_primary, tankmass_turbine, tankmass_burner] = LNGTank(LNGflowrate, turbine_LNG, duct_burn_LNG, dt);

% build struct for LNG tanks
TankMass.Primary_SOFC = tankmass_primary;
TankMass.Turbine = tankmass_turbine;
TankMass.DuctBurner = tankmass_burner;


%% System Reactant Totals
% LNG (fuel reformer, turbine, duct)
SystemReactants.LNG = FuelReformation.ReactantTotals.LNG ...
    + sum(Turbine_Model.Inflow.LNG .* dt) ...
    + sum(DuctBurnHeater.InflowLNG .* dt);

% Water (tank)
SystemReactants.H2O = SteamRecycling.Performance.WaterCarriage;

% H2 (fuel reformer/SOFC)
SystemReactants.H2 = SOFC_Model.Reactants.TotalInflow_H2;

% Steam (SOFC, turbine, duct)
SystemReactants.Steam = sum(Turbine_Model.Outflow.Steam .* dt) ...
    + SOFC_Model.Reactants.TotalSteam ...
    + sum(DuctBurnHeater.OutflowSteam .* dt);

% Air (SOFC, turbine, duct)
SystemReactants.AirFlow = Turbine_Model.Inflow.Air ...
    + SOFC_Model.Performance.AirInflow + DuctBurnHeater.InflowAir;
SystemReactants.AirTotal = sum(Turbine_Model.Inflow.Air .* dt) ...
    + SOFC_Model.Reactants.TotalInflow_Air ...
    + sum(DuctBurnHeater.InflowAir .* dt);

    % determine SOFC bypass ratio for air
SOFC_Model.Performance.BypassRatio = (Turbine_Model.Inflow.Air ...
    + DuctBurnHeater.InflowAir) ./ SystemReactants.AirFlow;

% Carbon Dioxide (turbine, fuel reformer, duct)
SystemReactants.CarbonDiox = sum(Turbine_Model.Outflow.CarbonDiox.*dt) ...
    + FuelReformation.ReactantTotals.CarbonDiox ...
    + sum(DuctBurnHeater.OutflowCarbonDiox .* dt);

% Carbon Monoxide (fuel reformer)
SystemReactants.CarbonMonox = FuelReformation.ReactantTotals.CarbonMonox;

end
