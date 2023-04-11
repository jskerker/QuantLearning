%% Wrapper Function for Multiflex Optimization and Simulation
% July 2022
% For one set of transition matrices, do the following:
%   1. Find the optimal flexible dam size
%   2. Find the optiml static dam size
%   3. Run the forward simulation with the optimal flex/static sizes

%% Setup
clear all;
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
datetime=date;
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_')%Replace space with underscore

%% Step 0. Load learning scenario transition matrix data
learning_scen = {'High', 'Low'}; %, 'Med'
climate_scen = {'Wet', 'Mod', 'Dry'};
storageAll = 50:10:150;

m = 1;
%% 
for m=1:length(learning_scen)
     % import transition matrix data-- UPDATE THIS BASED ON FILE LOCATION
     % AND FILE
     cd('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Mwache_Dam/Synthetic_TransMatrices/Bayes_July2022');
     TM_filename = strcat('T_Temp_Precip_V2_',string(learning_scen{m}), '_July2022_Bayes','.mat');
     TM = strcat('T_Temp_Precip_',string(learning_scen{m}));
     load(TM_filename);
     
     % UPDATE THIS BASED ON WHAT YOU WANT THE FILENAME TO BE
     scenName = '3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6'; 
     

    % Step 1. Find the optimal flexible dam size
    bestVal_flex = inf;

    for j=50:10:140 % initial unexpanded dam sizes
        for h=1%:5 %2
            for g=1:5
                stateMsg = strcat('m=', num2str(m), 'j=', num2str(j), ', g=', ...
                    num2str(g), ', h=', num2str(h));
                disp(stateMsg);
                
                  % this piece adds constraints on the flexible dam designs
                  if (j+h*10*g) > 150
                      disp('Flex design surpasses max capacity');
                  %elseif (j+h*10*g) < ceil(1.2*j/10)*10 % if false, then this combination is ok
                  %if or((j*1.25) > (j+h*10*g), (j*1.6) < (j+h*10*g)) % if false, then this combination is ok
                  %elseif (j*1.6) < (j+h*10*g)
                  %  disp('Flex size surpasses 160% initial capacity');
                    %disp('Flex design max expansion less than 30% of initial cap'); %50% of initial capacity');
                   %elseif (j+h*10*g) ~= 150 & (j+h*10*g) ~= ceil(1.5*j/10)*10
                     %  disp('Flex design max expansion not 150 MCM or less than 150% of initial cap');
                        
                  else %if (j*1.3) >= (j+h*10*g)
                
                    x(1) = 1; % optParam.optFlex
                    x(2) = j; % optParam.smallCap
                    x(3) = g; % optParam.numFlex
                    x(4) = h*10; % optParam.flexIncr 
                    x(5) = 50; % optParam.staticCap
                    x(6) = false; % runParam.forwardSim
                    x(7) = true; % runParam.runSDP
                    % UPDATE THESE PARAMS BASED ON DISCOUNT
                    % RATE/ASSUMPTIONS
                    x(8) = 0.03; % costParam.discountrate
                    x(9) = 0.0; % costParam.PercFlex % .075
                    x(10) = 0.5; % costParam.PercFlexExp % .15
                    % 3% params, flex design: .075, 0.15, 0% params: 0, 0.25 (or 0.5)
                    x(11) = 6e-6; % cPrime: 3% params- 6e-6; 0% params- 1.5e-6

                    run('multiflex_sdp_climate_StaticFlex_DetT_StateSpace');
                    P0 = find(s_P_abs == 77)
                    val = V(1, P0, 1, 1);
                    if val < bestVal_flex
                        bestVal_flex = val;
                        allV_flex = V;
                        bestAct_flex = x;
                        allX_flex = X;
                        allV_flex_short = Vs;
                        allV_flex_dam = Vd;
                    end
                end
            end
        end
    end

    %% 2. Find the optimal static dam size
    bestVal_static = inf;

    for j=50:10:150
            stateMsg = strcat('j=', num2str(j));
            disp(stateMsg)
            x(1) = 2; % optParam.optFlex: choose 2 for static design
            x(2) = 50; % optParam.smallCap
            x(3) = 0; % optParam.numFlex
            x(4) = 0; % optParam.flexIncr
            x(5) = j; % optParam.staticCap
            x(6) = false; % runParam.forwardSim
            x(7) = true; % runParam.runSDP
            % UPDATE THESE PARAMS BASED ON DISCOUNT
            % RATE/ASSUMPTIONS
            x(8) = 0.03; % costParam.discountrate
            x(9) = 0.0; % costParam.PercFlex % .075
            x(10) = 0.5; % costParam.PercFlexExp % .15
            x(11) = 6e-6; % cPrime: 3% params- 6e-6; 0% params- 1.5e-6

            run('multiflex_sdp_climate_StaticFlex_DetT_StateSpace');
            val = V(1, P0, 1, 1);
            if val < bestVal_static
                bestVal_static = val;
                allV_static = V;
                bestAct_static = x;
                allX_static = X;
                allV_static_short = Vs;
                allV_static_dam = Vd;
            end
    end
    file_name = strcat('ExpCosts_', learning_scen{m}, '_', num2str(x(8)*100), ...
        'DR');
    save(file_name, 'allV_static_short', 'allV_static', 'allV_static_dam', ...
        'allV_flex_short', 'allV_flex', 'allV_flex_dam');

    %% 3. Run the SDP with the optimal dam sizes from steps 1 and 2

    % get optimal values
    x(1) = 0; % optParam.optFlex
    x(2) = bestAct_flex(2); % optParam.smallCap
    x(3) = bestAct_flex(3); % optParam.numFlex
    x(4) = bestAct_flex(4); % optParam.flexIncr
    x(5) = bestAct_static(5); % optParam.staticCap
    x(6) = true; %false; % runParam.forwardSim
    x(7) = true; % runParam.runSDP
    % UPDATE THESE PARAMS BASED ON DISCOUNT
    % RATE/ASSUMPTIONS
    x(8) = 0.03; % costParam.discountrate
    x(9) = 0.0; % costParam.PercFlex
    x(10) = 0.5; % costParam.PercFlexExp
    x(11) = 6e-6; % cPrime: 3% params- 6e-6; 0% params- 1.5e-6

    run('multiflex_sdp_climate_StaticFlex_DetT_StateSpace');
    location = strcat(projpath, '/Multiflex_expansion_SDP/Results.nosync');
    cd(location)
    new_folder = strcat(learning_scen{m}, '_learning_scenario');
    cd(new_folder);
    file_name = strcat('OptimalPolicies_', num2str(learning_scen{m}), '_', scenName, '_', datetime); %, '_disc', num2str(d*100));
    save(file_name);
    
end