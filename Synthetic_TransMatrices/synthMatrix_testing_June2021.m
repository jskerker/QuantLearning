%% test updated version of synthMatrix_stateSpace function
% June 21, 2021
TM_test1 = synthMatrix_stateSpace(2, 4, 0.8, Prng, 0); % changes over time
TM_test2 = synthMatrix_stateSpace(2, 4, 0.8, Prng, 1); % constant over time

for i=1:5
    subplot(5,2,2*i-1)
    imagesc(TM_test1(:,:,i));
    colorbar;
    set(gca, 'YDir', 'normal');
    if i==1
        title(['StDev Changes over Time, N = ', num2str(i)]);
    else
        title(['N = ', num2str(i)]);
    end
    %axis square
    
    subplot(5,2,2*i)
    imagesc(TM_test2(:,:,i));
    colorbar;
    set(gca, 'YDir', 'normal');
    if i==1
        title(['StDev Constant over Time, N = ', num2str(i)]);
    else
        title(['N = ', num2str(i)]);
    end
    %axis square
end

%%
for i=1:5
    subplot(5,1,i)
    imagesc(T_Precip_all(:,:,i, 2));
    colorbar;
    set(gca, 'YDir', 'normal');
    if i==1
        title(['StDev Changes over Time, N = ', num2str(i)]);
    else
        title(['N = ', num2str(i)]);
    end
    %axis square
end
%% START RUNNING HERE

N = 5;

% Percent change in precip from one time period to next
climParam.P_min = -.3;
climParam.P_max = .3;
climParam.P_delta = .02; 
s_P = climParam.P_min : climParam.P_delta : climParam.P_max;
climParam.P0 = s_P(15);
climParam.P0_abs = 77; %mm/month
M_P = length(s_P);

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

numSamp = 25000;
decades = { '1990', '2010', '2030', '2050', '2070', '2090'};

% Starting point
P0 = s_P(15);
P0_abs = 77;

addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);

scenarios = {'Dry, High Learning', 'Mod, High Learning', 'Wet, High Learning',...
    'Dry, Medium Learning', 'Mod, Medium Learning', 'Wet, Medium Learning',...
    'Dry, Low Learning', 'Mod, Low Learning', 'Wet, Low Learning'};

files2 = {'T_Temp_Precip_dry1', 'T_Temp_Precip_mod1', 'T_Temp_Precip_wet1', ...
    'T_Temp_Precip_dry2', 'T_Temp_Precip_mod2', 'T_Temp_Precip_wet2', ...
    'T_Temp_Precip_dry4', 'T_Temp_Precip_mod4', 'T_Temp_Precip_wet4'};

%% try plotting learning over time

state_ind_P = zeros(1,N+1);
state_ind_P(1) =  find(P0_abs==s_P_abs);
%state_ind_P(2:end) = [13 14 15 15 17];
randGen = true;
p = randi(numSamp,N-1);
P_over_time = cell(1,N);
sig_vals = [0.6, 0.8, 1];
T_Precip_all = zeros(32, 32, 5, 9);

