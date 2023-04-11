%% KL Divergence Post Processing: This is an alternative to just running 
% the Bayesian Quant Learning file, and to instead take X number of
% instances from the simulation and to calculate the KL divergence values
% for them. Can run on local drive or Sherlock.
% August 2022

% Notes: Run 1x for high learning and 1x for low learning
%% Setup

% Set Project root folder and Add subfolders to path; runs either on desktop 
% or on a cluster using SLURM queueing system 
if ~isempty(getenv('SLURM_JOB_ID'))
    projpath = '/home/users/jskerker/Mwache_Dam';
else
    projpath = '/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Mwache_Dam';
    
end
addpath(genpath(projpath))

jobid = getenv('SLURM_JOB_ID');

% Get date for file name when saving results 
datetime=datestr(now);
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_');%Replace space with underscore

%% Parameters

%clear all; close all;

learning = {'High', 'Low'};
climate = {'Dry', 'Wet'};
numSamp = 25000;
decades = { '1990', '2010', '2030', '2050', '2070', '2090'};

%% For loop to run and calculate KL divergence
numRuns = 1000;
rndSamps = randi(10000, [numRuns 1]);
tic

cd(strcat(projpath, '/Multiflex_expansion_SDP/ForSherlock_Aug2022'));
for b=1:2 % policy

    stateMsg = strcat('policy = ', learning{b});
    disp(stateMsg);
    
    % load simulation file
    fileName = strcat('OptimalPolicies_', learning{b}, '_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat'); %strcat('Simulation_', policy, '_Policy_', combo{c+(b-1)*2}, '.mat');
    load(fileName);
    
    % load shortages using the flex unexpanded size
    unmet_dom = shortageVol(:,:,2);
    
    % for loop to calculate KLD for numRuns
    for n=1:numRuns
        state_ind_P = zeros(1,N+1); % state_ind_P = zeros(1,N)
        state_ind_T = zeros(1,N); % state_ind_T = zeros(1,N)
        state_ind_P(1) =  find(climParam.P0_abs==s_P_abs);
        %state_ind_T(1) = find(climParam.T0_abs==s_T_abs);
        state_ind_P(2:end) = P_state(rndSamps(n),:)-(s_P_abs(1)-1);
        state_ind_T(1:end) = find(T_state(rndSamps(n),:) == s_T_abs); %T_state(rndSamps(n),:)-(s_T_abs(1)-1);
        randGen = false;
        
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
            
        end
        
        % Calculate KL Divergence
        % Specify calculation method and input parameters
        param.CalcMethod = 2; % 1 = Simple, 2 = Bin Counting, 3 = BC + Zero + BoxCox
        param.NumBins = 50;
        param.Const = 1*10^-4; % Account for zeros by adding a small value
        param.Transform = 0; % 0 = no transform, 1 = boxcox, 2 = log
        
        % Calc precip using bin discretization
        KLDiv_Precip_Simple(n,:) = CalcKLDivergence(P_over_time, 3, 0, param.Const, param.NumBins);
        
        % Log Transform, Optimal Bins
        %KLDiv_Precip_Log(n,:,m) = CalcKLDivergence(P_over_time, 2, 2, param.Const, param.NumBins);
        KLDiv_MAR_Log_Opt(n,:) = CalcKLDivergence(MAR_over_time, 2, 2, param.Const, param.NumBins);
        KLDiv_Yield_Log_Opt(n,:) = CalcKLDivergence(yield_over_time, 2, 2, param.Const, param.NumBins);
        
        for d=1:size(state_ind_T, 2)
            state_ind_MAR(n,d) = MAR(state_ind_T(d), state_ind_P(d), 1);
            state_ind_Yield(n,d) = unmet_dom(state_ind_T(d), state_ind_P(d));
        end
        
        stateMsg = strcat('n= ', num2str(n));
        disp(stateMsg);
    end
    
    % resave data
    save(fileName);

    toc;
    %cd ..
end