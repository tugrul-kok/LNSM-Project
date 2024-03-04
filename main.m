clear all, clc, close all


% Loading data
load("Project_data.mat")

parameters.xmin = (floor(min(AP(:,1))) - 1); parameters.ymin = (floor(min(AP(:,2))) - 1);
parameters.xmax =  (ceil(max(AP(:,1))) + 1); parameters.ymax =  (ceil(max(AP(:,2))) + 1);
parameters.numberOfAP = size(AP,1);
parameters.samplingTime=0.1;
AP = AP(:,1:2); % Removes Z axis

% Z-Score or Standard Score: Calculate the Z-score for each data. High Z
% point means it is a outlier

tag = 1;
% To display data before pre-process and after
subplot(2,1,1)
for j = 1:5
    plot(rho{tag}(j,:))
    hold on
end
grid on
legend('TDOA2-1','TDOA2-3','TDOA2-4','TDOA2-5','TDOA2-6')
title("Raw Data of Tag 1")
ylabel("Range Difference [m]")
xlabel("Samples [n]")

%% Preprocess
for i=1:4
    z_scores = zscore(rho{i});
    threshold = 2;

    % Identify and replace outliers with NaN values
    rho{i}(abs(z_scores) > threshold) = NaN;

    % To fill NaN values
    ranges{i,1}= inpaint_nans(rho{i});

end
%% Data display
subplot(2,1,2)
for j = 1:5
    plot(ranges{tag}(j,:))
    hold on
end
grid on
title("Processed Data of Tag 1")
legend('TDOA2-1','TDOA2-3','TDOA2-4','TDOA2-5','TDOA2-6')
ylabel("Range Difference [m]")
xlabel("Samples [n]")
%% Calculating standard deviation for each array in the cells
parameters.sigmaTDOA  = cellfun(@(x) std(x, 0, 2), ranges, 'UniformOutput', false);


%% Creating a grid of evaluation points to sample the scenario from Lab1
x = linspace( parameters.xmin , parameters.xmax , 100);
y = linspace( parameters.ymin , parameters.ymax , 100);

parameters.numberOfTags = size(ranges,1);
likelihood = zeros(parameters.numberOfTags, parameters.numberOfAP , length(x) , length(y) );
meansArray = zeros(parameters.numberOfTags, 2);
for tag = 1:4
    uhat = zeros(size(ranges{tag},2),2);
    for t= 1: size(ranges{tag},2)
        for a = 1:6
            % evaluate the likelihood in each evaluation point
            for i = 1:1:length(x)
                for j = 1:1:length(y)
                    if a~=2
                        if a == 1
                            likelihood(tag,a,i,j) =evaluateLikelihoodTDOA ( parameters.sigmaTDOA{tag}(a) , ranges{tag}(a,t), AP(2,:) , AP(a,:) , [x(i) , y(j)]);
                        else
                            likelihood(tag,a-1,i,j) =evaluateLikelihoodTDOA ( parameters.sigmaTDOA{tag}(a-1) , ranges{tag}(a-1,t), AP(2,:) , AP(a,:) , [x(i) , y(j)]);
                        end
                    end

                end %j
            end %i
        end %a
        %% Computing the maximum likelihood and plot it
        maximumLikelihood = ones(length(x),length(y));

        for a= [1 3 4 5 6]
            if a == 1
                maximumLikelihood = maximumLikelihood .* squeeze(likelihood(tag,a,:,:));
            else
                maximumLikelihood = maximumLikelihood .* squeeze(likelihood(tag,a-1,:,:));
            end
        end
        %  plotMaximumlikelihood( parameters, AP , x , y , maximumLikelihood , 'TDOA')

        %% Evaluating the UE estimated position
        maxValue = max( maximumLikelihood(:));
        [xhat , yhat] = find(maximumLikelihood == maxValue);
        uhat(t,1) = x(xhat(1));
        uhat(t,2) = y(yhat(1));
    end %t
    for i = 1:parameters.numberOfTags
        meansArray(tag,:) = mean(uhat(1:end,:),1);
    end
    locations{tag} = uhat;
end %tag

%% Loading data if needed
%load('workspace2.mat')
%% Low pass filter
sigma = 3;  % Standard deviation of the Gaussian kernel

for tag = 1:4
    for i=1:2
        array = locations{tag}(:,i);
        locations{tag}(:,i) = imgaussfilt(array, sigma);
    end
end

%% Ploting Tracks
markerSize = 10; % Adjust the size according to your preference
for ap = 1:6
    plot(AP(ap, 1), AP(ap, 2),  '^', 'MarkerSize', markerSize, 'MarkerFaceColor', 'red','HandleVisibility', 'off')
    hold on