figure('Position', [360 194 856 503]);
for j=1:3 % high, medium, low learning
    for i=1:3 % dry, mod, wet
        % set climate direction
        avgChng = i-(4-i); % -2, 0, 2
        
        % set standard deviation
        sigmaStart = 3;
        sigChng = sig_vals(j);
        
        stateMsg = strcat('avgChng = ', num2str(avgChng), ', sigChng = ', num2str(sigChng));
        disp(stateMsg);
        
        % get transition matrices
        T_Precip = synthMatrix_stateSpace(avgChng, sigmaStart, sigChng, ...
            s_P_abs, 0);
        T_Precip_all(:,:,:,i+(j-1)*3) = synthMatrix_stateSpace(avgChng, ...
            sigmaStart, sigChng, s_P_abs, 0);

        % get precipitation path
        for t = 1:N
            % Sample forward distribution given current state
            P_current = s_P_abs(state_ind_P(t));
            [P_over_time{t}] = T2forwardSimTemp(T_Precip, s_P_abs, N, t, P_current, numSamp, false);

            % Lookup MAR and yield for forward distribution
            P_ind = arrayfun(@(x) find(x == s_P_abs), P_over_time{t});

            % Sample next time period
            if j == 1 
                if randGen
                %state_ind_T(t+1) = find(T_over_time{t}(p(t),2)==s_T_abs);
                    state_ind_P(t+1) = find(P_over_time{t}(p(t),2)==s_P_abs);
                end
                if mod(i,3) == 1
                    state_ind_P_dry = state_ind_P;
                elseif mod(i,3) == 2
                    state_ind_P_mod = state_ind_P;
                else
                    state_ind_P_wet = state_ind_P;
                end
            else
                if mod(i,3) == 1
                    state_ind_P = state_ind_P_dry;
                elseif mod(i,3) == 2
                    state_ind_P = state_ind_P_mod;
                else
                    state_ind_P = state_ind_P_wet;
                end
            end
        end

        for t =1:N
            x = t:N+1;
            X=[x,fliplr(x)];
            %     T_p01 = prctile(T_over_time{t},.01);
            %     T_p995 = prctile(T_over_time{t},99.9);
            P_p01 = prctile(P_over_time{t},.01);
            P_p995 = prctile(P_over_time{t},99.9);
            %     MAR_p01 = prctile(MAR_over_time{t},.01);
            %     MAR_p995 = prctile(MAR_over_time{t},99.9);
            %     yield_p01 = prctile(yield_over_time{t},.01);
            %     yield_p995 = prctile(yield_over_time{t},99.9);

            subplot(3,3,i+(j-1)*3);
            Y=[P_p01,fliplr(P_p995)];
            hold on
            if i == 1
                fill(X,Y-P0_abs,clrmp1(t,:), 'LineWidth', 1);
            elseif i == 2
                fill(X,Y-P0_abs,clrmp3(t,:), 'LineWidth', 1);
            else
                fill(X,Y-P0_abs,clrmp2(t,:), 'LineWidth', 1);
            end
            scatter(t,s_P_abs(state_ind_P(t))-P0_abs, 'k', 'MarkerFaceColor', 'k')
            xticks(1:6)
            xticklabels(decades)
            ylabel('mm/month')
            ylim([-12 22])

            if N==5
                % Calc precip using bin discretization
                KLDiv_Precip_Simple(i,:) = CalcKLDivergence(P_over_time, 3, 0, 1e-4, 50);
            end

            KLdiv = KLDiv_Precip_Simple(i,10);
            %title([scenarios{k}, ' (', num2str(KLdiv, '%.3f'), ')'], 'FontSize', 12);
            %ylim([-30 30])
            set(gca,'Units','normalized')
            if t ==1
                yLabelHandle = get( gca ,'YLabel' );
                pos  = get( yLabelHandle , 'position' );
                pos1 = pos - [0.15 0 0];
                set( yLabelHandle , 'position' , pos1 );
            end

            frames(t) = getframe(gcf);
            title([scenarios{i+(j-1)*3}, ' (', num2str(KLdiv, '%.3f'), ')'], 'FontSize', 12);
        end
    end
end
sgtitle('Change in Monthly Precip Predictions in Low to High Learning, Dry to Wet Scenarios (Stdev Chng over Time)');

%% run 100 instances to see how many "work" where the high learning scenarios have higher values
% than the mod and low learning
tic
randGen = true;
sig_vals = [0.6, 0.8, 1];
T_Precip_all = zeros(32, 32, 5, 9);
num = 5;

