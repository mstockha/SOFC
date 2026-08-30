function [wbalance, H2Olevelintank, initalwaterintank, SOFC, FRneed, FRrelease, wexhaust, totalexhauststeam, wtankflow] = steamrecyclewatertank(SOFC, FRneed, FRrelease, SOFCtimedelay, FRtimedelay)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% create vectors of zero recycled steam during recycling delay
SOFCdelay = zeros(1,SOFCtimedelay);
Recycledelay = zeros(1,FRtimedelay);

% any steam still in the system at landing will be flushed
RecycleExhaust = SOFC(end-SOFCdelay:end) + FRrelease(end-Recycledelay:end);

% remove exhaust segments from SOFC and FR released vaport vectors
SOFC = [SOFCdelay SOFC(1:end-SOFCtimedelay)];
FRrelease = [Recycledelay FRrelease(1:end-FRtimedelay)];

% negative wbalance means excess steam is exhausted tank, positive means steam is needed from tank
wbalance = FRneed - SOFC - FRrelease; % kg/s
wtankflow = zeros(1, length(wbalance)); % kg/s positive means steam flows out of tank
wexhaust =  zeros(1, length(wbalance)); % kg/s
wequal =  zeros(1, length(wbalance)); 

for i = 1:length(wbalance)
    if wbalance(i) > 0
        wtankflow(i) = wbalance(i);
    elseif wbalance(i)<0
        wexhaust(i) = abs(wbalance(i));
    else
        wequal(i) = 1;
    end
end

% exhaust steam within recycle system at end of flight
wexhaust(end) = wexhaust(end) + RecycleExhaust;

wtankmin = sum(wtankflow); 
tanksafetymargin = 0.1*wtankmin;
initalwaterintank = wtankmin + tanksafetymargin;

H2Olevelintank = zeros(1, length(wbalance)); 

for i = 1:length(wbalance)
        if i == 1
            H2Olevelintank(i) = initalwaterintank - wtankflow(i);
        else
            H2Olevelintank(i) = H2Olevelintank(i-1) - wtankflow(i);
        end
end

totalexhauststeam = sum(wexhaust);
end