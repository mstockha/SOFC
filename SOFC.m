function [H2dot,vapordot,heatdot,total_H2,total_vapor,total_heat,pdens,voltagedraw,currentdraw, airdot,total_air] = SOFC(E,T,pH2,dt,min_cells)

%% Estimate Voltage Equation Values

% cell voltage equation (cve) coefficients
temp = [700,750,800];           % temperature [celsius]
res = [0.05, 0.0367, 0.0307];   % resistance  
i0 = [0.2327, 0.38, 0.38];      % exchange current density
ias = [2.3, 2.8397, 3.1323];    % anodic saturation density
ics = [2.3, 2.8292, 3.1311];    % cathodic saturation density

% linear fit equations: cve coefficents to temperature based on data
syms t
coeff_ias = polyfit(temp,ias,1);
iaseq = coeff_ias(1)*t + coeff_ias(2);

coeff_res = polyfit(temp,res,1);
reseq = coeff_res(1)*t + coeff_res(2);

coeff_ics = polyfit(temp,ics,1);
icseq = coeff_ics(1)*t + coeff_ics(2);

coeff_i0 = polyfit(temp,i0,1);
i0eq = coeff_i0(1)*t + coeff_i0(2);

% estimate values for given case based on temperature
res_real = subs(reseq,t,T);
ias_real = subs(iaseq,t,T);
ics_real = subs(icseq,t,T);
i0_real = subs(i0eq,t,T);


%% Single Cell Sizing: Voltage Equation Analysis

V0 = 1.121;             % my sources indicate that this should be 1.06
R = 8.314;
n = 1;                  % why isn't this 2, since there are 2 atoms of hydrogen?
F = 96485;          
pH20 = 1- pH2;
i = 0;
V = 0;
T = T + 273.15;
ntemp = 0;
Vtemp = 10000;
j=1;

while Vtemp > 0 

    i(j) = ntemp;    
    V(j) = V0 - ntemp.*res_real - 2.*R.*T./n./F .* log(1./2 ...
        .* (ntemp./i0_real + sqrt((ntemp./i0_real).^2 +4))) ...
        + R.*T./2./F .* log(1 - ntemp./ias_real)- R.*T./2./F ...
        .* log(1 + pH2.*ntemp./pH20./ias_real) + R.*T./4./F ...
        .* log(1 - ntemp./ics_real);
    Vtemp = V(j);
    ntemp = ntemp + 0.01;
    j = j +1;

end

V(V~=real(V)) = NaN;
power = i.*V;

figure(19)
plot(i,V)
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')

figure(20)
plot(i,power,"LineWidth", 2);
ylim([0 1.2]);
xlabel("Current Density (A/cm^2)",'FontSize',13)
ylabel("Power Density (W/cm^2)",'FontSize',13)

% Use min cells to find pdens req, find current relating to that power
% Then find, h2dot
A = 500;            % cell area in cm^2

pdens = E./min_cells./A;
[~,k] = max(power);
i_cut = i;

for d = 1:length(power)
    if d > k
        power(d) = NaN;
        i_cut(d) = NaN;
    end
end

currentdraw = spline(power,i_cut,pdens);    % per-cell current density
voltagedraw = spline(i,V,currentdraw);      % per-cell voltage draw

% determine total current and power
current = currentdraw .* A ;              % total current (amps)
P_cell = current .* voltagedraw ./1000;   % per-cell power (kJ/s)
P_elec = P_cell .* min_cells;             % total power (kJ/s)

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
RxnEnthalpy_Steam = polyval(slope_steam,T)

% net reaction enthalpy calculation
heatdot = h2mol.*RxnEnthalpy_Steam + P_elec;
total_heat = sum(heatdot.*dt);

end