for j=1:3 % high, medium, low learning
    for i=1:3 % dry, mod, wet
        KLDiv_Precip_Simple = zeros(num, 20);
        % set climate direction
        avgChng = i-(4-i); % -2, 0, 2
        
        % set standard deviation
        sigmaStart = 3;
        sigChng = sig_vals(j);
        
        stateMsg = strcat('avgChng = ', num2str(avgChng), ', sigChng = ', num2str(sigChng));
        disp(stateMsg);
        
        % get transition matrices
        T_Precip = synthMatrix_stateSpace(avgChng, sigmaStart, sigChng, ...
            s_P_abs, 0);
        
        for b=1:num
            % Set time series
            state_ind_P = zeros(1,N+1);
            state_ind_P(1) =  find(P0_abs==s_P_abs);
            p = randi(numSamp,N-1);
            P_over_time = cell(1,N);

            for t = 1:N
                % Sample forward distribution given current state
                P_current = s_P_abs(state_ind_P(t));
                [P_over_time{t}] = T2forwardSimTemp(T_Precip, s_P_abs, N, t, P_current, numSamp, false);
                P_ind = arrayfun(@(x) find(x == s_P_abs), P_over_time{t});

                % Sample next time period
                if j == 1
                    if randGen
                        state_ind_P(t+1) = find(P_over_time{t}(p(t),2)==s_P_abs);
                    end
                    if mod(i,3) == 1
                        state_ind_P_dry(b,:) = state_ind_P;
                    elseif mod(i,3) == 2
                        state_ind_P_mod(b,:) = state_ind_P;
                    else
                        state_ind_P_wet(b,:) = state_ind_P;
                    end
                else
                        if mod(i,3) == 1
                            state_ind_P = state_ind_P_dry(b,:);
                        elseif mod(i,3) == 2
                            state_ind_P = state_ind_P_mod(b,:);
                        else
                            state_ind_P = state_ind_P_wet(b,:);
                        end
                end
            end

            KLDiv_Precip_Simple(b,:) = CalcKLDivergence(P_over_time, 3, 0, 1e-4, 50);


        end
        KLDiv(:,i+(j-1)*3) = KLDiv_Precip_Simple(:,10);
        %stateMsg = ['b = ', num2str(b)];
        %disp(stateMsg);
    end
        toc
end

%% run num instances to see how many "work" where the high learning scenarios have higher values
% than the mod and low learning
% This also calculates the KL divergence values
tic
randGen = true;
% sig_vals = [0.6, 0.8, 1];
% T_Precip_all = zeros(32, 32, 5, 9);
num = 5;

for j=1:3 % high, medium, low learning
    for i=1:3 % dry, mod, wet
        KLDiv_Precip_Simple = zeros(num, 20);
        
        stateMsg = strcat('j = ', num2str(j), ', i = ', num2str(i));
        disp(stateMsg);
        
        % get transition matrices
        load(files2{i+(j-1)*3}, 'T_Precip');
        
        for b=1:num
            % Set time series
            state_ind_P = zeros(1,N+1);
            state_ind_P(1) =  find(P0_abs==s_P_abs);
            p = randi(numSamp,N-1);
            P_over_time = cell(1,N);

            for t = 1:N
                % Sample forward distribution given current state
                P_current = s_P_abs(state_ind_P(t));
                [P_over_time{t}] = T2forwardSimTemp(T_Precip, s_P_abs, N, t, P_current, numSamp, false);
                P_ind = arrayfun(@(x) find(x == s_P_abs), P_over_time{t});

                % Sample next time period
                if j == 1
                    if randGen
                        state_ind_P(t+1) = find(P_over_time{t}(p(t),2)==s_P_abs);
                    end
                    if mod(i,3) == 1
                        state_ind_P_dry(b,:) = state_ind_P;
                    elseif mod(i,3) == 2
                        state_ind_P_mod(b,:) = state_ind_P;
                    else
                        state_ind_P_wet(b,:) = state_ind_P;
                    end
                else
                        if mod(i,3) == 1
                            state_ind_P = state_ind_P_dry(b,:);
                        elseif mod(i,3) == 2
                            state_ind_P = state_ind_P_mod(b,:);
                        else
                            state_ind_P = state_ind_P_wet(b,:);
                        end
                end
            end

            KLDiv_Precip_Simple(b,:) = CalcKLDivergence(P_over_time, 3, 0, 1e-4, 50);


        end
        KLDiv(:,i+(j-1)*3) = KLDiv_Precip_Simple(:,10);
        %stateMsg = ['b = ', num2str(b)];
        %disp(stateMsg);
    end
        toc
