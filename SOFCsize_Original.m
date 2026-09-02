function [min_cells, i, V, power] = SOFCsize_Original(E,T,A)

pH2 = 0.98;

%% Estimate Voltage Equation Values

% cell voltage equation (cve) coefficients - best fit based on Whale
% Optimization Algorithm approach
temp = [700,750,800];           % temperature [celsius]
res = [0.05, 0.0367, 0.0307];   % resistance  
i0 = [0.2327, 0.38, 0.38];      % exchange current density
ias = [2.3, 2.8397, 3.1323];    % anodic saturation density
ics = [2.3, 2.8292, 3.1311];    % cathodic saturation density

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
syms t
% anodic saturation current density
coeff_ias = polyfit(temp,ias,1);
iaseq = coeff_ias(1)*t + coeff_ias(2);
% area specific ohmic resistance
coeff_res = polyfit(temp,res,1);
reseq = coeff_res(1)*t + coeff_res(2);
% cathodic saturation current density
coeff_ics = polyfit(temp,ics,1);
icseq = coeff_ics(1)*t + coeff_ics(2);
% exchange current density
coeff_i0 = polyfit(temp,i0,1);
i0eq = coeff_i0(1)*t + coeff_i0(2);

% estimate values for given case based on temperature
res_real = subs(reseq,t,T);     
ias_real = subs(iaseq,t,T);
ics_real = subs(icseq,t,T);
i0_real = subs(i0eq,t,T);


%% Single Cell Sizing: Voltage Equation Analysis

% set constants for cell voltage equation
V0 = 1.121;             % Nernst voltage (V)
R = 8.314;              % universal gas constant (J/mol*K)
n = 1;                  % number of charges/electrons transferred
F = 96485;              % Faraday's constant (C/mol)
pH20 = 1- pH2;          % partial pressure of water (atm)
T = T + 273.15;         % convert ops temperature to K

% initialize voltage loop
i = 0;                  % initial current (amps)
V = 0;                  % initial cell voltage (V)
ntemp = 0;              % current counter for loop - counts up
Vtemp = 10000;          % voltage counter for loop - counts down
j=1;                    % iteration counter - counts up

% loop over current values to calculate all corresponding voltages
while Vtemp > 0 % stop looping when losses due to current > nernst voltage
    % set current index to ntemp counter value
    i(j) = ntemp; 
    % calculate voltage for current value
    V(j) = V0 - ntemp.*res_real - 2.*R.*T./n./F .* log(1./2 ...
        .* (ntemp./i0_real + sqrt((ntemp./i0_real).^2 +4))) ...
        + R.*T./2./F .* log(1 - ntemp./ias_real)- R.*T./2./F ...
        .* log(1 + pH2.*ntemp./pH20./ias_real) + R.*T./4./F ...
        .* log(1 - ntemp./ics_real);
    Vtemp = V(j);           % reset voltage counter with new cell voltage
    ntemp = ntemp + 0.01;   % increase current value 0.01 amps 
    j = j +1;               % increase iteration count for next iteration
end

% due to square root operation, some values will be imaginary - set to NaN
V(V~=real(V)) = NaN;

% calculate cell power
power = i.*V;

% maximum available power density, according to voltage relation
pdens_max = max(power);

% verify model - output i-V and i-P curves
figure(101)
plot(i,V)
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')

figure(102)
plot(i,power,"LineWidth", 2);
ylim([0 1.2]);
xlabel("Current Density (A/cm^2)",'FontSize',13)
ylabel("Power Density (W/cm^2)",'FontSize',13)


%% Determine minimum cell # from maximum power required

E_max = max(E);                     % max experimental power required (W)
min_cells = E_max/(pdens_max*A);    % cell # required @ each time point
min_cells = ceil(min_cells);        % round up to nearest whole number

end