
l = 1;
for i=1:4 % 1:4
    %disp(['i = ', num2str(i), ', j = ', num2str(j), ', k = ', num2str(k)]);
    for j=1:5-i % 0:4-i
        for k=2:6-(i+j-1)
        % get data
            disp(['data1 = ', num2str(i), ', ', num2str(k+j), ', data2 = ', num2str(i+j), ', ', num2str(k)]);
            test{i}(:,j) = KLDiv_Precip_Simple(:,l);
            l = l + 1
%             const = constParam;
%             dist1 = data{i}(:,k+j);
%             dist2 = data{i+j}(:,k);
        end
    end
end

%% Get from 1000 x 20 data to cell array for different time periods
l = 1;
for i=1:4 % 1:4
    %disp(['i = ', num2str(i), ', j = ', num2str(j), ', k = ', num2str(k)]);
    for j=1:5-i % 0:4-i
        for k=1:5-(i+j-1)
        % get data
            %disp(['i = ', num2str(i), ', j = ', num2str(j), ', k = ', num2str(k)]);
            KLDiv_Precip_Sim{i,j}(:,k) = KLDiv_Precip_Simple(:,l);
            l = l + 1;
%             const = constParam;
%             dist1 = data{i}(:,k+j);
%             dist2 = data{i+j}(:,k);
        end
    end
end