end

% code to count number of runs where high learning greater than mod and low,
% and mod learning > low learning
count_dry = zeros(num, 1);
count_mod = zeros(num, 1);
count_wet = zeros(num, 1);

% count the number of instances where high learning > medium learning > low
% learning
for i=1:length(count_dry)
    if (KLDiv(i,1) > KLDiv(i,4) && KLDiv(i,4) > KLDiv(i,7))
        count_dry(i) = 1;
    end
    
    if (KLDiv(i,2) > KLDiv(i,5) && KLDiv(i,5) > KLDiv(i,8))
        count_mod(i) = 1;
    end
    
    if (KLDiv(i,3) > KLDiv(i,6) && KLDiv(i,6) > KLDiv(i,9))
        count_wet(i) = 1;
    end
    
end

count_sum(1) = sum(count_dry);
count_sum(2) = sum(count_mod);
count_sum(3) = sum(count_wet);

save('KLDiv_Precip_count')

%% 1. Take KLdiv_all_22June2021 results and count number of dry, mod, wet instances
% where high learning > med learning and med learning > low learning for
% precip

% load data
load('KLdiv_all_22June2021');

KLDiv_Precip = squeeze(KLDiv_Precip_Simple(:,10,:));

% code to count number of runs where high learning greater than mod and low,
% and mod learning > low learning
count_dry = zeros(numRuns, 1);
count_mod = zeros(numRuns, 1);
count_wet = zeros(numRuns, 1);

for i=1:numRuns
    if (KLDiv_Precip(i,1) > KLDiv_Precip(i,4) && KLDiv_Precip(i,4) > KLDiv_Precip(i,7))
        count_dry(i) = 1;
    end
    
    if (KLDiv_Precip(i,2) > KLDiv_Precip(i,5) && KLDiv_Precip(i,5) > KLDiv_Precip(i,8))
        count_mod(i) = 1;
    end
    
    if (KLDiv_Precip(i,3) > KLDiv_Precip(i,6) && KLDiv_Precip(i,6) > KLDiv_Precip(i,9))
        count_wet(i) = 1;
    end
end

count_sum(1) = sum(count_dry);
count_sum(2) = sum(count_mod);
count_sum(3) = sum(count_wet);

%% 2. Make boxplots of KL divergence results for precip, MAR, shortage

C = {[0.6350, 0.0780, 0.1840], [0.8500, 0.3250, 0.0980], [0.4660, 0.6740, 0.1880],...
    [0, 0.4470, 0.7410], [0.4940, 0.1840, 0.5560]};
scenarios = {'Dry, High', 'Mod, High', 'Wet, High',...
    'Dry, Med', 'Mod, Med', 'Wet, Med',...
    'Dry, Low', 'Mod, Low', 'Wet, Low'};

%scenarios = cellfun(@(x) strrep(x, ' ', '\newline'), scenarios, 'UniformOutput', false);

scenarios_shortened = {'Dry,\newlineHigh', 'Mod,\nHigh', 'Wet, \newlineHigh', ...
    'Dry, \newlineMed', 'Mod, \newlineMed', 'Wet, \newlineMed', ...
    'Dry, \newlineLow', 'Mod, \newlineLow', 'Wet, \newlineLow'};

