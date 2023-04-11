%% Bayesian Quant Learning
% April 2021
% Goal: Run simulation to calculate KL Divergence

%Setup
clear all; close all
%addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Mombasa_climate/BMA_code')
%load('BMA_results_RCP45_2020-11-11.mat')
%load('BMA_results_RCP45_2020-11-10.mat')

% RCP8.5
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/BMA_code')
%load('BMA_results_RCP85_2020-11-11.mat')
load('BMA_results_RCP85_2020-11-14.mat')

addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Bayesian_Quant_Learning');

N = 5;

% Percent change in precip from one time period to next
climParam.P_min = -.3;
climParam.P_max = .3;
climParam.P_delta = .02; 
s_P = climParam.P_min : climParam.P_delta : climParam.P_max;
climParam.P0 = s_P(15);
climParam.P0_abs = 77; %mm/month
M_P = length(s_P);

% Change in temperature from one time period to next
climParam.T_min = 0;
climParam.T_max = 1.5;
climParam.T_delta = 0.05; % deg C
s_T = climParam.T_min: climParam.T_delta: climParam.T_max;
climParam.T0 = s_T(1);
climParam.T0_abs = 26;
M_T = length(s_T);

% Absolute temperature values
T_abs_max = max(s_T) * N;
s_T_abs = climParam.T0_abs : climParam.T_delta : climParam.T0_abs+ T_abs_max;
M_T_abs = length(s_T_abs);
T_bins = [s_T_abs-climParam.T_delta/2 s_T_abs(end)+climParam.T_delta/2];

% Absolute percip values
P_abs_max = max(s_P) * N;
s_P_abs = 66:1:97;
M_P_abs = length(s_P_abs);
P_bins = [s_P_abs-climParam.P_delta/2 s_P_abs(end)+climParam.P_delta/2];

climParam = struct;
climParam.numSamp_delta2abs = 100000;
climParam.numSampTS = 100;
climParam.checkBins = true;

% Percent change in precip from one time period to next
climParam.P_min = -.3;
climParam.P_max = .3;
climParam.P_delta = .02; 
s_P = climParam.P_min : climParam.P_delta : climParam.P_max;
climParam.P0 = s_P(15);
climParam.P0_abs = 77; %mm/month
M_P = length(s_P);

% Change in temperature from one time period to next
climParam.T_min = 0;
climParam.T_max = 1.5;
climParam.T_delta = 0.05; % deg C
s_T = climParam.T_min: climParam.T_delta: climParam.T_max;
climParam.T0 = s_T(1);
climParam.T0_abs = 26;
M_T = length(s_T);

%[T_Temp, T_Precip, ~, ~, ~, ~] = bma2TransMat( NUT, NUP, s_T, s_P, N, climParam);
%addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/SDP');
%load('T_Temp_Precip_wetter4.mat');

numSamp = 25000;
decades = { '1990', '2010', '2030', '2050', '2070', '2090'};

% Starting point
T0 = s_T(1);
T0_abs = 26;
P0 = s_P(15);
P0_abs = 77;

% Updating over time with runoff
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Mombasa_climate/SDP')
load('runoff_by_state_Mar16_knnboot_1t')

scenarios = {'Dry, High Learning', 'Mod, High Learning', 'Wet, High Learning',...
    'Dry, Medium Learning', 'Mod, Medium Learning', 'Wet, Medium Learning',...
    'Dry, Low Learning', 'Mod, Low Learning', 'Wet, Low Learning'};

files = {'T_Temp_Precip_dry1', 'T_Temp_Precip_mod1', 'T_Temp_Precip_wet1', ...
    'T_Temp_Precip_dry2', 'T_Temp_Precip_mod2', 'T_Temp_Precip_wet2', ...
    'T_Temp_Precip_dry4', 'T_Temp_Precip_mod4', 'T_Temp_Precip_wet4'};

numRuns = 2000;

state_ind_P_dry = zeros(numRuns, 6);
state_ind_P_mod = zeros(numRuns, 6);
state_ind_P_wet = zeros(numRuns, 6);
%%  Run for loop to create sample sets
tic
for a=1:2 % high, medium, low learning
    for b=1 %dry, mod, wet
        % load transition matrices
        addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/SDP/TMs_Test_22_Jun_2021_16_02_34');
        load(files{b+(a-1)*3});
