% Title: VoltageEqtnFittingData_Hsieh31atm.m
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
Data = readmatrix('Hsieh2015_3atm.xlsx');

    % 750
Current_750_Hsieh3 = Data(:,1)'; Voltage_750_Hsieh3 = Data(:,2)';
i_750_Hsieh3 = Data(:,3)'; Power_750_Hsieh3 = Data(:,4)';

Current_750_Hsieh3 = Current_750_Hsieh3(~isnan(Current_750_Hsieh3));
Voltage_750_Hsieh3 = Voltage_750_Hsieh3(~isnan(Voltage_750_Hsieh3));
i_750_Hsieh3 = i_750_Hsieh3(~isnan(i_750_Hsieh3)); 
Power_750_Hsieh3 = Power_750_Hsieh3(~isnan(Power_750_Hsieh3)); 
   
    % 800
Current_800_Hsieh3 = Data(:,6)'; Voltage_800_Hsieh3 = Data(:,7)';
i_800_Hsieh3 = Data(:,8)'; Power_800_Hsieh3 = Data(:,9)';

Current_800_Hsieh3 = Current_800_Hsieh3(~isnan(Current_800_Hsieh3));
Voltage_800_Hsieh3 = Voltage_800_Hsieh3(~isnan(Voltage_800_Hsieh3));
i_800_Hsieh3 = i_800_Hsieh3(~isnan(i_800_Hsieh3)); 
Power_800_Hsieh3 = Power_800_Hsieh3(~isnan(Power_800_Hsieh3)); 

    % 850
Current_850_Hsieh3 = Data(:,11)'; Voltage_850_Hsieh3 = Data(:,12)';
i_850_Hsieh3 = Data(:,13)'; Power_850_Hsieh3 = Data(:,14)';

Current_850_Hsieh3 = Current_850_Hsieh3(~isnan(Current_850_Hsieh3));
Voltage_850_Hsieh3 = Voltage_850_Hsieh3(~isnan(Voltage_850_Hsieh3));
i_850_Hsieh3 = i_850_Hsieh3(~isnan(i_850_Hsieh3)); 
Power_850_Hsieh3 = Power_850_Hsieh3(~isnan(Power_850_Hsieh3)); 