figure('Position', [385 105 685 575]);
subplot(3,1,1)
b1 = boxplot(KLDiv_Precip, 'width', 0.6, 'colors', C{1}, 'symbol', '');
ylim([0 6]);
xlim([0.5 9.5]);
xticklabels(scenarios);
ylabel('KL Divergence');
set(b1, 'LineWidth', 1.5);
set(b1(:,1:3:7), 'Color', clrmp1(3,:));
set(b1(:,2:3:8), 'Color', clrmp3(3,:));
set(b1(:,3:3:9), 'Color', clrmp2(3,:));
title('KL Divergence for Precipitation');

subplot(3,1,2)
KLDiv_MAR = squeeze(KLDiv_MAR_Log_Opt(:,10,:));
b2 = boxplot(KLDiv_MAR, 'width', 0.6, 'colors', C{1}, 'symbol', '');
ylim([0 6]);
xlim([0.5 9.5]);
xticklabels(scenarios);
ylabel('KL Divergence');
set(b2, 'LineWidth', 1.5);
set(b2(:,1:3:7), 'Color', clrmp1(3,:));
set(b2(:,2:3:8), 'Color', clrmp3(3,:));
set(b2(:,3:3:9), 'Color', clrmp2(3,:));
title('KL Divergence for Mean Annual Runoff');

subplot(3,1,3)
KLDiv_Yield = squeeze(KLDiv_Yield_Log_Opt(:,10,:));
b3 = boxplot(KLDiv_Yield, 'width', 0.6, 'colors', C{1}, 'symbol', '');
ylim([0 6]);
xlim([0.5 9.5]);
xticklabels(scenarios);
xlabel('Scenario');
ylabel('KL Divergence');
set(b3, 'LineWidth', 1.5);
set(b3(:,1:3:7), 'Color', clrmp1(3,:));
set(b3(:,2:3:8), 'Color', clrmp3(3,:));
set(b3(:,3:3:9), 'Color', clrmp2(3,:));
%set(gca,'xticklabel',scenarios, 'FontSize', 10);
title('KL Divergence for Shortage');

% title
text(3, 29.5, 'KL Divergence for Different Scenarios', 'FontSize', 14)

%% Test- looking at different percentiles of kl divergence values for all 3 metrics over time

prctiles = [10, 50, 90];
figure('Position', [140 40 1075 650]);
labs = {'Precip ', 'Mean Annual Runoff', 'Shortage'};
for a=1:3
for b=1:length(prctiles)
    
    for j=1:20
        for k=1:9
            if a==1
                KLDiv(j,k) = prctile(KLDiv_Precip_Simple(:,j,k), prctiles(b));
            elseif a==2
                KLDiv(j,k) = prctile(KLDiv_MAR_Log_Opt(:,j,k), prctiles(b));
            elseif a==3
                KLDiv(j,k) = prctile(KLDiv_Yield_Log_Opt(:,j,k), prctiles(b));
            end
        end
    end
    order = [1 5 8 10];
    colors = [clrmp1(3,:); clrmp3(3,:); clrmp2(3,:)];
    lineStyle = {'-o', '-x', '-.x'};
    
    subplot(3,3,b+(a-1)*3);
    for i=1:3
        p1(i,:) = plot(KLDiv(order,1+(i-1)*3), lineStyle{i},'LineWidth', 1.5, 'Color', clrmp1(3,:));
        hold on
        p2(i,:) = plot(KLDiv(order,2+(i-1)*3), lineStyle{i},'LineWidth', 1.5, 'Color', clrmp3(3,:));
        p3(i,:) = plot(KLDiv(order,3+(i-1)*3), lineStyle{i},'LineWidth', 1.5, 'Color', clrmp2(3,:));
        disp(i);

    end
    xticks(1:1:4);
    xticklabels(decades(3:end));
    xlabel('Time');
    ylabel('KL Divergence');
    %ylim([0 4]);
    set(gca, 'YScale', 'log')
    ylim([0 4]);
    if b==1 && a==1
        legend([p1(1,:) p2(1,:) p3(1,:) p1(2,:) p2(2,:) p3(2,:) p1(3,:) p2(3,:) p3(3,:)], scenarios,...
            'location', 'northwest', 'FontSize', 7);
        legend('boxoff');
    end
    title([labs{a}, ': ', num2str(prctiles(b)), 'th Percentile']);
