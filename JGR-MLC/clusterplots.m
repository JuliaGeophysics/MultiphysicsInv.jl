%load data2800.mat
centers_res=real(Cbest(:,1));
 centers_vel=real(Cbest(:,2));
iter =1;
U=Ubest';
 %for kj=1:length(41*176) 
        % maxU = max(U(1:5));
       % kk=find(U(1:n_clustter,kj) == maxU);
      % power(1,kj)=centers(kk)*maxU;
             power=centers_res'*U;
             cdm=10.^(power);
             m1=real(cdm');
            % m1 = reshape(m1,41,176);
             fuzzy_se=centers_vel'*U;
             m2=real(fuzzy_se');
             %m2 = reshape(m2,41,176);
         %GU(iter,kj)=kk;
        
% end    
 
 em_voro.v = 1./m1'; 
 vm_voro.v = m2'; 
 
 emj_c = vm_voronoi2RBFvm(em_voro); 
 vmj_c = vm_voronoi2RBFvm(vm_voro);
 
 figure(1)
 subplot(211)
 imagesc(1./vmj_c.sl);colormap(jet_1500_6500_v5); caxis([1.49, 4.48])
 title('V_p created using best accepted U and C')
 colorbar
 subplot(212)
 imagesc(1./vmj_best.sl);colormap(jet_1500_6500_v5)
 caxis([1.49, 4.48])
 colorbar
 title('Best accepted V_p')
 
 figure(2)
 subplot(211)
 imagesc(log10(emj_c.sl));colormap(jet_1500_6500_v5); caxis([-0.5 2.0])
 title('R_v created using best accepted U and C')
 colorbar
 subplot(212)
 imagesc(log10(emj_best.sl));colormap(jet_1500_6500_v5); caxis([-0.5 2.0])
 colorbar
 title('Best Accepted R_v')