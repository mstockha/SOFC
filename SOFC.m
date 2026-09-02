function [H2dot,vapordot,heatdot,total_H2,total_vapor,total_heat,pdens,voltagedraw,currentdraw, airdot,total_air] = SOFC(E,T,dt,A,min_cells,i,V,power)

%% Constants
F = 96485;              % Faraday's constant (C/mol)
n = 2;                  % number of charges/electrons transferred
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

for count = 1:length(currentdraw)
    if currentdraw(count) < 0
        currentdraw(count) = 0;
    end
end

voltagedraw = spline(i,V,currentdraw);      % per-cell voltage draw (V)


% determine total current and power
current = currentdraw .* A ;              % total current (amps)
P_cell = current .* voltagedraw ./1000;   % per-cell power (kJ/s)
P_elec = P_cell .* min_cells;             % total power (kJ/s)


%% Determine reactant flows

% use Nernst relation to find molar hydrogen flow
h2mol = min_cells .* current ./ (n*F); % kg/s

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

% determine reaction enthalpies (kJ/mol)
RxnEnthalpy_Steam = EnthalpyInterpolation(T);

% net reaction enthalpy calculation
heatdot = h2mol.*RxnEnthalpy_Steam + P_elec;  % heat flow rate (kJ/s)
total_heat = sum(heatdot.*dt);      % integrate for total heat (kJ)

end