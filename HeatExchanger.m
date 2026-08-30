function [totalheatflowrate, heatdotLNGheating, heatdotH2O, heatdotair, heatburner] = HeatExchanger(turbine_heat, LNGflowrate, heatdotfuelreformer, heatdotSOFC, wtankflow, efficiency, Ti_air, Tf_air, airfr)

%% LNG Recuperator Heating

deltaHvap = 510.4;      % kJ/kg
Tf = 700 + 273.15;      % K to heat up fuel reformer to
Ti = 110;               % LNG storage temperature
Tbp = -161.5 + 273.15;  % boiling point

% at 25 deg C vals below
CpCH4g =  2.226; % (kJ/(kg*K))
CpCH4l =  3.49; % (kJ/(kg*K))

% liquid heating to boiling point
q1= LNGflowrate.*CpCH4l.*(Tbp-Ti);  % kg/s*(kJ/(kg*K))*K = kJ/s
% heat of phase change
q2 = LNGflowrate.*deltaHvap;        %kJ/s
% gas heating to reformer temperature
q3 = LNGflowrate.*CpCH4g.*(Tf-Tbp); % kJ/s

% total heat = sum of heat stages
heatdotLNGheating = q1+q2+q3;   % kJ/s


%% Water-Steam Recuperator Heat 

cpH2Og = 1.865;         %(kJ/(kg*K))
cpH2Ol = 4.22;          % (kJ/(kg*K))
deltaHvapW = 2257;      % kJ/kg at 1 atm
Tbpw = 100 + 273.15;    % water boiling point (K)
Tiw = 25 + 273.15;      % water storage at room temperature (K)
Tfw = 700 + 273.15;     % Fuel reformer temp (K)

% heat liquid water toboiling point
qa = wtankflow(1:length(LNGflowrate)) .*cpH2Ol .* (Tbpw-Tiw); % kg/s*(kJ/(kg*K))*K = kJ/s
% heat for phase change
qb = wtankflow(1:length(LNGflowrate)) .*deltaHvapW; % kJ/s
% heat gas to reformer temperature
qc = wtankflow(1:length(LNGflowrate)) .*cpH2Og .* (Tfw - Tbpw); % kJ/s

% total heat flow
heatdotH2O = qa + qb + qc; % kJ/s


%% Air Recuperator Heat

cpair =  1.005;                             % (kJ/(kg*K))
deltaTair = Tf_air - Ti_air;                % Temperature change (K)
heatdotair = airfr .* cpair .* deltaTair;   % Heat flow (kJ/s)


%% determine any additional heat required from duct burning LNG

% determine net heat without burner
heatbalance = turbine_heat + heatdotLNGheating + heatdotfuelreformer ...
    + (efficiency*heatdotSOFC) + heatdotH2O + heatdotair;

% preallocate mission burner heat vector
heatburner = zeros(1, length(LNGflowrate));

% anywhere in the mission the net heat is positive, the system is 
% endothermic and the burner must provide heat 
for i=1:length(LNGflowrate) 
    if heatbalance(i) > 0
        heatburner(i) = -heatbalance(i);
    end
end

%% total SOFC propulsion system heat

totalheatflowrate = turbine_heat + heatdotLNGheating ...
    + heatdotfuelreformer + (efficiency*heatdotSOFC) + heatdotH2O ...
    + heatdotair + heatburner;

end