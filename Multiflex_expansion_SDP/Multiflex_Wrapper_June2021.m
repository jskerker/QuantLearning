%% Wrapper Function for Multiflex KL Divergence Tests
% June 2021
% For one set of transition matrices, do the following:
%   1. Find the optimal flexible dam size
%   2. Find the optimal static dam size
%   3. Run the forward simulation with the optimal flex/static sizes

tic
clear all;
close all;
scen = 5;

% 0. Load transition matrix scenario data

TM_scenarios = {'wet1', 'wet2', 'wet4', 'dry1', 'dry2', 'dry4', 'mod1', 'mod2', 'mod4'};
for d=0.01:0.01:0.02
for f=1
for k=5
    cd('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/SDP/TMs_Test_22_Jun_2021_16_02_34');
    TM_filename = strcat('T_Temp_Precip_',string(TM_scenarios{k}),'.mat');
    TM = strcat('T_Temp_Precip_',string(TM_scenarios{k}));
    load(TM_filename);

    % 1. Find the optimal flexible dam size
    cd('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Operations/Fletcher_2019_Learning_Climate/SDP');
    bestVal_flex = inf;

    for j=50:10:90
        for h=1:2
            for g=1:(7-2*h)
                stateMsg = strcat('j=', num2str(j), ', g=', num2str(g), ', h=', ...
                    num2str(h));
                disp(stateMsg)
                x(1) = 1; % optParam.optFlex
                x(2) = j; % optParam.smallCap
                x(3) = g; % optParam.numFlex
                x(4) = h*10; % optParam.flexIncr
                x(5) = 50; % optParam.staticCap
                x(6) = false; % runParam.forwardSim
                x(7) = f/10; % costParam.PercFlexExp
                x(8) = d; % costParam.discountrate

                run('multiflex_sdp_climate_StaticFlex');
                val = V(1, 12, 1, 1);
                if val < bestVal_flex
                    bestVal_flex = val;
                    allV_flex = V;
                    bestAct_flex = x;
                    allX_flex = X;

                end
            end
        end
    end
    % old_path = '/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Bayesian_Quant_Learning';
    % cd(old_path);
    % mkdir(TM);
    % new_path = strcat(old_path, '/', TM);
    % cd(new_path);
    % file_name = strcat('BestFlex_', TM);
    % save(file_name);
    toc

    %%
    % 2. Find the optimal static dam size
    bestVal_static = inf;

    for j=50:10:100
            stateMsg = strcat('j=', num2str(j));
            disp(stateMsg)
            x(1) = 2; % optParam.optFlex
            x(2) = 50; % optParam.smallCap
            x(3) = 0; % optParam.numFlex
            x(4) = 0; % optParam.flexIncr
            x(5) = j; % optParam.staticCap
            x(6) = false; % runParam.forwardSim
            x(7) = f/10; % costParam.PercFlexExp
            x(8) = d; % costParam.discountrate

            run('multiflex_sdp_climate_StaticFlex');
            val = V(1, 12, 1, 1);
            if val < bestVal_static
                bestVal_static = val;
                allV_static = V;
                bestAct_static = x;
                allX_static = X;

            end
    end

    % file_name = strcat('BestStatic_', TM);
    % save(file_name);

    %%
    % 3. Run the SDP and forward simulation with the optimal dam sizes

    % get optimal values
    x(1) = 0; % optParam.optFlex
    x(2) = bestAct_flex(2); % optParam.smallCap
    x(3) = bestAct_flex(3); % optParam.numFlex
    x(4) = bestAct_flex(4); % optParam.flexIncr
    x(5) = bestAct_static(5); % optParam.staticCap
    x(6) = true; % runParam.forwardSim
    x(7) = f/10; % costParam.PercFlexExp
    x(8) = d; % costParam.discountrate

    run('multiflex_sdp_climate_StaticFlex');
    file_name = strcat('BestFlexStatic_', TM, num2str(f), 'pf_', num2str(100*d), 'd');
    save(file_name)

    toc
end
end
end