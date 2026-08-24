function [turbine_LNG, turbine_air, turbine_steam, turbine_CO2] = LNGburner(burnerheat)

%% Data-driven constants
cycleEff = 0.4;         % cycle efficiency
LHV_LNG = 48600;        % lower heating value (kJ/kg)
AFR_LNG = 17.19;        % air to fuel ratio

%% Calculate reactants flow
% calculate LNG flow from burner heat
turbine_LNG = abs(burnerheat) ./ (cycleEff.*LHV_LNG);

% calculate reactant and product mass flow rates
turbine_air = 1.1 .* AFR_LNG .* turbine_LNG;
turbine_steam = 2.25 .* turbine_LNG;
turbine_CO2 = 2.74 .* turbine_LNG; 

end