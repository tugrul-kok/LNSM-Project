function [ h ] = measurementModel(parameters,UE,AP,TYPE)

%% compute the distance between UE and APs
distanceUEAP = sqrt( sum( [UE - AP].^2 , 2 ) ); 

%% build the vector/matrix of observation
h = zeros( 1 , parameters.numberOfAP );
for a = 1:parameters.numberOfAP
    switch TYPE
        case 'TOA'
            h(a) = distanceUEAP( a );
        case 'AOA'
            h(a) = atan2( ( UE(2)-AP(a,2) ) , ( UE(1)-AP(a,1) ) );
%         case 'RSS'
%             P0 = 10; d0=1; np=2;
%             h(a) = P0 - 10*np*log10( distanceUEAP(a) / d0 );     
         case 'TDOA'
             refAP = 2;
             h(a) = distanceUEAP( a ) - distanceUEAP( refAP );
    end
    
end

end