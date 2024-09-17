figure(1)
load('petro_1/data10.mat')
subplot(1,2,1) 
plot(1./vmj_best.sl(:), log10(emj_best.sl(:)),'.')
hold on 
plot([1.49 ;Cbest(:,2)], [-0.5 ;Cbest(:,1)],'ok','markersize', 6, 'MarkerFaceColor', 'r')
ylim([-1, 2.1])
xlabel('V_p'); ylabel('Rv')

load('petro_1/data3000.mat')
subplot(1,2,2)
plot(1./vmj_best.sl(:), log10(emj_best.sl(:)),'.')
hold on 
plot([1.49 ;Cbest(:,2)], [-0.5 ;Cbest(:,1)],'ok','markersize', 6, 'MarkerFaceColor', 'r')
ylim([-1, 2.1])
xlabel('V_p'); ylabel('Rv') 