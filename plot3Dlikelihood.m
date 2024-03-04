function plot3Dlikelihood(parameters, AP , UE , x , y , likelihood , TYPE, tag)

figure();
for a = [1, 3, 4, 5, 6]
    if a == 1
        subplot(3,2,a)
    else
        subplot(3,2,a-1)
    end
    surf(  x, y , squeeze(likelihood(tag,a,:,:))' ),hold on
    
    shading flat
    colorbar;

    xlabel('[m]'), ylabel('[m]');
    plot3( AP(:,1) , AP(:,2) ,0.01+zeros(1,size(AP,1)), '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] )
    plot3( AP(a,1) , AP(a,2) ,0.01, '^','MarkerSize',10,'MarkerEdgeColor',[102,254,0]./255,'MarkerFaceColor',[102,254,0]./255 )
    plot3( UE(:,1) , UE(:,2) ,0.01, 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )
    
    switch TYPE
        case 'TOA'
            title(['Likelihood ',num2str(TYPE),', ${AP}$ = ',num2str(a),' , $\sigma $ = ',num2str(parameters.sigmaTOA),' m '],'Interpreter','Latex')
         case 'RSS'
        title(['Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(a),' , $\sigma $ = ',num2str(parameters.sigmaRSS),' m '],'Interpreter','Latex')
        case 'AOA'
            title(['Likelihood ',num2str(TYPE),', ${AP}$ = ',num2str(a),' , $\sigma $ = ',num2str(rad2deg(parameters.sigmaAOA)),' deg '],'Interpreter','Latex')
        case 'TDOA'
            title(['Likelihood for Tag',num2str(tag),' ',num2str(TYPE),', ${AP}$ = 2-',num2str(a),' , $\sigma $ = ',num2str(parameters.sigmaTDOA),' m '],'Interpreter','Latex')
    end
    

end



end