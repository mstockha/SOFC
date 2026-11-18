% Title: VoltageEqtnFitting_Chemistry3.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 12 November 2026
% 

clc; clear;
eps = 1e-15;
jLeak = 0.01;

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
% Parameters = [1-E0, 2-a, 3-S0, 4-j0, 5-c, 6-jL, 7-T]
% voltage equation based on chemistry losses
Veqtn_600_Fe1 = @(params,j) params(1) ...
    + (8.314.*873)./(2.*96485.34) .* log((0.97*sqrt(0.21))) ...
    - (8.314.*873)./(params(2).*2.*96485.34) .* log((j + jLeak)./params(4)) ...
    - j.* (0.000275 + 0.031 + 0.00175) ./ params(3) ...
    - params(5).*log(1 - (j+jLeak)./params(6));
    % + params(5) .* log(params(6) ./ (params(6) - (j + jLeak))));
    % j + jLeak

Veqtn_650_Fe1 = @(params,j) params(1) ...
    + (8.314.*923)./(2.*96485.34) .* log((0.97*sqrt(0.21))) ...
    - (8.314.*923)./(params(2).*2.*96485.34) .* log((j + jLeak)./params(4)) ...
    - j.* (0.000275 + 0.031 + 0.00175) ./ params(3) ...
    - params(5).*log(1 - (j+jLeak)./params(6));

Veqtn_700_Fe1 = @(params,j) params(1) ...
    + (8.314.*973)./(2.*96485.34) .* log((0.97*sqrt(0.21))) ...
    - (8.314.*973)./(params(2).*2.*96485.34) .* log((j + jLeak)./params(4)) ...
    - j.* (0.000275 + 0.031 + 0.00175) ./ params(3) ...
    - params(5).*log(1 - (j+jLeak)./params(6));

Veqtn_750_Fe1 = @(params,j) params(1) ...
    + (8.314.*1023)./(2.*96485.34) .* log((0.97*sqrt(0.21))) ...
    - (8.314.*1023)./(params(2).*2.*96485.34) .* log((j + jLeak)./params(4)) ...
    - j.* (0.000275 + 0.031 + 0.00175) ./ params(3) ...
    - params(5).*log(1 - (j+jLeak)./params(6));

% initial guess, upper and lower bounds
% Params =  [1-E0, 2-a, 3-S0,  4-j0,  5-c,  6-jL]
initials =  [1.1   0.4  0.05    0.1   0.1     4];           % initial guesses
lower_600 = [0.9   0.1  0.0001  1e-6  0.01  max(i_600)+jLeak]; % lower bounds 600
lower_650 = [0.9   0.1  0.0001  1e-6  0.01  max(i_650)+jLeak]; % lower bounds 650
lower_700 = [0.9   0.1  0.0001  1e-6  0.01  max(i_700)+jLeak]; % lower bounds 700
lower_750 = [0.9   0.1  0.0001  1e-6  0.01  max(i_750)+jLeak]; % lower bounds 750
upper     = [1.25  1    0.2     10    0.5     8];                   % upper bounds

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
S0 = [parameters_600(3); parameters_650(3); parameters_700(3); parameters_750(3)];
j0 = [parameters_600(4); parameters_650(4); parameters_700(4); parameters_750(4)];
c  = [parameters_600(5); parameters_650(5); parameters_700(5); parameters_750(5)];
jL = [parameters_600(6); parameters_650(6); parameters_700(6); parameters_750(6)];
residuals = [residual_600; residual_650; residual_700; residual_750];
    % create table
Outputs = table(Temperature, V0, a, S0, j0, jL, c, residuals);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares - Fe\n')
disp(Outputs)

%% fit for best fit parameters: cve coefficents fit as Var = f(T)
temps = Temperature + 273;
paramsV0_Fe = polyfit(temps, V0, 3); 
params_a_Fe = polyfit(temps, a, 3);
paramsS0_Fe = polyfit(temps, S0, 3);   
paramsj0_Fe = polyfit(temps, j0, 3);   
paramsjL_Fe = polyfit(temps, jL, 3); 

% anonymous function for general temperature (electrolyte = YSZ + Fe, P =
% 1atm)
% Parameters = [1-E0, 2-a, 3-S0, 4-j0, 5-c, 6-jL, 7-T]
% voltage equation based on chemistry losses
Veqtn_Fe1 = @(params,j) params(1) ...
    + (8.314.*params(7))./(2.*96485.34) .* log((0.97*sqrt(0.21))) ...
    - (8.314.*params(7))./(params(2).*2.*96485.34) .* log((j + jLeak)./params(4)) ...
    - j.* (0.000275 + 0.031 + 0.00175) ./ params(3) ...
    - params(5).*log(1 - (j+jLeak)./params(6));

% % Goodness of Fit
%     % set parameters
% params600_Islam = [polyval(paramsV0_Fe, 600+273), polyval(params_a_Fe, 600+273), polyval(paramsS0_Fe, 600+273), polyval(paramsj0_Fe, 600+273), polyval(paramsjL_Fe, 600+273), 873];
% params650_Islam = [polyval(paramsV0_Fe, 650+273), polyval(params_a_Fe, 650+273), polyval(paramsS0_Fe, 650+273), polyval(paramsj0_Fe, 650+273), polyval(paramsjL_Fe, 650+273), 923];
% params700_Islam = [polyval(paramsV0_Fe, 700+273), polyval(params_a_Fe, 700+273), polyval(paramsS0_Fe, 700+273), polyval(paramsj0_Fe, 700+273), polyval(paramsjL_Fe, 700+273), 973];
% params750_Islam = [polyval(paramsV0_Fe, 750+273), polyval(params_a_Fe, 750+273), polyval(paramsS0_Fe, 750+273), polyval(paramsj0_Fe, 750+273), polyval(paramsjL_Fe, 750+273), 1023];