end
end
sgtitle('KL Divergence Percentiles for Different Prediction Years from 1990 and Metrics');

%% 3b. Try taking averages of information time periods data, e.g. (1990-2010I)
% --> 2030, 2050, 2070, 2090 results, (2010-2030I) --> avg(2050, 2070,
% 2090)

for b=1:9
    KLDiv_Prec(b,1) = mean(KLDiv_Precip_Simple(:,1:4,b), 'all');
    KLDiv_Prec(b,2) = mean(KLDiv_Precip_Simple(:,11:13,b), 'all');
    KLDiv_Prec(b,3) = mean(KLDiv_Precip_Simple(:,17:18,b), 'all');
    KLDiv_Prec(b,4) = mean(KLDiv_Precip_Simple(:,20,b), 'all');
    
    KLDiv_MAR(b,1) = mean(KLDiv_MAR_Log_Opt(:,1:4,b), 'all');
    KLDiv_MAR(b,2) = mean(KLDiv_MAR_Log_Opt(:,11:13,b), 'all');
    KLDiv_MAR(b,3) = mean(KLDiv_MAR_Log_Opt(:,17:18,b), 'all');
    KLDiv_MAR(b,4) = mean(KLDiv_MAR_Log_Opt(:,20,b), 'all');
    
    KLDiv_Yield(b,1) = mean(KLDiv_Yield_Log_Opt(:,1:4,b), 'all');
    KLDiv_Yield(b,2) = mean(KLDiv_Yield_Log_Opt(:,11:13,b), 'all');
    KLDiv_Yield(b,3) = mean(KLDiv_Yield_Log_Opt(:,17:18,b), 'all');
    KLDiv_Yield(b,4) = mean(KLDiv_Yield_Log_Opt(:,20,b), 'all');
end

colors = [clrmp1(3,:); clrmp3(4,:); clrmp2(3,:)];
lineStyle = {'-o', '-x', '-.o'};
decadeLearn = {'1990-2010', '2010-2030', '2030-2050', '2050-2070', '2070-2090'};

scenarios_shortened = {'Dry, High', 'Mod, High', 'Wet, High', ...
    'Dry, Med', 'Mod, Med', 'Wet, Med', ...
    'Dry, Low', 'Mod, Low', 'Wet, Low'};

figure;
subplot(3,1,1)
for a=1:3 % high, medium, low learning
    for b=1:3 % dry, mod, wet
        p1(b+(a-1)*3,:) = plot(transpose(KLDiv_Prec(b+(a-1)*3,:)), lineStyle{a}, 'Color', ...
            colors(b,:), 'LineWidth', 1.5);
        hold on
    end
end
xticks(1:1:4);
xticklabels(decadeLearn);
xlabel('Learning Time Period');
ylabel('KL Divergence');
ylim([0 1]);
title('KL Divergence for Precipitation');
legend([p1], scenarios_shortened, 'location', 'northwest', 'FontSize', 7,...
    'NumColumns', 2);
legend('boxoff');

subplot(3,1,2)
for a=1:3 % high, medium, low learning
    for b=1:3 % dry, mod, wet
        p1(b+(a-1)*3,:) = plot(transpose(KLDiv_MAR(b+(a-1)*3,:)), lineStyle{a}, 'Color', ...
            colors(b,:), 'LineWidth', 1.5);
        hold on
    end
end
xticks(1:1:4);
xticklabels(decadeLearn);
xlabel('Learning Time Period');
ylabel('KL Divergence');
ylim([0 1]);
title('KL Divergence for Mean Annual Runoff');

