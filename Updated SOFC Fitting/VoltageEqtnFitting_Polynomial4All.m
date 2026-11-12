% Title: VoltageEqtnFitting_Polynomial4All.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 6 Nov 2026
% 
% % % Description: % % % 
% Polynomial fit including data for all of the fuel cells.

clc; clear;

%Plot Data

load("VoltageFittingDataAll.mat");     % load experimental dataset

figure(1)       % experimental voltage curves
title('Experimental Voltage Data')
subplot(4,2,1)
plot(Current_600, Voltage_600, '*') 
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('600C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,2)
plot(Current_650, Voltage_650, '*' )
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('650C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,3)
plot(Current_700, Voltage_700, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('700C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,4)
plot(Current_750, Voltage_750, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('750C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,5)
plot(Current_800, Voltage_800, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('800C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,6)
plot(Current_850, Voltage_850, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('850C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,7)
plot(Current_900, Voltage_900, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('900C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])

subplot(4,2,8)
plot(Current_1000, Voltage_1000, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')
legend('1000C', Location='northeast')
xlim([0,5.5])
ylim([0, 1.2])


figure(2)       % experimental Power curves
title('Experimental Power Data')
subplot(4,2,1)
plot(i_600, P_600, '*') 
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,2)
plot(i_650, P_650, '*' )
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('650C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,3)
plot(i_700, P_700, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('700C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,4)
plot(i_750, P_750, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('750C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,5)
plot(i_800, P_800, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('800C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,6)
plot(i_850, P_850, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('850C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,7)
plot(i_900, P_900, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('900C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])

subplot(4,2,8)
plot(i_1000, P_1000, '*')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('1000C', Location='southeast')
xlim([0,5.5])
ylim([0,3.5])


%% Voltage Curve Fitting: nonlin least-squares fit I-V curve for each Temperature
 
% Model: Voltage Equation for each temperature
    % j = current density (known input)
    % params = [V0, a, Ri, j0, jL]
    % V0 = thermonuetral/Nernst voltage params(1)
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density
    
Veqtn_600 = @(params, j) params(1) - ((8.314.*873)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*873)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_650 = @(params, j) params(1) - ((8.314.*923)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*823)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_700 = @(params, j) params(1) - ((8.314.*973)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*973)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_750 = @(params, j) params(1) - ((8.314.*1023)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*1023)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_800 = @(params, j) params(1) - ((8.314.*1073)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*1073)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_850 = @(params, j) params(1) - ((8.314.*1123)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*1123)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_900 = @(params, j) params(1) - ((8.314.*1173)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*1173)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));
Veqtn_1000 = @(params, j) params(1) - ((8.314.*1273)./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) + j.*params(3) + (8.314.*1273)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j)));

% Set parameter conditions (true for all temperatures)
initials = [1.06 0.5 0.04 0.1 5.5];           % initial guesses

upper_600 = [1.25 1 1 10 6];                 % upper bounds
lower_600 = [0.9 0.2 0.001 0.001 max(Current_600)+0.001];     % lower bounds
[parameters_600v, residual_600v] = lsqcurvefit(Veqtn_600, initials, Current_600, Voltage_600, lower_600, upper_600);

lower_650 = [0.9 0.2 0.001 0.001 max(Current_650)+0.001];     % lower bounds
upper_650 = [1.25 1 1 10 6];                 % upper bounds
[parameters_650v, residual_650v] = lsqcurvefit(Veqtn_650, initials, Current_650, Voltage_650, lower_650, upper_650);

lower_700 = [0.9 0.2 0.001 0.001 max(Current_700)+0.001];     % lower bounds
upper_700 = [1.25 1 1 10 6];                 % upper bounds
[parameters_700v, residual_700v] = lsqcurvefit(Veqtn_700, initials, Current_700, Voltage_700, lower_700, upper_700);

lower_750 = [0.9 0.2 0.001 0.001 max(Current_750)+0.001];     % lower bounds
upper_750 = [1.25 1 1 10 6];                 % upper bounds
[parameters_750v, residual_750v] = lsqcurvefit(Veqtn_750, initials,Current_750, Voltage_750, lower_750, upper_750);

lower_800 = [0.9 0.2 0.001 0.001 max(Current_800)+0.001];     % lower bounds
upper_800 = [1.25 1 1 10 6];                 % upper bounds
[parameters_800v, residual_800v] = lsqcurvefit(Veqtn_800, initials, Current_800, Voltage_800, lower_800, upper_800);

lower_850 = [0.9 0.2 0.001 0.001 max(Current_850)+0.001];     % lower bounds
upper_850 = [1.25 1 1 10 6];                 % upper bounds
[parameters_850v, residual_850v] = lsqcurvefit(Veqtn_850, initials, Current_850, Voltage_850, lower_850, upper_850);

lower_900 = [0.9 0.2 0.001 0.001 max(Current_900)+0.001];     % lower bounds
upper_900 = [1.25 1 1 10 6];                 % upper bounds
[parameters_900v, residual_900v] = lsqcurvefit(Veqtn_900, initials, Current_900, Voltage_900, lower_900, upper_900);

lower_1000 = [0.9 0.2 0.001 0.001 max(Current_1000)+0.001];     % lower bounds
upper_1000 = [1.25 1 1 10 6];   
[parameters_1000v, residual_1000v] = lsqcurvefit(Veqtn_1000, initials, Current_1000, Voltage_1000, lower_1000, upper_1000);

% Output table
    % column vectors
Temperature = [600; 650; 700; 750; 800; 850; 900; 1000];
V0 = [parameters_600v(1); parameters_650v(1); parameters_700v(1); parameters_750v(1); parameters_800v(1); parameters_850v(1); parameters_900v(1); parameters_1000v(1)];
% V0 = [0.95; 0.95; 0.95; 0.95; 0.95];
a  = [parameters_600v(2); parameters_650v(2); parameters_700v(2); parameters_750v(2); parameters_800v(2); parameters_850v(2); parameters_900v(2); parameters_1000v(2)];
Ri = [parameters_600v(3); parameters_650v(3); parameters_700v(3); parameters_750v(3); parameters_800v(3); parameters_850v(3); parameters_900v(3); parameters_1000v(3)];
j0 = [parameters_600v(4); parameters_650v(4); parameters_700v(4); parameters_750v(4); parameters_800v(4); parameters_850v(4); parameters_900v(4); parameters_1000v(4)];
jL = [parameters_600v(5); parameters_650v(5); parameters_700v(5); parameters_750v(5); parameters_800v(5); parameters_850v(5); parameters_900v(5); parameters_1000v(5)];
residuals = [residual_600v;  residual_650v; residual_700v; residual_750v; residual_800v; residual_850v; residual_900v; residual_1000v];
    % create table
Outputs = table(Temperature, V0, a, Ri, j0, jL, residuals);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares\n')
disp(Outputs)


