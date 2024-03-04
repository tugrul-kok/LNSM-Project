function likelihood = evaluateLikelihoodTDOA( sigmaTDOA , rho , APmaster , AP , evaluationPoint  )

evaluation_rho = sqrt (  sum( [evaluationPoint - APmaster ].^2,2 ) ) -sqrt (  sum( [evaluationPoint - AP ].^2,2 ) ) ;            
argument = rho - evaluation_rho;

likelihood = 1./sqrt(2*pi*sigmaTDOA^2) .* exp( -0.5 * (argument/sigmaTDOA).^2 );


end