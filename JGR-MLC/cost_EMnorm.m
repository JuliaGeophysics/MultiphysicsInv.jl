function [phi_EM] = cost_EMnorm(EM)
ret=system(sprintf('%s > out_m.txt',EM.forward_sh));
phi_EM = load('fcost.txt');
% fid = fopen('data_EM/data');
% M=textscan(fid,'%s%f%f%s','Delimiter',{'(',',',')'},'MultipleDelimsAsOne',false);
% d_tr =[M{2},M{3}];
% fclose(fid); 
% clear EM fid M 
% fid = fopen('data');
% M=textscan(fid,'%s%f%f%s','Delimiter',{'(',',',')'},'MultipleDelimsAsOne',false);
% d_cal =[M{2},M{3}];
% minus = (norm(d_tr(:,1)-d_cal(:,1), 2)); 
% plus = (norm(d_tr(:,1)+d_cal(:,1), 2)); 
% phi_EM = 2*minus/(minus+plus);
% fclose(fid);
end

 