%         if b==1
%             load(files{4});
%         elseif b==3
%             load(files{6});
%         end
        
        % load flexible, unexpanded storage size
        addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Operations/Fletcher_2019_Learning_Climate/SDP/Results_22June2021');
        fileName = strcat('BestFlexStatic_', files{b+(a-1)*3}, '.mat');
        load(fileName, 'storage');
        
        % load shortages using the optimized reservoir operations
        unmet_dom = storageSize2domShortage(storage(2), 1, N, M_T_abs, M_P_abs);
        
        for M=1:numRuns
            % Set time series
            state_ind_P = zeros(1,N+1); % state_ind_P = zeros(1,N)
            state_ind_T = zeros(1,N+1); % state_ind_T = zeros(1,N)
            state_ind_P(1) =  find(P0_abs==s_P_abs);
            state_ind_T(1) = find(T0_abs==s_T_abs);
            randGen = true;
            
            MAR = cellfun(@(x) mean(mean(x)), runoff);
            p = randi(numSamp,N-1);
            T_over_time = cell(1,N);
            P_over_time = cell(1,N);
            MAR_over_time = cell(1,N);
            
            for t = 1:N
                % Sample forward distribution given current state
                T_current = s_T_abs(state_ind_T(t));
                P_current = s_P_abs(state_ind_P(t));
                [T_over_time{t}] = T2forwardSimTemp(T_Temp, s_T_abs, N, t, T_current, numSamp, false);
                [P_over_time{t}] = T2forwardSimTemp(T_Precip, s_P_abs, N, t, P_current, numSamp, false);
                
                % Lookup MAR and yield for forward distribution
                T_ind = arrayfun(@(x) find(x == s_T_abs), T_over_time{t});
                P_ind = arrayfun(@(x) find(x == s_P_abs), P_over_time{t});
                [~,t_steps] = size(T_ind);
                MAR_over_time{t} = zeros(size(T_ind));
                yield_over_time{t} = zeros(size(T_ind));
                for i = 1:numSamp
                    for j = 1:t_steps
                        MAR_over_time{t}(i,j) = MAR(T_ind(i,j), P_ind(i,j), 1);
                        yield_over_time{t}(i,j) = unmet_dom(T_ind(i,j), P_ind(i,j),1, 1) ; % flex unexpanded size (MCM)
                    end
                end
                
                % Sample next time period
                if a == 1
                    if randGen
                        state_ind_T(t+1) = find(T_over_time{t}(p(t),2)==s_T_abs);
                        state_ind_P(t+1) = find(P_over_time{t}(p(t),2)==s_P_abs);
                    end
                    if mod(b,3) == 1
                        state_ind_P_dry(M,:) = state_ind_P;
                    elseif mod(b,3) == 2
                        state_ind_P_mod(M,:) = state_ind_P;
                    else
                        state_ind_P_wet(M,:) = state_ind_P;
                    end
                else
                    if randGen
                        state_ind_T(t+1) = find(T_over_time{t}(p(t),2)==s_T_abs);
                    end
                        if mod(b,3) == 1
                            state_ind_P = state_ind_P_dry(M,:);
                        elseif mod(b,3) == 2
                            state_ind_P = state_ind_P_mod(M,:);
                        else
                            state_ind_P = state_ind_P_wet(M,:);
                        end
                end
            end
            
            % calculate KL Divergence
            % Specify calculation method and input parameters
            param.CalcMethod = 2; % 1 = Simple, 2 = Bin Counting, 3 = BC + Zero + BoxCox
            param.NumBins = 50;
            param.Const = 1*10^-4; % Account for zeros by adding a small value
            param.Transform = 0; % 0 = no transform, 1 = boxcox, 2 = log
            
            % Calc precip using bin discretization
            KLDiv_Precip_Simple(M,:,b+(a-1)*3) = CalcKLDivergence(P_over_time, 3, 0, param.Const, param.NumBins);
            
            % Log Transform, Optimal Bins
            KLDiv_Precip_Log(M,:,b+(a-1)*3) = CalcKLDivergence(P_over_time, 2, 2, param.Const, param.NumBins);
            KLDiv_MAR_Log_Opt(M,:,b+(a-1)*3) = CalcKLDivergence(MAR_over_time, 2, 2, param.Const, param.NumBins);
            KLDiv_Yield_Log_Opt(M,:,b+(a-1)*3) = CalcKLDivergence(yield_over_time, 2, 2, param.Const, param.NumBins);
            
            if N==5 && j==1
                state_ind_P_runs(M,:) = state_ind_P;
                state_ind_T_runs(M,:) = state_ind_T;
                for c=1:size(state_ind_P_runs, 2)
                    state_ind_MAR(M,c) = MAR(state_ind_T(c), state_ind_P(c), 1);
                    state_ind_Yield(M,c) = unmet_dom(state_ind_T(c), state_ind_P(c), 1, 1);
                end
            end
            
            stateMsg = strcat('M= ', num2str(M));
            disp(stateMsg);
        end
        stateMsg = strcat('a = ', num2str(a), ', b = ', num2str(b));
        disp(stateMsg);
        toc;
    end
