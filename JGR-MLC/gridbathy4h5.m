clear all
clc
addpath(genpath('helpers'));
%Line 34 and 35 is hardcoded, change it accordingly 
em_modfile = 'SEAM_Rv.h5'; 
em_bathy_file= 'bath.mat';

% Bathynetry file EM Engine needs to be in grid-point numbers both in x and
% z-axis. This file reads the general bathymetry file (input) (in distances) given with the SEAM
% data and does
% (1) resizes it according to the dimension of current em_modfile (input)
% (2) create a new bathymetry file (output) in grid-numbers to match the
% current(input) em_modfile
%   Example run 
  % bwc = gridbathy4h5('SEAM1_2D_Rv_model.h5','bath.mat');
%   Author:  Pankaj K Mishra, Sept 2019 
%%
[em_str] = em_model_h5read(em_modfile);
s = size(em_str.cond);  % get the size of the model 
% detect padding in the model 
    difx = diff(em_str.dx) ~= 0;
    F_difx = find(difx == 0);

    difz = diff(em_str.dz) ~= 0;
    F_difz = find(difz == 0);

    padding_dim.x1 = F_difx(1)-1;
    padding_dim.x2 = length(em_str.dx)-(F_difx(end)+1);
    padding_dim.z1 = F_difz(1)-1;
    padding_dim.z2 = length(em_str.dz)-(F_difz(end)+1);

%%
load(em_bathy_file); % load the original bathymetry file
bwc(:,1) = linspace(0, 35, s(1)-padding_dim.x1-padding_dim.x2); %%% 35 is total length of model excluding padding
bwc(:,2) = interp1(bath.x, bath.z, bwc(:,1));
%Let's try to convert it in the grid format
bwc(:,1) = 1+round(bwc(:,1)*1000)/100;             %divided by dx  Except padding
bwc(:,2) = round((bwc(:,2)*1000)/50);                %divided by dz except padding 


bathy = zeros(s(1),2);
% hardcoded for 10,10,20,10 paddings 
bathy(11:s(1)-10,1)   = bwc(:,1)+10; 
bathy(11:s(1)-10,2)   = bwc(:,2)+20; 
bathy(s(1)-9:end,1) = s(1)-9:s(1); 
bathy(s(1)-9:end,2) = bathy(s(1)-10,2); 
bathy(1:10,1)  = 1:10;
bathy(1:10,2) = bathy(11,2); 
% generalized 
%bathy(padding_dim.x1+1:s(1)-padding_dim.x2,1)   = bwc(:,1)+padding_dim.x1; 
%bathy(padding_dim.x1+1:s(1)-padding_dim.x2,2)   = bwc(:,2)+padding_dim.z1 ; 
%bathy(s(1)-(padding_dim.x2-1):end,1) = s(1)-(padding_dim.x2-1):s(1); 
%bathy(s(1)-(padding_dim.x2-1):end,2) = bathy(s(1)-padding_dim.x2,2);
%bathy(1:padding_dim.x1,1)  = 1:padding_dim.x1;
%bathy(1:padding_dim.x1,2)  = bathy(padding_dim.x1+1,2);
plot(bathy(:,1), bathy(:,2))


set(gca,'Ydir','reverse')
ylim([1,s(3)])
xlim([1,s(1)])

save('bwc.txt','bathy', '-ascii') 