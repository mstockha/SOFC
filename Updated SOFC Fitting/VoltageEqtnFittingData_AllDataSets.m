% Title: VoltageEqtnFittingData_AllDataSets.m
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
Data600 = readmatrix('600iViP.xlsx'); Data650 = readmatrix('650iViP.xlsx');
Data700 = readmatrix('700iViP.xlsx'); Data750 = readmatrix('750iViP.xlsx');
Data800 = readmatrix('600iViP.xlsx'); Data850 = readmatrix('650iViP.xlsx');
Data900 = readmatrix('900iViP.xlsx'); Data1000 = readmatrix('1000iViP.xlsx');


%% Temp: 600 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_600 = Data600(:,1); Voltage_600 = Data600(:,2);
i_600 = Data600(:,3); P_600 = Data600(:,4);

Current_600 = Current_600(~isnan(Current_600));
Voltage_600 = Voltage_600(~isnan(Voltage_600));
i_600 = i_600(~isnan(i_600)); P_600 = P_600(~isnan(P_600)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_600)); 
kTest = round(0.05*length(Current_600));
    % index vectors for each dataset
Tidx = randperm(length(Current_600), kTrain);   % random training indices
Vidx = 1:length(Current_600);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent600_Train = Current_600(Tidx);
ExpVoltage600_Train = Voltage_600(Tidx);
ExpCurrent600_Validate = Current_600(Vidx);
ExpVoltage600_Validate = Voltage_600(Vidx);
ExpCurrent600_Test = Current_600(TestIdx);
ExpVoltage600_Test = Voltage_600(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_600)); 
kTest = round(0.05*length(i_600));
    % index vectors for each dataset
Tidx = randperm(length(i_600), kTrain);   % random training indices
Vidx = 1:length(i_600);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi600_Train = i_600(Tidx);
ExpP600_Train = P_600(Tidx);
Expi600_Validate = i_600(Vidx);
ExpP600_Validate = P_600(Vidx);
Expi600_Test = i_600(TestIdx);
ExpP600_Test = P_600(TestIdx);

%% Temp: 650 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_650 = Data650(:,1); Voltage_650 = Data650(:,2);
i_650 = Data650(:,3); P_650 = Data650(:,4);

Current_650 = Current_650(~isnan(Current_650));
Voltage_650 = Voltage_650(~isnan(Voltage_650));
i_650 = i_650(~isnan(i_650)); P_650 = P_650(~isnan(P_650)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_650)); 
kTest = round(0.05*length(Current_650));
    % index vectors for each dataset
Tidx = randperm(length(Current_650), kTrain);   % random training indices
Vidx = 1:length(Current_650);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent650_Train = Current_650(Tidx);
ExpVoltage650_Train = Voltage_650(Tidx);
ExpCurrent650_Validate = Current_650(Vidx);
ExpVoltage650_Validate = Voltage_650(Vidx);
ExpCurrent650_Test = Current_650(TestIdx);
ExpVoltage650_Test = Voltage_650(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_650)); 
kTest = round(0.05*length(i_650));
    % index vectors for each dataset
Tidx = randperm(length(i_650), kTrain);   % random training indices
Vidx = 1:length(i_650);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi650_Train = i_650(Tidx);
ExpP650_Train = P_650(Tidx);
Expi650_Validate = i_650(Vidx);
ExpP650_Validate = P_650(Vidx);
Expi650_Test = i_650(TestIdx);
ExpP650_Test = P_650(TestIdx);

%% Temp: 700 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_700 = Data700(:,1); Voltage_700 = Data700(:,2);
i_700 = Data700(:,3); P_700 = Data700(:,4);

Current_700 = Current_700(~isnan(Current_700));
Voltage_700 = Voltage_700(~isnan(Voltage_700));
i_700 = i_700(~isnan(i_700)); P_700 = P_700(~isnan(P_700)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_700)); 
kTest = round(0.05*length(Current_700));
    % index vectors for each dataset
Tidx = randperm(length(Current_700), kTrain);   % random training indices
Vidx = 1:length(Current_700);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent700_Train = Current_700(Tidx);
ExpVoltage700_Train = Voltage_700(Tidx);
ExpCurrent700_Validate = Current_700(Vidx);
ExpVoltage700_Validate = Voltage_700(Vidx);
ExpCurrent700_Test = Current_700(TestIdx);
ExpVoltage700_Test = Voltage_700(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_700)); 
kTest = round(0.05*length(i_700));
    % index vectors for each dataset