subplot(3,1,3)
for a=1:3 % high, medium, low learning
    for b=1:3 % dry, mod, wet
        p1(b+(a-1)*3,:) = plot(transpose(KLDiv_Yield(b+(a-1)*3,:)), lineStyle{a}, 'Color', ...
            colors(b,:), 'LineWidth', 1.5);
        hold on
    end
end
xticks(1:1:4);
xticklabels(decadeLearn);
xlabel('Learning Time Period');
ylabel('KL Divergence');
ylim([0 1]);
title('KL Divergence for Shortage');

sgtitle('KL Divergence as a Metric for Learning Averaged by Information Period');

%% 3c. Try taking averages of information time periods data, e.g. (1990-2010I)
% --> 2030 results, (2010-2030I) --> 2050, ...
% no averaging

for b=1:9
    KLDiv_Prec(b,1) = mean(KLDiv_Precip_Simple(:,1,b), 'all');
    KLDiv_Prec(b,2) = mean(KLDiv_Precip_Simple(:,11,b), 'all');
    KLDiv_Prec(b,3) = mean(KLDiv_Precip_Simple(:,17,b), 'all');
    KLDiv_Prec(b,4) = mean(KLDiv_Precip_Simple(:,20,b), 'all');
    
    KLDiv_MAR(b,1) = mean(KLDiv_MAR_Log_Opt(:,1,b), 'all');
    KLDiv_MAR(b,2) = mean(KLDiv_MAR_Log_Opt(:,11,b), 'all');
    KLDiv_MAR(b,3) = mean(KLDiv_MAR_Log_Opt(:,17,b), 'all');
    KLDiv_MAR(b,4) = mean(KLDiv_MAR_Log_Opt(:,20,b), 'all');
    
    KLDiv_Yield(b,1) = mean(KLDiv_Yield_Log_Opt(:,1,b), 'all');
    KLDiv_Yield(b,2) = mean(KLDiv_Yield_Log_Opt(:,11,b), 'all');
    KLDiv_Yield(b,3) = mean(KLDiv_Yield_Log_Opt(:,17,b), 'all');
    KLDiv_Yield(b,4) = mean(KLDiv_Yield_Log_Opt(:,20,b), 'all');
end

colors = [clrmp1(3,:); clrmp3(4,:); clrmp2(3,:)];
lineStyle = {'-o', '-x', '-.o'};
decadeLearn = {'2030P (1990-2010I)', '2050P (2010-2030I)', '2070P (2030-2050I)', '2090P (2050-2070I)'};

scenarios_shortened = {'Dry, High', 'Mod, High', 'Wet, High', ...
    'Dry, Med', 'Mod, Med', 'Wet, Med', ...
    'Dry, Low', 'Mod, Low', 'Wet, Low'};

figure;
subplot(3,1,1)
for a=1:3 % high, medium, low learning
    for b=1:3 % dry, mod, wet
        p1(b+(a-1)*3,:) = plot(transpose(KLDiv_Prec(b+(a-1)*3,:)), lineStyle{a}, 'Color', ...
            colors(b,:), 'LineWidth', 1.5);
        hold on
    end
end
xticks(1:1:4);
xticklabels(decadeLearn);
xlabel('Learning Time Period');
ylabel('KL Divergence');
ylim([0 1.2]);
title('KL Divergence for Precipitation');
legend([p1], scenarios_shortened, 'location', 'northwest', 'FontSize', 7,...
    'NumColumns', 2);
legend('boxoff');

subplot(3,1,2)
for a=1:3 % high, medium, low learning
    for b=1:3 % dry, mod, wet
        p1(b+(a-1)*3,:) = plot(transpose(KLDiv_MAR(b+(a-1)*3,:)), lineStyle{a}, 'Color', ...
            colors(b,:), 'LineWidth', 1.5);
        hold on
    end