end
cd('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Operations/Fletcher_2019_Learning_Climate/SDP/Results_22June2021');
save('KLdiv_all_28June2021.mat');
%% 
% save('KLdiv_RCP45_26Apr2021.mat', 'KLDiv_Precip_Simple', 'KLDiv_MAR_Simple', 'KLDiv_Yield_Simple',...
%     'KLDiv_Precip_Simple_10E5', 'KLDiv_MAR_Simple_10E5', 'KLDiv_Yield_Simple_10E5',...
%     'KLDiv_Precip_Simple_10E3', 'KLDiv_MAR_Simple_10E3', 'KLDiv_Yield_Simple_10E3');
    
 save('KLdiv_RCP45_26Apr2021.mat', 'KLDiv_Precip_Simple', 'KLDiv_MAR_Simple', 'KLDiv_Yield_Simple', ...
     'KLDiv_MAR_OptBins', 'KLDiv_Yield_OptBins', 'KLDiv_Precip_Boxcox', 'KLDiv_MAR_Boxcox', 'KLDiv_Yield_Boxcox', ...
     'KLDiv_Precip_Log', 'KLDiv_MAR_Log', 'KLDiv_Yield_Log');

%% check discretization of MAR
test = unique(MAR_over_time{1});
for i=2:length(test)
    diff(i-1) = test(i)-test(i-1);
end
max(diff) % 0.9014
min(diff) % 6.729e-05
mean(diff) % 0.0792
median(diff) % 0.0566

%% check discretization of shortage
test = unique(yield_over_time{1});
for i=2:length(test)
    diff(i-1) = test(i)-test(i-1);
end
max(diff) % 0.9014
min(diff) % 1.7585e-06
mean(diff) % 0.0467
median(diff) % 0.0070
%% Boxplots for Analyzing Different KL Divergence Calculation Methods
C = {[0.6350, 0.0780, 0.1840], [0.8500, 0.3250, 0.0980], [0.4660, 0.6740, 0.1880],...
    [0, 0.4470, 0.7410], [0.4940, 0.1840, 0.5560]};

figure('Position', [362 84 840 620]);
subplot(3,1,1)
pos1 = 1:1:10;
b1 = boxplot(KLDiv_Precip_Simple(ind_wet2,:), 'width', 0.15, 'positions', pos1, ...
    'colors', C{1}, 'symbol', '');
hold on
% b2 = boxplot(KLDiv_Precip_OptBins, 'width', 0.15, 'positions', (pos1+0.2), ...
%     'colors', C{2}, 'symbol', 'kx');
b3 = boxplot(KLDiv_Precip_Boxcox(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.4), ...
    'colors', C{3}, 'symbol', '');
b4 = boxplot(KLDiv_Precip_Log(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.6), ...
    'colors', C{4}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
%set(b2, 'LineWidth', 1.5);
set(b3, 'LineWidth', 1.5);
set(b4, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 2]);
ylabel('KL Divergence');
title('KL Divergence for Monthly Precipitation');

subplot(3,1,2)
b1 = boxplot(KLDiv_MAR_Simple(ind_wet2,:), 'width', 0.15, 'positions', pos1, ...
    'colors', C{1}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_MAR_OptBins(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.2), ...
    'colors', C{2}, 'symbol', '');
b3 = boxplot(KLDiv_MAR_Boxcox(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.4), ...
    'colors', C{3}, 'symbol', '');
b4 = boxplot(KLDiv_MAR_Log(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.6), ...
    'colors', C{4}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
set(b3, 'LineWidth', 1.5);
set(b4, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 2]);
ylabel('KL Divergence');
title('KL Divergence for Mean Annual Runoff');

subplot(3,1,3)
b1 = boxplot(KLDiv_Yield_Simple(ind_wet2,:), 'width', 0.15, 'positions', pos1, ...
    'colors', C{1}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_Yield_OptBins(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.2), ...
    'colors', C{2}, 'symbol', '');
b3 = boxplot(KLDiv_Yield_Boxcox(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.4), ...
    'colors', C{3}, 'symbol', '');
b4 = boxplot(KLDiv_Yield_Log(ind_wet2,:), 'width', 0.15, 'positions', (pos1+0.6), ...
    'colors', C{4}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
set(b3, 'LineWidth', 1.5);
set(b4, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 2]);
xlabel('Time Period/Yrs Analyzed');
ylabel('KL Divergence');
legend([b1(1,1), b2(1,1), b3(1,1), b4(1,1)], {'Simple Method (50 Bins)', ...
    'Optimal BW Method', 'Boxcox Transform', 'Log Transform'}, 'Location', ...
    'northwest');
