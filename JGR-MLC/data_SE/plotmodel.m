vm=vm_read('model_background.vm');
vmj  = vm_jumps('add',vm);
vmj.sl(30:35,70:110) = 1/4.48;
                     vm_out = vm_jumps('remove',vmj);
                     
x = linspace(0,35,176);
z =linspace(0,10,101);
                   
imagesc(x,z,1./vm_out.sl)
colormap(jet_1500_6500_v5)