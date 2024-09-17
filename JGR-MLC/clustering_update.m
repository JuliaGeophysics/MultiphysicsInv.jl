function [m1, m2, GU] = clustering_update(EM,SE)
   data1=log10(EM);
 data2=SE;
 data=[ data1(:) data2(:)];
 n_clustter = 4; 
 [center, U, obj_fcn] = FCmeans(data, n_clustter); 
 
 centers_res=real(center(:,1));
 centers_vel=real(center(:,2));
iter =1;
 for kj=1:length(data2(:)) 
         maxU = max(U(1:n_clustter,kj));
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
        
 end    

function [center, U, obj_fcn] = FCmeans(data, cluster_n)

data_n = size(data, 1); 
in_n = size(data, 2);   

options = [2;
    100;               
    1e-5;               
    0];                 

expo = options(1);          
max_iter = options(2);		
min_impro = options(3);		
display = options(4);		

obj_fcn = zeros(max_iter, 1);	
U = initfcm(cluster_n, data_n);     

for i = 1:max_iter,
	[U, center, obj_fcn(i)] = stepfcm(data, U, cluster_n, expo);
	if display, 
		fprintf('FCM:Iteration count = %d, obj. fcn = %f\n', i, obj_fcn(i));
	end

	if i > 1,
		if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro, 
            break;
        end,
	end
end

iter_n = i; 
obj_fcn(iter_n+1:max_iter) = [];

function U = initfcm(cluster_n, data_n)
U = rand(cluster_n, data_n);
col_sum = sum(U);
U = U./col_sum(ones(cluster_n, 1), :);

function [U_new, center, obj_fcn] = stepfcm(data, U, cluster_n, expo)
mf = U.^expo; 

tk = zeros(cluster_n,2); 
nk = 15000*ones(cluster_n,2); 
nk(2:end,:) = 150;
for i= 1:cluster_n
tk(1,1) = -0.45; tk(1,2) = 1.6; 
tk(2,1) = -0.2; tk(2,2) = 1.8;
tk(i,1) = i*(tk(2,1) - tk(cluster_n,1)/cluster_n);
tk(i,2) = i*(tk(2,2) - tk(cluster_n,2)/cluster_n);
tk(cluster_n,1) = 2.0; tk(cluster_n,2) = 4.5; 
end
%center = mf*data./((ones(size(data, 2), 1)*sum(mf'))'); 
center = (mf*data+nk.*tk)./((ones(size(data, 2), 1)*sum(mf'))'+nk); % new center
   %  hard_ctrs = [2.0, 4.48];
   %    for i=1:length(hard_ctrs(:,1))
   %        center = hard_constr(center, hard_ctrs(i,:));
   %    end
        
dist = distfcm(center, data);  
obj_fcn = sum(sum((dist.^2).*mf));  
tmp = dist.^(-2/(expo-1));     
U_new = tmp./(ones(cluster_n, 1)*sum(tmp)); 

function out = distfcm(center, data)
out = zeros(size(center, 1), size(data, 1));
for k = 1:size(center, 1), 
    out(k, :) = sqrt(sum(((data-ones(size(data,1),1)*center(k,:)).^2)',1));
end
