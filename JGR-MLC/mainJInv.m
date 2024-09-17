%%This script runs joint-inversion of first-arrival seismic and controlled-source electromagnetic data 
%%Authors: Pankaj K Mishra & Adrien Arnulf 
clear variables
close all
clc

%---------------------------------------------------------------------------------------------------------------
addpath(genpath('helpers'))
%Change parameters below
inv_num    = 1; 
it_init         = 0;
n_steps      = 3000;
nloop         = 4;
n_cores     = 15; 
do_figures =  0; 

%% File definitions
% SEISMIC

SE.file_root     = 'SE01_voro_300pts'; 
SE.forward_sh  = './run_forwardSE.csh';
SE.raytrac_directory = sprintf('./inversion%g_SE',inv_num);         
                                      system(sprintf('mkdir -p %s',SE.raytrac_directory));
SE.vm_and_ray_modelfile_root = sprintf('%s/%s_%d',SE.raytrac_directory,SE.file_root,inv_num); 
SE.vorovm_directory = sprintf('./inversion%g_voro_SE',inv_num); 
                                      system(sprintf('mkdir -p %s',SE.vorovm_directory)) ;
SE.vm_voro_modelfile_root = sprintf('%s/%s_%d',SE.vorovm_directory,SE.file_root,inv_num);  
                                    
       
       
% EM
EM.file_root     = 'EM01_voro_300pts'; 
EM.forward_sh  = './run_forwardEM.sh';
EM.raytrac_directory = sprintf('./inversion%g_EM',inv_num);
                                         system(sprintf('mkdir -p %s',EM.raytrac_directory)) ;
EM.vm_and_ray_modelfile_root = sprintf('%s/%s_%d',EM.raytrac_directory,EM.file_root,inv_num);  
                          
EM.vorovm_directory = sprintf('./inversion%g_voro_EM',inv_num); 
                                        system(sprintf('mkdir -p %s',EM.vorovm_directory)) ;
EM.vm_voro_modelfile_root = sprintf('%s/%s_%d',EM.vorovm_directory,EM.file_root,inv_num);

petro_directory = sprintf('./petro_%g',inv_num); 
                             system(sprintf('mkdir -p %s', petro_directory));
  
      
 %% Prior informations 
 %SE
 vp_min_ok = 1.49; 
 vp_max_ok = 4.5;

 %EM
em_min_ok = 0.01 ; 
em_min_ok_log = log10(em_min_ok); 
em_max_ok =3.0; 
em_max_ok_log = log10(em_max_ok); 
em_axis=[-0.5 2.0]; 
       
       
 %% Making & Storing the starting model 
 makevoro_both(inv_num)  %makes voro model for SE & EM on the same points and stores in voro_models
 
vm_voro0          = vm_voro_read(sprintf('./inversion%d_voro_SE/%s_%d_%d.vorovm',inv_num,SE.file_root, inv_num,it_init));
vm_voro0.v      = vp_min_ok + rand(size(vm_voro0.v)).*(vp_max_ok-vp_min_ok);



 em_voro0 = vm_voro_read(sprintf('./inversion%d_voro_EM/%s_%d_%d.vorovm',inv_num, EM.file_root, inv_num,it_init));
 em_voro0.v = em_min_ok_log+ rand(1, length(em_voro0.v)).*(em_max_ok_log-em_min_ok_log);
 em_voro0.v = 10.^em_voro0.v;  
 
 [emj0]             = vm_voronoi2RBFvm(em_voro0); 
 [vmj0]              = vm_voronoi2RBFvm(vm_voro0); 

 vm0                 = vm_jumps('remove',vmj0);
%write the initial velocity model
vm_write(vm0,sprintf('%s_%d.vm',SE.vm_and_ray_modelfile_root,it_init));
 vm_write2emh5(emj0,sprintf('%s_%d.h5',EM.vm_and_ray_modelfile_root,it_init));
 
 
 %% Compute priors 
 [prior_min_vp,prior_max_vp] = define_vfsa_prior_arrays(vmj0, vp_min_ok,vp_max_ok);
 [prior_min_em,prior_max_em] = define_vfsa_prior_arrays(emj0, em_min_ok,em_max_ok);
  % information concerning the bounds of the model (min_x, max_x, min_z, % max_z)
