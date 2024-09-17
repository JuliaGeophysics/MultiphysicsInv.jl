%--------------------------------------------------------------------------------------------
% This function replaces fake TT picks with the TTpicks generated using
% true model in 'rfn.t' 
% Pankaj K Mishra, 2019
%---------------------------------------------------------------------------------
%clear all
close all
clc

%----------------------------------------------------------
sh = load('shot_all.txt');
sh_toy = sh; 
sh_toy(:,4) = 0.01; 
%plot(sh_toy(:,2), sh_toy(:,4),'.w') 
%fileID = fopen('shotlocx.txt','w');
%nbytes = fprintf(fileID,'%d\t %6.2f\t %d\t %6.4f\n',sh_toy'); 
%hold on
% fclose(fileID);
%---------------------------------------------------------
 rec = load('rec_obs.txt');
 rec_toy = rec; 
 %plot(rec_toy(:,2), rec_toy(:,4),'.r') 
% fileID = fopen('instlocx.txt','w');
% nbytes = fprintf(fileID,'%d\t %6.2f\t %d\t %6.4f\n',rec_toy'); 
% fclose(fileID);

 
 pk = load('fakepick.pk');
 load rfntrue.mat
 %-------------------------------------------------------------------

  shotsize = size(sh_toy);
  n_shot = shotsize(1);
  recsize = size(rec_toy);
  n_rec   = recsize(1);
 k=0;
 for j=1:n_rec
      for i =1:n_shot*n_rec 
      shotID = pk(i,2);  %pk(i,1)
      recID  = pk(i,1);    %pk(i,2)
      xs = sh_toy(shotID,2);
      xr = rec_toy(recID,2);
      pk(i,5) = abs(xs-xr); 
      aaa(j,:) = rfn(j).t; 
      
      
      end
      
       k=j*n_shot; 
 
 
 end 
scale = 0.01;
n1 = randn(length(aaa(:)),1); % noise with mean=0 and std=1;
n1 = smoothdata(n1);
aaa(:) = aaa(:) + n1.*aaa(:)*scale;
 pk(1:11237,6) = aaa(:); 
 pk(i,7) = 0.011;
%   for rid=1:n_rec
%      plot([rfn(rid).nm], [rfn(rid).t],'-');
%      hold on
% end
 
 %check if copied correctly 
  %clear shotID recID 
  fileID = fopen('truepick.pk','w');
  nbytes = fprintf(fileID,'%d\t %d\t %d\t %d\t %6.4f\t %6.4f\t %6.4f\n',pk'); 
  fclose(fileID);

  
  
 