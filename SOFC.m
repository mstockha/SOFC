function [H2dot,vapordot,heatdot,total_H2,total_vapor,total_heat,pdens,voltagedraw,currentdraw, airdot,total_air] = SOFC(E,T,dt,A,min_cells,i,V,power)

%% Constants
F = 96485;              % Faraday's constant (C/mol)
n = 1;                  % number of charges/electrons transferred
T = T + 273.15;         % convert ops temperature to K

%% Power analysis - Cell and Stack

% truncate power and current at value for maximum power
pdens = E./min_cells./A;        % convert data to per-cell power density
[~,k] = max(power);             % find index for maximum calculated power
i_cut = i;                      % temporary current vector

for d = 1:length(power)
    if d > k                % set values after max power index to nan
        power(d) = NaN;
        i_cut(d) = NaN;
    end
end

% interpolate current and voltage draw based on calculated relations and
% experimental power requirements
currentdraw = spline(power,i_cut,pdens);    % current density (A/cm2)
voltagedraw = spline(i,V,currentdraw);      % per-cell voltage draw (V)

% determine total current and power
current = currentdraw .* A ;              % total current (amps)
P_cell = current .* voltagedraw ./1000;   % per-cell power (kJ/s)
P_elec = P_cell .* min_cells;             % total power (kJ/s)


%% Determine reactant flows

% use Nernst relation to find molar hydrogen flow
h2mol = min_cells .* current ./ (2*F); % kg/s

% find molar flow for reactants and products (mol/s) from rxn equation
h20mol = h2mol;         % moles of steam
O2mol = h2mol./2;       % moles of oxygen 

% convert to mass flow rates (kg/s)
H2dot = 0.002016 .* h2mol;          % hydrogen flow
vapordot = h20mol .* 0.01802;       % steam flow
airdot = O2mol .* 0.02896;          % oxygen flow

% determine total flow (kg)
total_H2 = sum(H2dot.*dt);          % total hydrogen
total_vapor = sum(vapordot.*dt);    % total steam
total_air = sum(airdot.*dt);        % total air 


%% Heat Calculation 

% determine temperature dependent enthalpy of reaction based on data from 
% “Appendix B: Thermodynamic Data.” In Fuel Cell Fundamentals. 
%       John Wiley & Sons, Ltd, 2016.
%       https://doi.org/10.1002/9781119191766.app2.
Temps = 600:20:1000;        % temperature data (K)
    % enthalpies in kJ/mol
Enthalpies_Steam = [-231.33 -230.6 -229.87 -229.13 -228.39 -227.64 ...
    -226.89 -226.13 -225.37 -224.60 -223.83 -223.05 -222.27 -221.48 ...
    -220.69 -219.89 -219.09 -218.28 -217.47 -216.65 -215.83];
% fit curve 
slope_steam = polyfit(Temps, Enthalpies_Steam, 1);
% determine reaction enthalpies (kJ/mol)
RxnEnthalpy_Steam = polyval(slope_steam,T);

% net reaction enthalpy calculation
heatdot = h2mol.*RxnEnthalpy_Steam + P_elec;  % heat flow rate (kJ/s)
total_heat = sum(heatdot.*dt);      % integrate for total heat (kJ)

end