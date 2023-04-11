function [KLDiv] = CalcDist2KLD(dist1, dist2, CalcMethod, constParam, NumBins)

const = constParam;

 % Get min, max, and range for two distributions
minYield = min(min(dist1, dist2));
maxYield = max(max(dist1, dist2));

% Optimal Bin Width from Gong et al. (2014)
binWidth = 0.01; % default value
if CalcMethod == 1
    binWidth = (ceil(maxYield)-floor(minYield))/NumBins;
elseif CalcMethod == 2
    % assumes Gaussian distribution
    OptBW1 = 3.49*std(dist1)*(length(dist1)^(-1/3)); % oversmoothed rule uses constant of 3.73
    OptBW2 = 3.49*std(dist2)*(length(dist2)^(-1/3));
    binWidth = round(mean([OptBW1, OptBW2]), 3);
elseif CalcMethod == 3
    % for precip only- bin size = discretization size
    binWidth = 1;
end
if binWidth == 0
    %disp('hi');
    binWidth = 0.01;
end

range = floor(minYield):binWidth:ceil(maxYield);
if range == 0
    range = 1;
end

% Get pdfs for each distribution
time1 = histcounts(dist1, range, 'Normalization', 'Probability');
time2 = histcounts(dist2, range, 'Normalization', 'Probability');

% set constant value based on the smaller of the constant from
% above and min value in time 1 or time 2 divided by 100
if min(min(time1(time1>0), min(time2(time2>0)))) < const
    const = min(min(time1(time1>0), min(time2(time2>0))))/100;
    %disp(num2str(const));
end

% find values equal to and greater than zero
ind1 = find(time1==0);
ind1Valid = find(time1 > 0);
ind2 = find(time2==0);
ind2Valid = find(time2 > 0);

% adjust values with small constant to "smooth" pdf
time1(ind1)=const/length(ind1);
time1(ind1Valid)=time1(ind1Valid)-const/length(ind1Valid);
time2(ind2)=const/length(ind2);
time2(ind2Valid)=time2(ind2Valid)-const/length(ind2Valid);

% Calculate KL-Divergence
sum = 0;
if length(time1) ~= length(time2)
    error('Error: distributions do not have the same bins');
end
for m=1:length(time1)
    sum = sum + time2(m)*log(time2(m)/time1(m));
end
%disp(['j = ', num2str(j)]);
%disp(sum);
if imag(sum) > 0
    error(['Complex Number: i=', num2str(i), ', j=', num2str(j)]);
end
KLDiv = sum;

end