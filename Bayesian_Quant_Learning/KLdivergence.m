%% Calculate KL Divergence using yield_over_time
% Specify calculation method
param.CalcMethod = 2; % 1 = Simple, 2 = Bin Counting, 3 = BC + Zero + BoxCox
param.NumBins = 50;
param.Const = 1*10^-4; % Account for zeros by adding a small value
param.Transform = 0; % 0 = no transform, 1 = boxcox, 2 = log

%% Method 1 or 2: The Simple Method or Optimal Bin Width Method
% Simple Method
for i=1:4 % 1:4
    disp(['i = ', num2str(i)]);
    for j=2:6-i % 2:6-i
        % get data
        dist1 = MAR_over_time{i}(:,j+1);
        dist2 = MAR_over_time{i+1}(:,j);
        
        % test out boxcox or log transform
        if param.Transform == 1
            t1 = find(dist1 == 0);
            t2 = find(dist2 == 0);
            dist1(t1) = param.Const;
            dist1(t2) = param.Const;
            dist1 = boxcox(dist1);
            dist2 = boxcox(dist2);
        elseif param.Transform == 2
                        t1 = find(dist1 == 0);
            t2 = find(dist2 == 0);
            dist1(t1) = param.Const;
            dist1(t2) = param.Const;
            dist1 = log(dist1);
            dist2 = log(dist2);
        end
        
        % Get min, max, and range for two distributions
        minYield = min(min(dist1, dist2));
        maxYield = max(max(dist1, dist2));
        % Optimal Bin Width from Gong et al. (2014)
        if param.CalcMethod == 1
            binWidth = (ceil(maxYield)-floor(minYield))/param.NumBins;
        elseif param.CalcMethod == 2
            % assumes Gaussian distribution
            OptBW1 = 3.49*std(dist1)*(length(dist1)^(-1/3)); % oversmoothed rule uses constant of 3.73
            OptBW2 = 3.49*std(dist2)*(length(dist2)^(-1/3));
            binWidth = round(mean([OptBW1, OptBW2]), 3);
        end
       
        range = floor(minYield):binWidth:ceil(maxYield);
        
        % Get pdfs for each distribution
        time1 = histcounts(dist1, range, 'Normalization', 'Probability');
        time2 = histcounts(dist2, range, 'Normalization', 'Probability');
        
        % find values equal to and greater than zero
        ind1 = find(time1==0);
        ind1Valid = find(time1 > 0);
        ind2 = find(time2==0);
        ind2Valid = find(time2 > 0);
        
        % adjust values with small constant to "smooth" pdf
        time1(ind1)=param.Const/length(ind1);
        time1(ind1Valid)=time1(ind1Valid)-param.Const/length(ind1Valid);
        time2(ind2)=param.Const/length(ind2);
        time2(ind2Valid)=time2(ind2Valid)-param.Const/length(ind2Valid);

        % Calculate KL-Divergence
        sum = 0;
        if length(time1) ~= length(time2)
            error('Error: distributions do not have the same bins');
        end
        for k=1:length(time1)
            sum = sum + time2(k)*log(time2(k)/time1(k));
        end
        disp(['KL Div: ', num2str(sum)]);
    end 
end
%% 
% Data Tests
dist1 = yield_over_time{1}(:,6);
dist2 = yield_over_time{2}(:,5);
precip1 = P_over_time{1}(:,3);
precip2 = P_over_time{2}(:,2);
runoff1 = MAR_over_time{1}(:,3);
runoff2 = MAR_over_time{2}(:,2);

% Optimal Bin Width from Gong et al. (2014
% assumes Gaussian distribution
OptBW1 = 3.49*std(dist1)*(length(dist1)^(-1/3)); % oversmoothed rule uses constant of 3.73
OptBW2 = 3.49*std(dist2)*(length(dist2)^(-1/3));
AvgBW = round(mean([OptBW1, OptBW2]), 3);

%% Deal with zero effect
% find nonzero ratio
kx1 = length(find(dist1 > 0))/length(dist1);
kx2 = length(find(dist2 > 0))/length(dist2);

%% Data Processing- "Smooth" distributions
% Get min and max values for two distributions
minYield = min(min(dist1, dist2));
maxYield = max(max(dist1, dist2));

% Get range for two distributions
range = floor(minYield):0.5:ceil(maxYield);

% Get pdfs for each distribution
time1 = histcounts(yield_over_time{1}(:,3), range, 'Normalization', 'Probability');
time2 = histcounts(yield_over_time{2}(:,2), range, 'Normalization', 'Probability');

% Account for zeros by adding a small value
const = 1*10^-7;

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
%%
% Calculate KL-Divergence
sum = 0;
if length(time1) ~= length(time2)
    error('Error: distributions do not have the same bins');
end

for i=1:length(time1)
    sum = sum + time2(i)*log(time2(i)/time1(i));
end

disp(['KL Div: ', num2str(sum)]);
%% histograms of data
histogram(yield_over_time{1}(:,3), 10, 'Normalization', 'Probability');
hold on
histogram(yield_over_time{2}(:,2), 10, 'Normalization', 'Probability');
xlabel('Shortage (mcm/y)');
ylabel('Probability');
legend('1990 Data', '2010 Data');
title('Histograms of Shortage Distributions Predicted in 1990 and 2010 for 2030');