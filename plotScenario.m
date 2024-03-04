function plotScenario( parameters , AP , UE )

nAP = parameters.numberOfAP;
xmin = parameters.xmin;
ymin = parameters.ymin;
xmax = parameters.xmax;
ymax = parameters.ymax;

figure() 
hold on
patch( [xmin xmax xmax xmin] , [ymin ymin ymax ymax], [54 114 91]./255 , 'FaceAlpha', .1)

plot( AP(:,1) , AP(:,2) , '^' , 'MarkerSize', 10 , 'MarkerEdgeColor' , [ 0.64 , 0.08 , 0.18 ] , 'MarkerFaceColor' , [ 0.64 , 0.08 , 0.18 ] )

plot( UE(1) , UE(2) , 'o' , 'MarkerSize' , 10 , 'MarkerEdgeColor' , [0.30 , 0.75 , 0.93 ] , 'MarkerFaceColor' , [0.30 , 0.75 , 0.93] )

for a=1:nAP
   text( AP(a,1) , AP(a,2) , sprintf('AP %d ', a) )
end

grid on
box on
legend( 'Localization Area' , 'AP' , 'UE' , 'location' , 'best' )
xticks( [xmin:20:xmax] )  , yticks( [xmin:20:xmax] )
xlim( [xmin-1 xmax+1] ) , ylim( [ymin-1 ymax+1] )
xlabel( 'meter' , 'FontSize' , 26 ) 
ylabel( 'meter' , 'FontSize' , 26 )
axis equal



end