% Edit model and create fake pk files
clear all
close all
clc

vm=vm_read('SE01_long_1_0.vm');
                         % vmj  = vm_jumps('add',vm);
%vmj.sl(30:35,70:110) = 1/4.48;
                    % vm_out = vm_jumps('remove',vmj);
                     
x = linspace(0,35,176);
z =linspace(0,10,101);
                   
imagesc(x,z,1./vm.sl)
colormap(jet_1500_6500_v5)
hold on
vm_write(vm_out,'SE01_TOY_1_0.vm');

%----------------------------------------------------------
sh = load('shot_all.txt');
sh_toy = sh; 
sh_toy(:,4) = 0.01; 
plot(sh_toy(:,2), sh_toy(:,4),'.w') 
fileID = fopen('shotlocx.txt','w');
nbytes = fprintf(fileID,'%d\t %6.2f\t %d\t %6.4f\n',sh_toy'); 
hold on
fclose(fileID);
%---------------------------------------------------------
 rec = load('rec_obs.txt');
 rec_toy = rec; 
 plot(rec_toy(:,2), rec_toy(:,4),'.r') 
 fileID = fopen('instlocx.txt','w');
 nbytes = fprintf(fileID,'%d\t %6.2f\t %d\t %6.4f\n',rec_toy'); 
 fclose(fileID);

 
 
 %-------------------------------------------------------------------
  fileID = fopen('fakepick.pk','w'); 
  shotsize = size(sh_toy);
  n_shot = shotsize(1);
  recsize = size(rec_toy);
  n_rec   = recsize(1);
  aa = repelem(sh_toy(:,1),n_rec);
  bb = repmat(rec_toy(:,1),n_shot,1);
  pk = zeros(n_shot*n_rec,7);
  pk(:,1) = bb;%aa;
  pk(:,2) = aa;%bb;
  pk(:,3)= 1;
  pk(:,4)= 0; 
  for i =1:n_shot*n_rec 
      shotID = pk(i,2);  %pk(i,1)
      recID  = pk(i,1);    %pk(i,2)
      xs = sh_toy(shotID,2);
      xr = rec_toy(recID,2);
      pk(i,5) = abs(xs-xr);
      pk(i,6) = pk(i,5)/10;
      pk(i,7) = 0.03;
  end
  clear shotID recID
  nbytes = fprintf(fileID,'%d\t %d\t %d\t %d\t %6.4f\t %6.4f\t %6.4f\n',pk'); 
  
%    fileID = fopen('truepick.pk','w'); 
%    load rfntrue.mat 
%    k=0;
%    for i=1:n_shot*n_rec
%        for j =1:n_shot
%            shotID=pk(i,2);
%            recID=pk(i,1);
%            pk(k+1:j*n_shot,6)=rfn(recID).t;
%            k=j*n_shot;
%        end
%    end
%    
% 
% 
%   nbytes = fprintf(fileID,'%d\t %d\t %d\t %d\t %6.4f\t %6.4f\t %6.4f\n',pk'); 
  
  
 