Tidx = randperm(length(i_700), kTrain);   % random training indices
Vidx = 1:length(i_700);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi700_Train = i_700(Tidx);
ExpP700_Train = P_700(Tidx);
Expi700_Validate = i_700(Vidx);
ExpP700_Validate = P_700(Vidx);
Expi700_Test = i_700(TestIdx);
ExpP700_Test = P_700(TestIdx);

%% Temp: 750 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_750 = Data750(:,1); Voltage_750 = Data750(:,2);
i_750 = Data750(:,3); P_750 = Data750(:,4);

Current_750 = Current_750(~isnan(Current_750));
Voltage_750 = Voltage_750(~isnan(Voltage_750));
i_750 = i_750(~isnan(i_750)); P_750 = P_750(~isnan(P_750)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_750)); 
kTest = round(0.05*length(Current_750));
    % index vectors for each dataset
Tidx = randperm(length(Current_750), kTrain);   % random training indices
Vidx = 1:length(Current_750);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent750_Train = Current_750(Tidx);
ExpVoltage750_Train = Voltage_750(Tidx);
ExpCurrent750_Validate = Current_750(Vidx);
ExpVoltage750_Validate = Voltage_750(Vidx);
ExpCurrent750_Test = Current_750(TestIdx);
ExpVoltage750_Test = Voltage_750(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_750)); 
kTest = round(0.05*length(i_750));
    % index vectors for each dataset
Tidx = randperm(length(i_750), kTrain);   % random training indices
Vidx = 1:length(i_750);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi750_Train = i_750(Tidx);
ExpP750_Train = P_750(Tidx);
Expi750_Validate = i_750(Vidx);
ExpP750_Validate = P_750(Vidx);
Expi750_Test = i_750(TestIdx);
ExpP750_Test = P_750(TestIdx);

%% Temp: 800 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_800 = Data800(:,1); Voltage_800 = Data800(:,2);
i_800 = Data800(:,3); P_800 = Data800(:,4);

Current_800 = Current_800(~isnan(Current_800));
Voltage_800 = Voltage_800(~isnan(Voltage_800));
i_800 = i_800(~isnan(i_800)); P_800 = P_800(~isnan(P_800)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_800)); 
kTest = round(0.05*length(Current_800));
    % index vectors for each dataset
Tidx = randperm(length(Current_800), kTrain);   % random training indices
Vidx = 1:length(Current_800);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent800_Train = Current_800(Tidx);
ExpVoltage800_Train = Voltage_800(Tidx);
ExpCurrent800_Validate = Current_800(Vidx);
ExpVoltage800_Validate = Voltage_800(Vidx);
ExpCurrent800_Test = Current_800(TestIdx);
ExpVoltage800_Test = Voltage_800(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_800)); 
kTest = round(0.05*length(i_800));
    % index vectors for each dataset
Tidx = randperm(length(i_800), kTrain);   % random training indices
Vidx = 1:length(i_800);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi800_Train = i_800(Tidx);
ExpP800_Train = P_800(Tidx);
Expi800_Validate = i_800(Vidx);
ExpP800_Validate = P_800(Vidx);
Expi800_Test = i_800(TestIdx);
ExpP800_Test = P_800(TestIdx);

%% Temp: 850 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_850 = Data850(:,1); Voltage_850 = Data850(:,2);
i_850 = Data850(:,3); P_850 = Data850(:,4);

Current_850 = Current_850(~isnan(Current_850));
Voltage_850 = Voltage_850(~isnan(Voltage_850));
i_850 = i_850(~isnan(i_850)); P_850 = P_850(~isnan(P_850)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_850)); 
kTest = round(0.05*length(Current_850));
    % index vectors for each dataset
Tidx = randperm(length(Current_850), kTrain);   % random training indices
Vidx = 1:length(Current_850);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent850_Train = Current_850(Tidx);
ExpVoltage850_Train = Voltage_850(Tidx);
ExpCurrent850_Validate = Current_850(Vidx);
ExpVoltage850_Validate = Voltage_850(Vidx);
ExpCurrent850_Test = Current_850(TestIdx);
ExpVoltage850_Test = Voltage_850(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_850)); 
kTest = round(0.05*length(i_850));
    % index vectors for each dataset