[min_x,max_x,nx,x_axis,min_z,max_z,nz,z_axis] = vm_axis_properties(vmj0);
[X_AXIS,Z_AXIS] = meshgrid(x_axis,z_axis); 
                                                                              
                                                                              %%%%%%%%%%%%%%%%%%%
                                                                              %%%%%%%%%%%%%%%%%%%
                                                                              %%%%%%%%%%%%%%%%%%%
                                                                              %%%%%%%%%%%%%%%%%%
                                                                              %%%%%%%%%%%%%%%%%%%
  
  %% Compute costs of the starting models

[phi_SE0] = cost_SEnorm(SE,it_init, inv_num,n_cores); % Computes cost of Raytracing (SE)

                                    [status1,result1] = system(sprintf('rm %s_%d.ray',SE.vm_and_ray_modelfile_root,it_init)); % remove .ray files
                                    [status2,result2] = system(sprintf('rm %s_%d_raytr.out',SE.vm_and_ray_modelfile_root,it_init)); % remove .ray files
                                    
[phi_EM0] = cost_EMnorm(EM); % Computes cost of CSEM  




t0                              = 70000;
like_accept = zeros(n_steps,1);
like_accept_SE=zeros(n_steps,1);
like_prop = zeros(n_steps,1); 
like_detail   = zeros(n_steps,nloop);
phi_SE   = zeros(n_steps,nloop);
phi_EM  = zeros(n_steps,nloop);
phi_FCM = zeros(n_steps, nloop);	
temp_T       = zeros(n_steps,1)+NaN; 
like_test = zeros(n_steps,1);
AR = zeros(n_steps,nloop); 

  res_in = 1./em_voro0.v; 
  vel_in =  vm_voro0.v; 
 
[U0, C0, phi_FCM0] = gkfcmclust(res_in,vel_in,6, 0);
             

like0    = phi_SE0+ phi_EM0/0.002+phi_FCM0/2.5; 
like      = like0;
like_best = like0;
save(sprintf('./petro_%g/data%d.mat',inv_num,it_init)); 
for i_step = (it_init+1):(it_init+n_steps)
 t1            = VFSA_t_update(t0,i_step-1); % cooling temperature schedule
 tt             = t1; 
vm_voro  = vm_voro0; 
em_voro = em_voro0; 
 for jj=1:nloop 
                 vm_voro  = vm_voro0; 
                
             