temps = Temperature + 273;
params600_Islam = [parameters_600, temps(1)];
params650_Islam = [parameters_650, temps(2)];
params700_Islam = [parameters_700, temps(3)];
params750_Islam = [parameters_750, temps(4)];

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

avgV600_Islam = mean(Voltage_600); avgP600_Islam = mean(Power_600);
avgV650_Islam = mean(Voltage_600); avgP650_Islam = mean(Power_600);
avgV700_Islam = mean(Voltage_600); avgP700_Islam = mean(Power_600);
avgV750_Islam = mean(Voltage_600); avgP750_Islam = mean(Power_600);

SSRv600_Islam = sum((Volts600_Islam - avgV600_Islam).^2); SSRp600_Islam  = sum((P600_Islam - avgP600_Islam).^2);
SSRv650_Islam = sum((Volts650_Islam - avgV650_Islam).^2); SSRp650_Islam  = sum((P650_Islam - avgP650_Islam).^2);
SSRv700_Islam = sum((Volts700_Islam - avgV700_Islam).^2); SSRp700_Islam  = sum((P700_Islam - avgP700_Islam).^2);
SSRv750_Islam = sum((Volts750_Islam - avgV750_Islam).^2); SSRp750_Islam  = sum((P750_Islam - avgP750_Islam).^2);

SSTv600_Islam = sum((Voltage_600 - avgV600_Islam).^2); SSTp600_Islam  = sum((Power_600 - avgP600_Islam).^2);
SSTv650_Islam = sum((Voltage_650 - avgV650_Islam).^2); SSTp650_Islam  = sum((Power_650 - avgP650_Islam).^2);
SSTv700_Islam = sum((Voltage_700 - avgV700_Islam).^2); SSTp700_Islam  = sum((Power_700 - avgP700_Islam).^2);
SSTv750_Islam = sum((Voltage_750 - avgV750_Islam).^2); SSTp750_Islam  = sum((Power_750 - avgP750_Islam).^2);

% Find R^2
ResVolts600_Islam = SSRv600_Islam/SSTv600_Islam; ResP600_Islam = SSRp600_Islam/SSTp600_Islam;
ResVolts650_Islam = SSRv650_Islam/SSTv650_Islam; ResP650_Islam = SSRp650_Islam/SSTp650_Islam;
ResVolts700_Islam = SSRv700_Islam/SSTv700_Islam; ResP700_Islam = SSRp700_Islam/SSTp700_Islam;
ResVolts750_Islam = SSRv750_Islam/SSTv750_Islam; ResP750_Islam = SSRp750_Islam/SSTp750_Islam;

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

% residual vs predicted plots
figure(3)
subplot(2,4,1)
plot(Voltage_600, ResVolts600_Islam, '*')
xlabel('Actual Voltage (V)')
ylabel('R^2')
legend('600 C')


subplot(2,4,2)
plot(Voltage_650, ResVolts650_Islam, '*')
xlabel('Actual Voltage (V)')
ylabel('R^2')
legend('650 C')

subplot(2,4,3)
plot(Voltage_700, ResVolts700_Islam, '*')
xlabel('Actual Voltage (V)')
ylabel('R^2')
legend('700 C')

subplot(2,4,4)
plot(Voltage_750, ResVolts750_Islam, '*')
xlabel('Actual Voltage (V)')
ylabel('R^2')
legend('750 C')

subplot(2,4,5)
plot(Power_600, ResP600_Islam, '*')
xlabel('Actual Power (W/cm^2)')
ylabel('R^2')
legend('600 C')

subplot(2,4,6)
plot(Power_650, ResP650_Islam, '*')
xlabel('Actual Power (W/cm^2)')
ylabel('R^2')
legend('650 C')

subplot(2,4,7)
plot(Power_700, ResP700_Islam, '*')
xlabel('Actual Power (W/cm^2)')
ylabel('R^2')
legend('700 C')

subplot(2,4,8)
plot(Power_750, ResP750_Islam, '*')
xlabel('Actual Power (W/cm^2)')
ylabel('R^2')
legend('750 C')

% plotting points over trend
figure(4)       % experimental voltage curves
yyaxis left
plot(Current_600, Voltage_600)
hold on
plot(Current_650, Voltage_650, Current_700, Voltage_700, Current_750, Voltage_750)
plot(Current_600, Volts600_Islam, 'o')
plot(Current_650, Volts650_Islam, '+', Current_700, Volts700_Islam, '^', Current_750, Volts750_Islam, 'square')
hold off
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
ylim([0,1.2])

yyaxis right        % experimental power curves
plot(i_600, Power_600)
hold on
plot(i_650, Power_650, i_700, Power_700, i_750, Power_750)
plot(i_600, P600_Islam, 'o')
plot(i_650, P650_Islam, '+', i_700, P700_Islam, '^', i_750, P750_Islam, 'square')
hold off
title('Data from Islam, et al., 2025')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600', '650', '700', '750')
xlim([0,8])
ylim([0,4])