function [tankmass_primary, tankmass_turbine] = LNGTank(LNGfr, turbine_LNG, dt)

%% mass fraction = mass of fuel/(mass of fuel and mass of tank)

tankmassratio = 0.935;

%% Determine primary tank mass

% total methane flow to fuel reformer (primary tank)
totalmethane_primary = sum(LNGfr.*dt);

% mass of tank
massfuelandtank_primary = 1.1 * totalmethane_primary/tankmassratio;
tankmass_primary = massfuelandtank_primary - totalmethane_primary;

%% Determine turbine tank mass

% total methane for turbine tank
totalmethane_turbine = sum(turbine_LNG);

% mass of tank
massfuelandtank_turbine = 1.1 * totalmethane_turbine/tankmassratio;
tankmass_turbine = massfuelandtank_turbine - totalmethane_turbine;

end