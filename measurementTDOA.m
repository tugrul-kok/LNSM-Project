function h = measurementTDOA(UE, AP, APmaster)
dm = norm(AP(APmaster,:) - UE); % distance between UE and Master AP
AP(APmaster,:) = []; % delete master ap
h = zeros(size(AP,1), 1);
for i = 1:length(h)
    di = norm(AP(i,:) - UE); % distance between UE and current AP
    h(i) = dm - di;
end