end
rectangle('Position', [min(AP(:,1)) min(AP(:,2)) max(AP(:,1))-min(AP(:,1)) max(AP(:,2))-min(AP(:,2))], 'EdgeColor', 'blue', 'LineWidth', 2);

for tag = 1:4
    plot(locations{tag}(:,1), locations{tag}(:,2))
    legend
    hold on
end
legend('Tag 1', 'Tag 2', 'Tag 3', 'Tag 4')
xlabel('m')
ylabel('m')
grid on

%% EKF with Random Walk and Random Force
% EKF with Random Walk Model (position estimates)
parameters.sigma_v = 0.25;
T = 0.1; % Sampling Time

% Motion model
F = eye(2);
Q = (T*parameters.sigma_v)^2 * eye(2);

parameters.UE_init = [10, 10];
parameters.UE_init_COV = diag([100^2 100^2]);

fig = figure;
fig.WindowState = 'maximized';
for i = 1:parameters.numberOfTags
    tic
    R = diag(parameters.sigmaTDOA{i}(1:end));
    parameters.simulationTime = size(ranges{i},2);
    x_hat = EKF(parameters, AP, F, Q, R, ranges{i}, "Random Walk");
    ekfRW_ev_time(i) = toc;
    subplot(2,1,1)
    plot(x_hat(:,1), x_hat(:,2)), hold on

    % distance error
    DeltaPosition_KF = meansArray(i,:) - x_hat(1:end,1:2); a = 1;
    err_KF = sqrt( sum ( DeltaPosition_KF.^2,2 ) );
    t = a*parameters.samplingTime:parameters.samplingTime:parameters.samplingTime*parameters.simulationTime;

    subplot(2,1,2)
    plot(t , err_KF ), hold on
end
subplot(2,1,1)
grid minor
xlabel('x [m]'); ylabel('y [m]');
title('Tracking with EKF - Random Walk Model');
legend('Tag 1', 'Tag 2', 'Tag 3', 'Tag 4');
subplot(2,1,2)
grid minor
xlabel('time [s]'), ylabel('m'), title('Position Error for the Final Position');
legend('Tag 1', 'Tag 2', 'Tag 3', 'Tag 4');


%% EKF with Random Force Model (position + velocity estimates)
parameters.sigma_a = 0.05; % std of random accelaration
% Motion model
F = [1, 0, T, 0;
    0, 1, 0, T;
    0, 0, 1, 0
    0, 0, 0, 1];
L = [0.5*T^2 0; 0 0.5*T^2; T 0; 0 T];
Q = parameters.sigma_a^2 * (L * L');

parameters.UE_init = [10, 10, 0, 0];
parameters.UE_init_COV = diag([10000^2 10000^2 100^2 100^2]);
fig = figure;
fig.WindowState = 'maximized';
for i = 1:parameters.numberOfTags

    tic
    R = diag(parameters.sigmaTDOA{i}(1:end));
    parameters.simulationTime = size(ranges{i},2);
    x_hat = EKF(parameters, AP, F, Q, R, ranges{i}, "Random Force");
    ekfRF_ev_time(i) = toc;

    subplot(3,1,1)
    plot(x_hat(:,1), x_hat(:,2))
    title(sprintf('EKF - Random Force: Position Estimate '))
    xlabel('x [m]')
    ylabel('y [m]')
    grid minor
    legend('Tag 1', 'Tag 2', 'Tag 3', 'Tag 4')
    hold on

    t = parameters.samplingTime:parameters.samplingTime:parameters.samplingTime*parameters.simulationTime;
    subplot(3,1,2)
    plot(t, x_hat(:,3)), hold on
    plot(t, x_hat(:,4))
    xlabel('time [s]')
    ylabel('velocity [m/s]')
    legend('tag1 v_x',' tag1 v_y','tag2 v_x',' tag2 v_y','tag3 v_x',' tag3 v_y','tag4 v_x',' tag4 v_y')
    title(sprintf('EKF - Random Force: Velocity Estimate'))

    grid minor,
    ylim([-1 1]), hold on,

    % distance error
    DeltaPosition_KF = meansArray(i,:) - x_hat(1:end,1:2); a = 1;
    err_KF = sqrt( sum ( DeltaPosition_KF.^2,2 ) );
    t = a*parameters.samplingTime:parameters.samplingTime:parameters.samplingTime*parameters.simulationTime;

    subplot(3,1,3)
    plot(t , err_KF )
    grid minor
    xlabel('time [s]'), ylabel('m'), title(sprintf('Position Error for the Final Position'));
    legend('Tag 1', 'Tag 2', 'Tag 3', 'Tag 4')
    hold on
end
