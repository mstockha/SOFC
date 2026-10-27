function [min_cells, CellParams, i, V, power] = SOFCsize2(E,T,A)
% local function for cell voltage equation
Veqtn = @(params,j) params(1) ...
    - (8.314.*params(6))./(params(2).*2.*96485.34) .* log(j./params(4)) ...
    - j.*params(3) - (8.314.*params(6))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(5)./(params(5) - j));
% params = [V0, a, Ri, j0, jL, T (Kelvin)]

%% Estimate Voltage Equation Values
% Model: Voltage Equation for each temperature
    % i = current density (known input)
    % params = [V0, a, Ri, j0, jL]
    % V0 = thermonuetral/Nernst voltage
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density

% cell voltage equation (cve) best fit coefficients
temps = [873 973 1073 1173 1273];           % temperature [celsius]
V0_set = [1.03725415711440	1.01891468320676	1.00971564455194	1.00643505567497	1.00330411372350];
Ri_set = [0.641530762954321	0.388420407624452	0.261136514819686	0.209672814526219	0.168876245427943];
j0_set = [0.0609784150044978	0.107294037941175	0.190731967158638	0.250541484550616	0.279377504120229]; 
jL_set = [1.00100000000002	1.02068598022039	1.31203645375411	1.54100201480319	1.66641288039077];

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
T = T + 273;

params_V0 = polyfit(temps, V0_set, 3);   V0 = polyval(params_V0, T);
params_Ri = polyfit(temps, Ri_set, 3);   Ri = polyval(params_Ri, T);
params_j0 = polyfit(temps, j0_set, 3);   j0 = polyval(params_j0, T);
params_jL = polyfit(temps, jL_set, 3);   jL = polyval(params_jL, T);
a = 1;        % da/dT = 0 per curve fitting

CellParams = [V0, a, Ri, j0, jL];


%% Single Cell Sizing: Voltage Equation Analysis
% set current density from 0 to limiting current density (A/cm^2)
i = 0:0.01:(jL - 0.01); i(1) = 0.0001;

% calculate voltage based on parameters (V)
parameters = [CellParams, T];
V = Veqtn(parameters, i);

for count = 1:length(V)
    if V(count) < 0
        V(count) = 0;
    end
end

% due to operation, some values will be imaginary - set to NaN
V(V~=real(V)) = NaN;


% calculate cell power (W/cm^2)
power = i.*V;

% maximum available power density, according to voltage relation
pdens_max = max(power);


%% Determine minimum cell # from maximum power required

E_max = max(E);                     % max experimental power required (W)
min_cells = E_max/(pdens_max*A);    % cell # required @ each time point
min_cells = ceil(min_cells);        % round up to nearest whole number


%% Verify model - output i-V and i-P curves

figure(101) % I-V Curve
plot(i,V)
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')

figure(102) % I-P Curve
plot(i,power,"LineWidth", 2);
ylim([0 1.2]);
xlabel("Current Density (A/cm^2)",'FontSize',13)
ylabel("Power Density (W/cm^2)",'FontSize',13)

end





 
