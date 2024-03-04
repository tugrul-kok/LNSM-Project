function [x_hat, P_hat] = EKF(parameters, AP, F, Q, R, rho, MODEL)
UE_init = parameters.UE_init;       
UE_init_COV = parameters.UE_init_COV;
switch MODEL
    case 'Random Walk'
        x_hat = NaN( parameters.simulationTime , 2);
        P_hat = NaN( 2 , 2 , parameters.simulationTime );
    case 'Random Force'
        x_hat = NaN( parameters.simulationTime , 4);
        P_hat = NaN( 4 , 4 , parameters.simulationTime );
end

for time = 1 : parameters.simulationTime
    %prediction
    if time == 1
        x_pred =  UE_init';
        P_pred =  UE_init_COV;
    else
        x_pred = F * x_hat(time-1,:)';
        P_pred = F * P_hat(:,:,time-1) * F' + Q;
    end
    H = buildJacobianMatrixH(parameters, x_pred(1:2)', AP, 2);
    if MODEL == "Random Force", H = [H zeros(parameters.numberOfAP-1, 2)]; end

    %update
    G = P_pred * H' * inv( H*P_pred*H' + R);
    x_hat(time,:) = x_pred +  G * ( rho(:,time) - measurementTDOA(x_pred(1:2)', AP, 2) ) ;
    P_hat(:,:,time) = P_pred - G * H * P_pred;
end