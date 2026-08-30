function [turbine_LNG, turbine_air, turbine_steam, turbine_CO2, turbine_heat] = Turbine(P)

%% Data-driven constants
cycleEff = 0.4;         % cycle efficiency
captureEff = 0.85;      % thermal efficiency (heat extraction from core)
LHV_LNG = 48600;        % lower heating value (kJ/kg)
AFR_LNG = 17.19;        % air to fuel ratio

%% Calculate reactants flow
% calculate LNG flow from power output (net power)
turbine_LNG = P./ 1000 ./ (cycleEff.*LHV_LNG);

% calculate reactant and product mass flow rates
turbine_air = AFR_LNG .* turbine_LNG;
turbine_steam = 2.25 .* turbine_LNG;
turbine_CO2 = 2.74 .* turbine_LNG; 

% calculate heat output
turbine_heat = -1 .* captureEff .* P .* (1 - cycleEff) ./ cycleEff ./ 1000;

end