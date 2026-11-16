% Title: VoltageEqtnFitting_Chemistry.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 12 November 2026
% 

clc; clear;


%% Plot Data

load("VoltageFittingData_Islam2025.mat");     % load experimental dataset

figure(1)       % experimental voltage curves
yyaxis left
plot(Current_600, Voltage_600)
hold on
plot(Current_650, Voltage_650, Current_700, Voltage_700, Current_750, Voltage_750)
hold off
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
ylim([0,1.2])

yyaxis right        % experimental power curves
plot(i_600, Power_600)
hold on
plot(i_650, Power_650, i_700, Power_700, i_750, Power_750)
hold off
title('Data from Islam, et al., 2025')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600', '650', '700', '750')
xlim([0,8])
ylim([0,4])


%% BUILD MODELS - Iron with YSZ %%
% Parameters = [E0, a, j0, jL]
% voltage equation based on chemistry losses
Veqtn_600_Fe1 = @(params,j) params(1) ...
    + (8.314.*(600+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(600+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(3126*exp(-0.014*(600))) ...
    + (8.314.*(600+273))./(2.*96485.34) .* (1 + 1/params(2)) .* log(1 - j./params(4)));

Veqtn_650_Fe1 = @(params,j) params(1) ...
    + (8.314.*(650+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(650+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(3126*exp(-0.014*(650))) ...
    + (8.314.*(650+273))./(2.*96485.34) .* (1 + 1/params(2)) .* log(1 - j./params(4)));

Veqtn_700_Fe1 = @(params,j) params(1) ...
    + (8.314.*(700+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(700+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(3126*exp(-0.014*(700))) ...
    + (8.314.*(700+273))./(2.*96485.34) .* (1 + 1/params(2)) .* log(1 - j./params(4)));

Veqtn_750_Fe1 = @(params,j) params(1) ...
    + (8.314.*(750+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(750+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(3126*exp(-0.014*(750))) ...
    + (8.314.*(750+273))./(2.*96485.34) .* (1 + 1/params(2)) .* log(1 - j./params(4)));

% initial guess, upper and lower bounds
initials = [1.1 0.5 0.1 4];           % initial guesses
lower_600 = [0.9  0.2 1e-6  max(i_600)+0.001];     % lower bounds 600
lower_650 = [0.9  0.2 1e-6  max(i_650)+0.001];     % lower bounds 650
lower_700 = [0.9  0.2 1e-6  max(i_700)+0.001];     % lower bounds 700
lower_750 = [0.9  0.2 1e-6  max(i_750)+0.001];     % lower bounds 750
upper     = [1.25 1   10 8];                         % upper bounds

[parameters_600, residual_600] = lsqcurvefit(Veqtn_600_Fe1, initials, Current_600, Voltage_600, lower_600, upper);
[parameters_650, residual_650] = lsqcurvefit(Veqtn_650_Fe1, initials, Current_650, Voltage_650, lower_650, upper);
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700_Fe1, initials, Current_700, Voltage_700, lower_700, upper);
[parameters_750, residual_750] = lsqcurvefit(Veqtn_750_Fe1, initials, Current_750, Voltage_750, lower_750, upper);

% Output table
    % column vectors
Temperature = [600; 650; 700; 750];
V0 = [parameters_600(1); parameters_650(1); parameters_700(1); parameters_750(1)];
% V0 = [0.95; 0.95; 0.95; 0.95; 0.95];
a  = [parameters_600(2); parameters_650(2); parameters_700(2); parameters_750(2)];
j0 = [parameters_600(3); parameters_650(3); parameters_700(3); parameters_750(3)];
jL = [parameters_600(4); parameters_650(4); parameters_700(4); parameters_750(4)];
residuals = [residual_600; residual_650; residual_700; residual_750];
    % create table
Outputs = table(Temperature, V0, a, j0, jL, residuals);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares - Fe\n')
disp(Outputs)

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
temps = Temperature + 273;
paramsV0_Fe = polyfit(temps, V0, 3); 
params_a_Fe = polyfit(temps, a, 3); 
paramsj0_Fe = polyfit(temps, j0, 3);   
paramsjL_Fe = polyfit(temps, jL, 3); 

% anonymous function for general temperature (electrolyte = YSZ + Fe, P =
% 1atm)
Veqtn_Fe1 = @(params,j) params(1) ...
    + (8.314.*(params(5)+273))./(2.*96485.34) .* log((1*sqrt(0.21))) ...
    - ((8.314.*(params(5)+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(3126*exp(-0.014*(params(5)))) ...
    + (8.314.*(params(5)+273))./(2.*96485.34) .* (1 + 1/params(2)) .* log(1 - j./params(4)));

% Goodness of Fit
    % set parameters
% params600_Islam = [polyval(paramsV0_Fe, 600+273), polyval(params_a_Fe, 600+273), polyval(paramsj0_Fe, 600+273), polyval(paramsjL_Fe, 600+273), 600];
% params650_Islam = [polyval(paramsV0_Fe, 650+273), polyval(params_a_Fe, 650+273), polyval(paramsj0_Fe, 650+273), polyval(paramsjL_Fe, 650+273), 650];
% params700_Islam = [polyval(paramsV0_Fe, 700+273), polyval(params_a_Fe, 700+273), polyval(paramsj0_Fe, 700+273), polyval(paramsjL_Fe, 700+273), 700];
% params750_Islam = [polyval(paramsV0_Fe, 750+273), polyval(params_a_Fe, 750+273), polyval(paramsj0_Fe, 750+273), polyval(paramsjL_Fe, 750+273), 750];

params600_Islam = [parameters_600, 600];
params650_Islam = [parameters_650, 650];
params700_Islam = [parameters_700, 700];
params750_Islam = [parameters_750, 750];

    % Experimental data collection
Volts600_Islam = Veqtn_Fe1(params600_Islam, Current_600); P600_Islam = Veqtn_Fe1(params600_Islam, i_600) .* i_600;
Volts650_Islam = Veqtn_Fe1(params650_Islam, Current_650); P650_Islam = Veqtn_Fe1(params650_Islam, i_650)  .* i_650;
Volts700_Islam = Veqtn_Fe1(params700_Islam, Current_700); P700_Islam = Veqtn_Fe1(params700_Islam, i_700)  .* i_700;
Volts750_Islam = Veqtn_Fe1(params750_Islam, Current_750); P750_Islam = Veqtn_Fe1(params750_Islam, i_750)  .* i_750;
    % find residuals
ResVolts600_Islam = Volts600_Islam - Voltage_600; ResP600_Islam = P600_Islam - Power_600;
ResVolts650_Islam = Volts650_Islam - Voltage_650; ResP650_Islam = P650_Islam - Power_650;
ResVolts700_Islam = Volts700_Islam - Voltage_700; ResP700_Islam = P700_Islam - Power_700;
ResVolts750_Islam = Volts750_Islam - Voltage_750; ResP750_Islam = P750_Islam - Power_750;

figure(2)
subplot(2,4,1)
plot(Voltage_600, Volts600_Islam, '*', Voltage_600, Voltage_600, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,2)
plot(Voltage_650, Volts650_Islam, '*', Voltage_650, Voltage_650, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,3)
plot(Voltage_700, Volts700_Islam, '*', Voltage_700, Voltage_700, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,4)
plot(Voltage_750, Volts750_Islam, '*', Voltage_750, Voltage_750, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,5)
plot(Power_600, P600_Islam, '*', Power_600, Power_600, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,4,6)
plot(Power_650, P650_Islam, '*', Power_650, Power_650, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,4,7)
plot(Power_700, P700_Islam, '*', Power_700, Power_700, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,4,8)
plot(Power_750, P750_Islam, '*', Power_750, Power_750, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

%% Plot Data

load("VoltageFittingData_Hsieh1atm.mat");     % load experimental dataset

figure(3)       % experimental voltage curves
yyaxis left
plot(Current_750_Hsieh, Voltage_750_Hsieh)
hold on
plot(Current_800_Hsieh, Voltage_800_Hsieh, Current_850_Hsieh, Voltage_850_Hsieh)
hold off
title('Cell Voltage Data')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
ylim([0.7,1.2])

yyaxis right        % experimental power curves
plot(i_750_Hsieh, Power_750_Hsieh)
hold on
plot(i_800_Hsieh, Power_800_Hsieh, i_850_Hsieh, Power_850_Hsieh)
hold off
title('Data from Hsieh, et al., 2015')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('750', '800', '850')
xlim([0,0.7])
ylim([0,0.5])


%% BUILD MODELS - Just YSZ %%
% Parameters = [V0, a, j0, jL]
% voltage equation based on chemistry losses
Veqtn_750_YSZ1 = @(params,j) params(1) ...
    + (8.314.*(750+273))./(2.*96485.34) .* log(((5/9)*sqrt(0.21))) ...
    - ((8.314.*(750+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(48785*exp(-0.017*(750))) ...
    + (8.314.*(750+273))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(4)./(params(4) - j)));

Veqtn_800_YSZ1 = @(params,j) params(1) ...
    + (8.314.*(800+273))./(2.*96485.34) .* log(((5/9)*sqrt(0.21))) ...
    - ((8.314.*(800+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(48785*exp(-0.017*(800))) ...
    + (8.314.*(800+273))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(4)./(params(4) - j)));

Veqtn_850_YSZ1 = @(params,j) params(1) ...
    + (8.314.*(850+273))./(2.*96485.34) .* log(((5/9)*sqrt(0.21))) ...
    - ((8.314.*(850+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(48785*exp(-0.017*(850))) ...
    + (8.314.*(850+273))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(4)./(params(4) - j)));

% initial guess, upper and lower bounds
initials = [1.06 0.5 0.1 4];           % initial guesses
lower_750 = [0.8  0.2 1e-6  max(i_750_Hsieh)+0.001];     % lower bounds 750
lower_800 = [0.8  0.2 1e-6  max(i_800_Hsieh)+0.001];     % lower bounds 750
lower_850 = [0.8  0.2 1e-6  max(i_850_Hsieh)+0.001];     % lower bounds 750
upper     = [1.25 1   10 10];                         % upper bounds

[parameters_750_Hsieh, residual_750_Hsieh] = lsqcurvefit(Veqtn_750_YSZ1, initials, Current_750_Hsieh, Voltage_750_Hsieh, lower_750, upper);
[parameters_800_Hsieh, residual_800_Hsieh] = lsqcurvefit(Veqtn_800_YSZ1, initials, Current_800_Hsieh, Voltage_800_Hsieh, lower_800, upper);
[parameters_850_Hsieh, residual_850_Hsieh] = lsqcurvefit(Veqtn_850_YSZ1, initials, Current_850_Hsieh, Voltage_850_Hsieh, lower_850, upper);

% Output table
    % column vectors
Temperature = [750; 800; 850];
V0 = [parameters_750_Hsieh(1); parameters_800_Hsieh(1); parameters_850_Hsieh(1)];
% V0 = [0.95; 0.95; 0.95; 0.95; 0.95];
a  = [parameters_750_Hsieh(2); parameters_800_Hsieh(2); parameters_850_Hsieh(2)];
j0 = [parameters_750_Hsieh(3); parameters_800_Hsieh(3); parameters_850_Hsieh(3)];
jL = [parameters_750_Hsieh(4); parameters_800_Hsieh(4); parameters_850_Hsieh(4)];
residuals = [residual_750_Hsieh; residual_800_Hsieh; residual_850_Hsieh];
    % create table
Outputs = table(Temperature, V0, a, j0, jL, residuals);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares - YSZ\n')
disp(Outputs)

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
temps = Temperature + 273;
paramsV0_YSZ = polyfit(temps, V0, 2); 
params_a_YSZ = polyfit(temps, a, 2); 
paramsj0_YSZ = polyfit(temps, j0, 2);   
paramsjL_YSZ = polyfit(temps, jL, 2); 


% anonymous function for general temperature (ele_Islamctrolyte = YSZ + YSZ, P =
% 1atm)
Veqtn_YSZ1 = @(params,j) params(1) ...
    + (8.314.*(params(5)+273))./(2.*96485.34) .* log(((5/9)*sqrt(0.21))) ...
    - ((8.314.*(params(5)+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.*(48785*exp(-0.017*(params(5)))) ...
    + (8.314.*(params(5)+273))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(4)./(params(4) - j)));

% Goodness of Fit
    % set parameters
params750_Hsieh = [parameters_750_Hsieh, 750];
params800_Hsieh = [parameters_800_Hsieh, 800];
params850_Hsieh = [parameters_850_Hsieh, 850];
    % Experimental data collection
Volts750_Hsieh = Veqtn_YSZ1(params750_Hsieh, Current_750_Hsieh); P750_Hsieh = Veqtn_YSZ1(params750_Hsieh, i_750_Hsieh)  .* i_750_Hsieh;
Volts800_Hsieh = Veqtn_YSZ1(params800_Hsieh, Current_800_Hsieh); P800_Hsieh = Veqtn_YSZ1(params800_Hsieh, i_800_Hsieh)  .* i_800_Hsieh;
Volts850_Hsieh = Veqtn_YSZ1(params850_Hsieh, Current_850_Hsieh); P850_Hsieh = Veqtn_YSZ1(params850_Hsieh, i_850_Hsieh)  .* i_850_Hsieh;
    % find residuals
ResVolts750_Hsieh = Volts750_Hsieh - Voltage_750_Hsieh; ResP750_Hsieh = P750_Hsieh - Power_750_Hsieh;
ResVolts800_Hsieh = Volts800_Hsieh - Voltage_800_Hsieh; ResP800_Hsieh = P800_Hsieh - Power_800_Hsieh;
ResVolts850_Hsieh = Volts850_Hsieh - Voltage_850_Hsieh; ResP850_Hsieh = P850_Hsieh - Power_850_Hsieh;

figure(4)
subplot(2,3,1)
plot(Voltage_750_Hsieh, Volts750_Hsieh, '*', Voltage_750_Hsieh, Voltage_750_Hsieh, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,3,2)
plot(Voltage_800_Hsieh, Volts800_Hsieh, '*', Voltage_800_Hsieh, Voltage_800_Hsieh, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,3,3)
plot(Voltage_850_Hsieh, Volts850_Hsieh, '*', Voltage_850_Hsieh, Voltage_850_Hsieh, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,3,4)
plot(Power_750_Hsieh, P750_Hsieh, '*', Power_750_Hsieh, Power_750_Hsieh, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,3,5)
plot(Power_800_Hsieh, P800_Hsieh, '*', Power_800_Hsieh, Power_800_Hsieh, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,3,6)
plot(Power_850_Hsieh, P850_Hsieh, '*', Power_850_Hsieh, Power_850_Hsieh, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

