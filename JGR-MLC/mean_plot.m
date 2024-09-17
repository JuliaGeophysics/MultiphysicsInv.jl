clear all
close all
clc

load('august_data/data_01/data3000.mat')
v1 = vmj_best.sl;  e1 = emj_best.sl; 


load('august_data/data_02/data3000.mat')
v2 = vmj_best.sl;  e2 = emj_best.sl; 


load('august_data/data_03/data3000.mat')
v3 = vmj_best.sl;  e3 = emj_best.sl; 


load('august_data/data_04/data3000.mat')
v4 = vmj_best.sl;  e4 = emj_best.sl; 


load('august_data/data_05/data3000.mat')
v5 = vmj_best.sl;  e5 = emj_best.sl; 


load('august_data/data_06/data3000.mat')
v6 = vmj_best.sl;  e6 = emj_best.sl; 


load('august_data/data_07/data3000.mat')
v7 = vmj_best.sl;  e7 = emj_best.sl; 


load('august_data/data_08/data3000.mat')
v8 = vmj_best.sl;  e8 = emj_best.sl; 


v = (v1+v2+v3+v4+v5+4*v6+v7+v8)/11; 
e =(e1+e2+e3+e4+e5+4*e6+e7+e8)/11;

 figure
 subplot(2,1,1)
 imagesc(1./v);colormap(jet_1500_6500_v5)
 caxis([1.49, 4.4])
 colorbar
 title('Mean V_p') 
 
 subplot(2,1,2)
 imagesc(log10(e));colormap(jet_1500_6500_v5); caxis([-0.5 2.0])
 colorbar
 title('Mean R_v')