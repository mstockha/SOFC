% Title: EnthalpyInterpolation.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 28 August 2026
% 
% % % Description: % % % 
% This function interpolates/extrapolates the enthalpy of formation of gaseous water
% (ie, steam) based on an input temperature and the total

function SteamEnthalpy = EnthalpyInterpolation(Temperature)
% Inputs: temperature (Celsius)
% Outputs: interpolated enthalpy of reaction of steam (kJ/mol)


%% Interpolating Data from:
% “Appendix B: Thermodynamic Data.” In Fuel Cell Fundamentals. 
%       John Wiley & Sons, Ltd, 2016.
%       https://doi.org/10.1002/9781119191766.app2.

Temps = 600:20:1000;        % temperature data (K)
    % enthalpies in kJ/mol:
Enthalpies_Steam = [-231.33 -230.6 -229.87 -229.13 -228.39 -227.64 ...
    -226.89 -226.13 -225.37 -224.60 -223.83 -223.05 -222.27 -221.48 ...
    -220.69 -219.89 -219.09 -218.28 -217.47 -216.65 -215.83];

%% Data fit

% fit curve 
slope_steam = polyfit(Temps, Enthalpies_Steam, 1);

% determine reaction enthalpies (kJ/mol)
SteamEnthalpy = polyval(slope_steam,T);

end