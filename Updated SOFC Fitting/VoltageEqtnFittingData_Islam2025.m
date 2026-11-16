% Title: VoltageEqtnFittingData_Islam2025.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 6 November 2026
% 
% % % Description: % % % 
% This file includes data digitized for the SOFC to fit the cell voltage 
% equation coefficients. All current datapoints are in units of Amps per 
% sq. centimeter, all voltage differences are in volts, and all power 
% datapoints are in Watts per sq. cm. Plots can be found at:
%
% LIST HERE

clc; clear;

%% Load Data Sets
Data = readmatrix('Islam2025.xlsx');
    
    % 600
Current_600 = Data(:,1)'; Voltage_600 = Data(:,2)';
i_600 = Data(:,3)'; Power_600 = Data(:,4)';

Current_600 = Current_600(~isnan(Current_600));
Voltage_600 = Voltage_600(~isnan(Voltage_600));
i_600 = i_600(~isnan(i_600)); Power_600 = Power_600(~isnan(Power_600)); 

    % 650
Current_650 = Data(:,6)'; Voltage_650 = Data(:,7)';
i_650 = Data(:,8)'; Power_650 = Data(:,9)';

Current_650 = Current_650(~isnan(Current_650));
Voltage_650 = Voltage_650(~isnan(Voltage_650));
i_650 = i_650(~isnan(i_650)); Power_650 = Power_650(~isnan(Power_650)); 

    % 700
Current_700 = Data(:,11)'; Voltage_700 = Data(:,12)';
i_700 = Data(:,13)'; Power_700 = Data(:,14)';

Current_700 = Current_700(~isnan(Current_700));
Voltage_700 = Voltage_700(~isnan(Voltage_700));
i_700 = i_700(~isnan(i_700)); Power_700 = Power_700(~isnan(Power_700)); 

    % 750
Current_750 = Data(:,16)'; Voltage_750 = Data(:,17)';
i_750 = Data(:,18)'; Power_750 = Data(:,19)';

Current_750 = Current_750(~isnan(Current_750));
Voltage_750 = Voltage_750(~isnan(Voltage_750));
i_750 = i_750(~isnan(i_750)); Power_750 = Power_750(~isnan(Power_750)); 