end
xticks(1:1:4);
xticklabels(decadeLearn);
xlabel('Learning Time Period');
ylabel('KL Divergence');
ylim([0 1.2]);
title('KL Divergence for Mean Annual Runoff');

subplot(3,1,3)
for a=1:3 % high, medium, low learning
    for b=1:3 % dry, mod, wet
        p1(b+(a-1)*3,:) = plot(transpose(KLDiv_Yield(b+(a-1)*3,:)), lineStyle{a}, 'Color', ...
            colors(b,:), 'LineWidth', 1.5);
        hold on
    end
end
xticks(1:1:4);
xticklabels(decadeLearn);
xlabel('Learning Time Period');
ylabel('KL Divergence');
ylim([0 1.2]);
title('KL Divergence for Shortage');

sgtitle('KL Divergence as a Metric for Learning by Information Period');

%% Test- Compare sample size of 2000 vs 500 for 2 scenarios: Dry, high and 
% dry, medium (6/28)

load('KLdiv_all_22June2021');
KLDiv_DryHigh_500(:,1) = KLDiv_Precip_Simple(:,10,1);
KLDiv_DryHigh_500(:,2) = KLDiv_MAR_Log_Opt(:,10,1);
KLDiv_DryHigh_500(:,3) = KLDiv_Yield_Log_Opt(:,10,1);

KLDiv_DryMed_500(:,1) = KLDiv_Precip_Simple(:,10,4);
KLDiv_DryMed_500(:,2) = KLDiv_MAR_Log_Opt(:,10,4);
KLDiv_DryMed_500(:,3) = KLDiv_Yield_Log_Opt(:,10,4);

load('KLdiv_all_28June2021');
KLDiv_DryHigh_2000(:,1) = KLDiv_Precip_Simple(:,10,1);
KLDiv_DryHigh_2000(:,2) = KLDiv_MAR_Log_Opt(:,10,1);
KLDiv_DryHigh_2000(:,3) = KLDiv_Yield_Log_Opt(:,10,1);

KLDiv_DryMed_2000(:,1) = KLDiv_Precip_Simple(:,10,4);
KLDiv_DryMed_2000(:,2) = KLDiv_MAR_Log_Opt(:,10,4);
KLDiv_DryMed_2000(:,3) = KLDiv_Yield_Log_Opt(:,10,4);

%%
figure;
pos1 = 1;
pos2 = 1.5;
metrics = {'Precip', 'MAR', 'Shortage'};
for m=1:3
    subplot(2, 3,m);
    b1 = boxplot(KLDiv_DryHigh_500(:,m), 'width', 0.4, 'Colors', cmap1(1,:), ...
        'position', pos1);
    hold on
    b2 = boxplot(KLDiv_DryHigh_2000(:,m), 'width', 0.4, 'Colors', cmap1(2,:), ...
        'position', pos2);
    set(b1, 'LineWidth', 2);
    set(b2, 'LineWidth', 2);
    xlim([0.5 2]);
    xticks(0.5:0.5:2.5);
    xticklabels({'', '500', '2000', ''});
    title(metrics{m});
    
    subplot(2, 3,m+3);
    b3 = boxplot(KLDiv_DryMed_500(:,m), 'width', 0.4, 'Colors', cmap1(1,:), ...
        'position', pos1);
    hold on
    b4 = boxplot(KLDiv_DryMed_2000(:,m), 'width', 0.4, 'Colors', cmap1(2,:), ...
        'position', pos2);
    set(b3, 'LineWidth', 2);
    set(b4, 'LineWidth', 2);
    xlim([0.5 2]);
    xticks(0.5:0.5:2.5);
    xticklabels({'', '500', '2000', ''});
    title(metrics{m});
end

text(-4, 10.5, 'KL Divergence Comparison for 500 and 2000 Instances for Dry, High (top) and Dry, Med (bottom)',...
    'FontSize', 12);