legend('boxoff');
title('KL Divergence for Mean Annual Shortage');
t1 = sgtitle('Wet Runs (Precip Avg >= 81 mm/mo excluding starting state)');
%% Boxplot for Analyzing Different Metrics (Precip, MAR, Shortage)

figure('Position', [362 84 840 620]);
subplot(3,1,1)
pos1 = 1:1:10;
b1 = boxplot(KLDiv_Precip_Simple, 'width', 0.2, 'positions', pos1, ...
    'colors', C{1}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_MAR_Simple, 'width', 0.2, 'positions', (pos1+0.25), ...
    'colors', C{2}, 'symbol', '');
b3 = boxplot(KLDiv_Yield_Simple, 'width', 0.2, 'positions', (pos1+0.5), ...
    'colors', C{4}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
set(b3, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 2]);
ylabel('KL Divergence');
title('KL Divergence Calcs using Method 1 (Simple Method w/ 50 Bins except Precip)');

subplot(3,1,2)
%b1 = boxplot(KLDiv_Precip_OptBins, 'width', 0.2, 'positions', pos1, ...
%    'colors', C{1}, 'symbol', '');
%hold on
b2 = boxplot(KLDiv_MAR_OptBins, 'width', 0.2, 'positions', (pos1+0.25), ...
    'colors', C{2}, 'symbol', '');
hold on
b3 = boxplot(KLDiv_Yield_OptBins, 'width', 0.2, 'positions', (pos1+0.5), ...
    'colors', C{4}, 'symbol', '');
%set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
set(b3, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 2]);
ylabel('KL Divergence');
title('KL Divergence Calcs using Method 2 (Optimal Bin Width & No Precip)');

subplot(3,1,3)
b1 = boxplot(KLDiv_Precip_Log, 'width', 0.2, 'positions', pos1, ...
    'colors', C{1}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_MAR_Log, 'width', 0.2, 'positions', (pos1+0.25), ...
    'colors', C{2}, 'symbol', '');
b3 = boxplot(KLDiv_Yield_Log, 'width', 0.2, 'positions', (pos1+0.5), ...
    'colors', C{4}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
set(b3, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 2]);
xlabel('Time Period/Yrs Analyzed');
ylabel('KL Divergence');
legend([b1(1,1), b2(1,1), b3(1,1)], {'Precip', ...
    'MAR', 'Shortage'}, 'Location', ...
    'northwest');
legend('boxoff');
title('KL Divergence Calcs using Method 4 (Log Transform)');

%% Boxplots comparing dry and wet for optimal bin width method

% Precip
figure('Position', [362 84 840 620]);
subplot(3,1,1)
pos1 = 1:1:10;
b1 = boxplot(KLDiv_Precip_Simple(ind_wet2,:), 'width', 0.15, 'positions', pos1, ...
    'colors', C{4}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_Precip_Simple(ind_dry2,:), 'width', 0.15, 'positions', (pos1+0.25), ...
    'colors', C{1}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 3]);
ylabel('KL Divergence');
title('KL Divergence for Monthly Precipitation');

% MAR
subplot(3,1,2)
b1 = boxplot(KLDiv_MAR_OptBins(ind_wet2,:), 'width', 0.15, 'positions', pos1, ...
    'colors', C{4}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_MAR_OptBins(ind_dry2,:), 'width', 0.15, 'positions', (pos1+0.25), ...
    'colors', C{1}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 3]);
ylabel('KL Divergence');
title('KL Divergence for Mean Annual Runoff');

% shortage
subplot(3,1,3)
b1 = boxplot(KLDiv_Yield_OptBins(ind_wet2,:), 'width', 0.15, 'positions', pos1, ...
    'colors', C{4}, 'symbol', '');
hold on
b2 = boxplot(KLDiv_Yield_OptBins(ind_dry2,:), 'width', 0.15, 'positions', (pos1+0.25), ...
    'colors', C{1}, 'symbol', '');
set(b1, 'LineWidth', 1.5);
set(b2, 'LineWidth', 1.5);
xlim([0.75 11])
ylim([0 3]);
xlabel('Time Period/Yrs Analyzed');
ylabel('KL Divergence');
legend([b1(1,1), b2(1,1)], {'Wet Instances', ...
    'Dry Instances'}, 'Location', ...
    'northeast');
legend('boxoff');
title('KL Divergence for Mean Annual Shortage');
sgtitle('KL Divergence for Wet and Dry Instances');