Tidx = randperm(length(i_850), kTrain);   % random training indices
Vidx = 1:length(i_850);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi850_Train = i_850(Tidx);
ExpP850_Train = P_850(Tidx);
Expi850_Validate = i_850(Vidx);
ExpP850_Validate = P_850(Vidx);
Expi850_Test = i_850(TestIdx);
ExpP850_Test = P_850(TestIdx);

%% Temp: 900 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_900 = Data900(:,1); Voltage_900 = Data900(:,2);
i_900 = Data900(:,3); P_900 = Data900(:,4);

Current_900 = Current_900(~isnan(Current_900));
Voltage_900 = Voltage_900(~isnan(Voltage_900));
i_900 = i_900(~isnan(i_900)); P_900 = P_900(~isnan(P_900)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_900)); 
kTest = round(0.05*length(Current_900));
    % index vectors for each dataset
Tidx = randperm(length(Current_900), kTrain);   % random training indices
Vidx = 1:length(Current_900);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent900_Train = Current_900(Tidx);
ExpVoltage900_Train = Voltage_900(Tidx);
ExpCurrent900_Validate = Current_900(Vidx);
ExpVoltage900_Validate = Voltage_900(Vidx);
ExpCurrent900_Test = Current_900(TestIdx);
ExpVoltage900_Test = Voltage_900(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_900)); 
kTest = round(0.05*length(i_900));
    % index vectors for each dataset
Tidx = randperm(length(i_900), kTrain);   % random training indices
Vidx = 1:length(i_900);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi900_Train = i_900(Tidx);
ExpP900_Train = P_900(Tidx);
Expi900_Validate = i_900(Vidx);
ExpP900_Validate = P_900(Vidx);
Expi900_Test = i_900(TestIdx);
ExpP900_Test = P_900(TestIdx);

%% Temp: 1000 C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Current_1000 = Data1000(:,1); Voltage_1000 = Data1000(:,2);
i_1000 = Data1000(:,3); P_1000 = Data1000(:,4);

Current_1000 = Current_1000(~isnan(Current_1000));
Voltage_1000 = Voltage_1000(~isnan(Voltage_1000));
i_1000 = i_1000(~isnan(i_1000)); P_1000 = P_1000(~isnan(P_1000)); 

%%% VOLTAGE DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(Current_1000)); 
kTest = round(0.05*length(Current_1000));
    % index vectors for each dataset
Tidx = randperm(length(Current_1000), kTrain);   % random training indices
Vidx = 1:length(Current_1000);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
ExpCurrent1000_Train = Current_1000(Tidx);
ExpVoltage1000_Train = Voltage_1000(Tidx);
ExpCurrent1000_Validate = Current_1000(Vidx);
ExpVoltage1000_Validate = Voltage_1000(Vidx);
ExpCurrent1000_Test = Current_1000(TestIdx);
ExpVoltage1000_Test = Voltage_1000(TestIdx);

%%% POWER DATA %%%
    % sort data into train/validate/test (70/25/5%)
kTrain = round(0.7*length(i_1000)); 
kTest = round(0.05*length(i_1000));
    % index vectors for each dataset
Tidx = randperm(length(i_1000), kTrain);   % random training indices
Vidx = 1:length(i_1000);                   % set of all indices
Vidx(Tidx) = [];                                % remove training indices from validation
testidx = randperm(length(Vidx), kTest);        % test indices to remove from validation set
TestIdx = Vidx(testidx);                        % set test indices
Vidx(testidx) = [];                             % remove test indices from validation set
    % sort data for ascending
Tidx = sort(Tidx, 'ascend');
Vidx = sort(Vidx, 'ascend');
TestIdx = sort(TestIdx, 'ascend');
    % compile data sets
Expi1000_Train = i_1000(Tidx);
ExpP1000_Train = P_1000(Tidx);
Expi1000_Validate = i_1000(Vidx);
ExpP1000_Validate = P_1000(Vidx);
Expi1000_Test = i_1000(TestIdx);
ExpP1000_Test = P_1000(TestIdx);