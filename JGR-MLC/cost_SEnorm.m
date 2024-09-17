function [phi_SE, prior_local] = cost_SEnorm(SE,i_step, inv_num,n_cores)

[~,~]= system([sprintf('%s > out_m1.txt',SE.forward_sh) ' ' num2str(i_step) ' ' num2str(n_cores) ' ' num2str(inv_num)]);
while isempty(dir('raytr_inst*')) ~= 1
    % Do nothing and wait until all temporary individual rayfile have been concatenated in the big .ray permanent rayfile
end
rfn            = read_rayfan_short(sprintf('%s_%d.ray',SE.vm_and_ray_modelfile_root,i_step)); 
 if length(rfn) ~= 34;
    fprintf(1,'length(rfn) %g ~= length(rfn_in) %g --> This model will be skipped by turning prior_local to 0\n', length(rfn), 34);  prior_local = 0; 
   else 
       prior_local=1; 
 end
   
 temp = calc_rayfan_stats_RJMCMC(rfn);
 phi_SE = temp.chi2;
%  t = vertcat(rfn(:).t);
% tPick = vertcat(rfn(:).pk);
% minus = (norm(t(:)-tPick(:), 2)); 
% plus = (norm(t(:)+tPick(:), 2));
% temp = 2*minus/(minus+plus); 
% phi_SE = temp; 
end 