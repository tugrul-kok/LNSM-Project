function [ H ] = buildJacobianMatrixH(parameters,UE,AP,TYPE)
% 
% %% compute the distance between UE and APs
% distanceUEAP = sqrt( sum( [UE - AP].^2 , 2 ) ); 
% 
% %% evaluate direction cosine
% directionCosineX = ( UE(1)-AP(:,1) ) ./ distanceUEAP;
% directionCosineY = ( UE(2)-AP(:,2) ) ./ distanceUEAP;
% 
% %% build H
% H = zeros( parameters.numberOfAP-1 , 2 );
% for a = 1:parameters.numberOfAP
%     switch TYPE
%         case 'TOA'
%             H(a,:) = [ directionCosineX(a) , directionCosineY(a) ];
%         case 'AOA'
%             H(a,:) = [ -directionCosineY(a)/distanceUEAP(a) , ...
%                         directionCosineX(a)/distanceUEAP(a) ];
%     end
% end
% 
% end
dm = norm(AP(2,:) - UE);                % distance between UE and Master AP
Master = AP(2,:);                        % master ap
AP(2,:) = [];                            % delete master ap 
H = zeros(size(AP,1), size(AP,2));
for i = 1:size(H,1)
    di = norm(AP(i,:) - UE);                    % distance between UE and current AP
    H(i,:) = (AP(i,:) - UE)/di - (Master - UE)/dm;
end