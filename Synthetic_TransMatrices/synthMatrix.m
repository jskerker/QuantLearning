function [T_Precip] = synthMatrix(avgChng, sigma, constTime)
avgChng = -avgChng; % wet scenarios should have negative value w/ this line
actualP = 66:1:97; %range of precip values
N=1:5;

% calculate the likelihood following a normal distribution
in = zeros(32, 32);
for i=1:32
    in(i,:) = normpdf(actualP, actualP(i)+avgChng, sigma);
end
likeP = reshape(in, 1, []);

% calculate prior assuming uniform distribution
pP = reshape(repmat(1, 32), 1, []);

% calculate posterior
probP = pP .* likeP;
probP_scen(:,:) = reshape(probP, 32, 32);

% normalize each scenario
sumP = sum(probP_scen(:,:));
for i=1:32
    probP_scen(:,i) = probP_scen(:,i)./sumP(i);
end

T_Precip=zeros(32,32,5);
if constTime % TMs constant in time
    for i=1:5
        T_Precip(:,:,i)=probP_scen(:,:);
    end
end

end 