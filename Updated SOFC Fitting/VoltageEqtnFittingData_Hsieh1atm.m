% Title: VoltageEqtnFittingData_Hsieh1atm.m
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
Data = readmatrix('Hsieh2015_1atm.xlsx');

    % 750
Current_750_Hsieh = Data(:,1)'; Voltage_750_Hsieh = Data(:,2)';
i_750_Hsieh = Data(:,3)'; Power_750_Hsieh = Data(:,4)';

Current_750_Hsieh = Current_750_Hsieh(~isnan(Current_750_Hsieh));
Voltage_750_Hsieh = Voltage_750_Hsieh(~isnan(Voltage_750_Hsieh));
i_750_Hsieh = i_750_Hsieh(~isnan(i_750_Hsieh)); 
Power_750_Hsieh = Power_750_Hsieh(~isnan(Power_750_Hsieh)); 
   
    % 800
Current_800_Hsieh = Data(:,6)'; Voltage_800_Hsieh = Data(:,7)';
i_800_Hsieh = Data(:,8)'; Power_800_Hsieh = Data(:,9)';

Current_800_Hsieh = Current_800_Hsieh(~isnan(Current_800_Hsieh));
Voltage_800_Hsieh = Voltage_800_Hsieh(~isnan(Voltage_800_Hsieh));
i_800_Hsieh = i_800_Hsieh(~isnan(i_800_Hsieh)); 
Power_800_Hsieh = Power_800_Hsieh(~isnan(Power_800_Hsieh)); 

    % 850
Current_850_Hsieh = Data(:,11)'; Voltage_850_Hsieh = Data(:,12)';
i_850_Hsieh = Data(:,13)'; Power_850_Hsieh = Data(:,14)';

Current_850_Hsieh = Current_850_Hsieh(~isnan(Current_850_Hsieh));
Voltage_850_Hsieh = Voltage_850_Hsieh(~isnan(Voltage_850_Hsieh));
i_850_Hsieh = i_850_Hsieh(~isnan(i_850_Hsieh)); 
Power_850_Hsieh = Power_850_Hsieh(~isnan(Power_850_Hsieh)); 