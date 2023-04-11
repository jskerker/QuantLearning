function [unmet_dom] = storageSize2domShortage(storage, optReservoir, N, M_T_abs, M_P_abs)

% set parameters
domShortage = 1;
setPathway = 'RCP85';


% get unmet_dom amounts for shortage
unmet_dom = NaN(M_T_abs, M_P_abs, length(storage), N);
if optReservoir % DDP calculated shortage costs
    for i=1:length(storage)
        s_state = string(storage(i));
        s_state_filename = strcat('ddp_shortage_cost_domCost',string(domShortage),'_',string(setPathway),'_s',s_state,'.mat');
        % test by Jenny 06/14/2021
        addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Operations/Fletcher_2019_Learning_Climate/SDP/post_process_opt_reservoir_results');
        unmet_dom_Dir = load(s_state_filename,'unmet_dom');
        unmet_dom_s_state = unmet_dom_Dir.unmet_dom;
        %shortageCost_s_state = load(s_state_filename,'shortageCost').shortageCost;
        % back to Keani's version
        unmet_dom(:,:,i,1) = unmet_dom_s_state;
    end
else % greedy algorithm calculated shortage costs
    for i=1:length(storage)
        s_state = string(storage(i));
        s_state_filename = strcat('nonopt_shortage_cost_domCost',string(domShortage),'_',string(setPathway),'_s',s_state,'.mat');
        % test by Jenny 06/14/2021
        addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Operations/Fletcher_2019_Learning_Climate/SDP/post_process_nonopt_reservoir_results');
        unmet_dom_Dir = load(s_state_filename,'unmet_dom');
        unmet_dom_s_state = unmet_dom_Dir.unmet_dom;
        %shortageCost_s_state = load(s_state_filename,'shortageCost').shortageCost;
        % back to Keani's version
        unmet_dom(:,:,i,1) = unmet_dom_s_state;
    end
end