% velocity perturbation ------------------------------
          vp_lb                = interp2(X_AXIS,Z_AXIS,prior_min_vp,vm_voro.x,vm_voro.z);
          vp_ub               = interp2(X_AXIS,Z_AXIS,prior_max_vp,vm_voro.x,vm_voro.z);
          vp_curr            = VFSA_mod_cauchy(vm_voro.v,vp_lb,vp_ub,tt);
          vm_voro.v        = vp_curr;
          prior_local       = 1; % prior_local is always 1 for VFSA
          
             [vmj] = vm_voronoi2RBFvm(vm_voro);
            % vmj.sl(vmj.sl < 1./vp_max_ok) =1./vp_max_ok ;
            % vmj.sl(vmj.sl > 1./vp_min_ok) =1./vp_min_ok ;
              vm = vm_jumps('remove',vmj);
  % conductivity perturbation -------------------------------
            em_voro            = em_voro0;          
            em_lb                = interp2(X_AXIS,Z_AXIS,prior_min_em,em_voro.x,em_voro.z);
            em_ub               = interp2(X_AXIS,Z_AXIS,prior_max_em,em_voro.x,em_voro.z);           
             em_lb_log        = log10(em_lb); 
             em_ub_log       = log10(em_ub); 
             em_voro.vlog   = log10(em_voro.v);  
                                   
             em_curr_log     = VFSA_mod_cauchy(em_voro.vlog,em_lb_log,em_ub_log,tt);
             em_curr            = 10.^em_curr_log;
             em_voro.v        = em_curr;
                                 
              [emj] = vm_voronoi2RBFvm(em_voro); 
             % emj.sl(emj.sl(:) < 1./em_max_ok) =1./em_max_ok  ;
             % emj.sl(emj.sl(:) > 1./em_min_ok) =1./em_min_ok  ;  
              
             
            
             vm_write(vm,sprintf('%s_%d.vm',SE.vm_and_ray_modelfile_root,i_step));          
             vm_write2emh5(emj,sprintf('%s_%d.h5',EM.vm_and_ray_modelfile_root,it_init));                   
              
       
              [phi_SE(i_step,jj),prior_local] = cost_SEnorm(SE,i_step, inv_num,n_cores);                 
                                               [status3,result3] = system(sprintf('rm %s_%d.vm',SE.vm_and_ray_modelfile_root,i_step));
                                               [status2,result2] = system(sprintf('rm %s_%d_raytr.out',SE.vm_and_ray_modelfile_root,i_step));                     
              phi_EM(i_step,jj) = cost_EMnorm(EM);    
                                                   if  phi_EM(i_step,jj) == 0 
                                                       fprintf('EMcrash -- skipping this model by turning prior_local to 0 ')
                                                       prior_local =0; 
                                                   end
              %=================================================================================
                    res_in = 1./em_voro.v; 
                    vel_in =  vm_voro.v; 
                    cnk = 1000;
                    %lambda = linspace(0.00001, 0.001, 3000);
                   % lambda(i_step) =1;
                 [U, C, phi_FCM(i_step,jj)] = gkfcmclust(res_in,vel_in,6,cnk);
                like_prop = phi_SE(i_step,jj)+  phi_EM(i_step,jj)/0.002+phi_FCM(i_step,jj)/2.5; 
              
                if like_prop < like_best  && prior_local ~= 0
                                                    like_best= like_prop; 
                                                      
                                                   vmj_best = vmj; 
                                                   emj_best = emj;
                                          %  vm_voro_best = vm_voro;
                                           % em_voro_best = em_voro; 
                                            Ubest = U; 
                                            Cbest = C;
                                            
                                            
                end 
               
                
                
                 delE = like_prop - like;
                            like_test = exp(-delE/tt);
                u2=rand; %u is random number between 0 and 1
           if (delE <= 0) || (u2<(prior_local*like_test)) 
                    SE.vm_voro_modelfile = sprintf('%s_accept_%d.vorovm',SE. vm_voro_modelfile_root,i_step);
                                   vm_voro_write(vm_voro,SE.vm_voro_modelfile);
                     EM.vm_voro_modelfile = sprintf('%s_accept_%d.vorovm',EM. vm_voro_modelfile_root,i_step);
                                   vm_voro_write(em_voro,EM.vm_voro_modelfile);
                  
                                   vm_voro0 = vm_voro; 
                                   em_voro0 = em_voro;
                      
                                   vmj0 = vmj; 
                                   emj0 = emj;
                                   U0 = U; 
                             
                                   like = like_prop; 
                                   likeSE= phi_SE(i_step,jj);
                                   likeEM= phi_EM(i_step,jj); 
                                   likeFCM = phi_FCM(i_step,jj); 
           end
           
          fprintf('iteration = %d, loop = %d, EM = %f, SE = %f, FCM = %f, curr = %f, best=%f', i_step, jj, phi_EM(i_step,jj)/0.002, phi_SE(i_step,jj), phi_FCM(i_step,jj)/5, like_prop, like_best)
          [status1,result1] = system(sprintf('rm %s_%d.ray',SE.vm_and_ray_modelfile_root,i_step));   

end
  temp_T(i_step) = tt;
  like_accept(i_step) = like; 
  like_accept_EM(i_step) = likeEM; 
  like_accept_SE(i_step) = likeSE; 
  like_accept_FCM(i_step) = likeFCM; 
  if i_step ==0 || mod(i_step,10)==0
     save(sprintf('./petro_%g/data%d.mat',inv_num,i_step)); 
  end
end
