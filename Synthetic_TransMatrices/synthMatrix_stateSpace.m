function [T_Precip] = synthMatrix_stateSpace(avgChng, sigma, sigChng, actualP, constTime)
% synthMatrix_stateSpace: A function that calculates transition matrices
% for N=5 time periods
% Inputs:
%   avgChng: Average change in precip (or temp) from time period N to N+1
%   sigma: The standard deviation around the mean
%   sigChng: The change in standard deviation (fraction) over each time
%       period
%   actualP: The range of precip (or temp) values
%   constTime: A boolean for if the transition matrix changes over time
%       periods
% Outputs:
%   T_Precip: Transition matrices for precipitation (or temperature)

%avgChng = -avgChng; % wet scenarios should have negative value w/ this line
N=5;
sz = length(actualP);

T_Precip=zeros(sz,sz,N);

if length(sigChng) == 1
    sigChng = repmat(sigChng, [N 1]);
elseif length(sigChng) ~= N
    error('error in length sigChng');
end

if length(avgChng) == 1
    avgChng = repmat(avgChng, [N 1]);
elseif length(avgChng) ~= N
    error('error in length avgChng');
end

if constTime % TMs constant in time
    % calculate single transition matrix
    probP_single = createTM(avgChng, sigma, actualP);
    for i=1:5
        T_Precip(:,:,i)=probP_single(:,:);
    end
else % stdev for TMs changes over time periods (increases if sigChng > 1, 
     % decreases if sigChng < 1)
    for i=1:N
        if i == 1
            sigmaIn = sigma;
        else
            sigmaIn = sigmaIn * sigChng(i);
        end
        disp(sigmaIn);
        T_Precip(:,:,i) = createTM(avgChng(i), sigmaIn, actualP);
    end
end

end 