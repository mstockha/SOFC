function [duct_burn_LNG, duct_air, duct_steam, duct_CO2] = DuctBurner(burnerheat)

%% Data-driven constants
ductEff = 0.4;         % cycle efficiency
LHV_LNG = 48600;        % lower heating value (kJ/kg)
AFR_LNG = 17.19;        % air to fuel ratio

%% Calculate reactants flow
% calculate LNG flow from burner heat
duct_burn_LNG = abs(burnerheat) ./ (ductEff.*LHV_LNG);

% calculate reactant and product mass flow rates
duct_air = AFR_LNG .* duct_burn_LNG;
duct_steam = 2.25 .* duct_burn_LNG;
duct_CO2 = 2.74 .* duct_burn_LNG; 

end