% script to calculate the horizontal flux divergence of nutrients from output from the ECCO2 darwin model run
% Sophie Clayton, July 2011
% sclayton@mit.edu

clear all

% set up the grid stuff
addpath /home/jahn/matlab/gael_class

gcmfaces_init
dirGrid='/scratch/jahn/run/ecco2/cube84/d0006/run.13/';
global mygrid
mygrid = []
grid_load(dirGrid,6);

% calculate the volume and face areas of the grid boxes
volc=0*mygrid.hFacC;
as=0*mygrid.hFacC;
aw=0*mygrid.hFacC;

for f=1:6;
for k=1;
volc{f}(:,:,k)=mygrid.RAC{f}*mygrid.DRF(k)*mygrid.hFacC{f}(:,:,k);
as{f}(:,:,k)=mygrid.DRF(k).*mygrid.DYG{f}.*mygrid.hFacS{f}(:,:,k);
aw{f}(:,:,k)=mygrid.DRF(k).*mygrid.DXG{f}.*mygrid.hFacW{f}(:,:,k);
end
end
% 
% time=184176;

%for t=1;
% it=time(t);


% load in global fields of the variables
% U,V
%[u,v]=HRknit_UVave(it);
u=readbin('/scratch/sclayton/high_res/UVEL_1999.data',[3060 510 50]);
v=readbin('/scratch/sclayton/high_res/VVEL_1999.data',[3060 510 50]);

u=convert2gcmfaces(u,6);
u=u(:,:,1:30);
v=convert2gcmfaces(v,6);
v=v(:,:,1:30);


fid=fopen('/scratch/sclayton/high_res/Nuts/Nuts/1999.data','r','b');
print('loaded vels')

for n=1;
% nutrients
%[N]=HRknit_N(it,n);

N=fread(fid,3060*510*30,'real*4');
N=reshape(N,[3060 510 30]);

% interpolate the nutrients onto the same grid as U,V

N=convert2gcmfaces(N,6,'cube');


N=N.*mygrid.mskC(:,:,1:30);
N=exch_T_N(N);

for f=1:6;
Nu{f}=0.5.*(N{f}(1:end-2,2:end-1,:)+N{f}(2:end-1,2:end-1,:));
Nv{f}=0.5.*(N{f}(2:end-1,1:end-2,:)+N{f}(2:end-1,2:end-1,:));
end

Nu=gcmfaces(Nu);
Nv=gcmfaces(Nv);
% calculate the fluxes
UN=U.*Nu.*aw(:,:,1:30);
VN=V.*Nv.*as(:,:,1:30);

[UN,VN]=exch_UV(UN,VN);
for f=1:6;
divUN{f}(:,:,:)=(UN{f}(1:end-1,:,:)-UN{f}(2:end,:,:))./volc{f}(:,:,1:30);
divVN{f}(:,:,:)=(VN{f}(:,1:end-1,:)-VN{f}(:,2:end,:))./volc{f}(:,:,1:30);
end

% convert back to matlab format

% write out the flux divergence of the tracer

out=sprintf('/scratch/sclayton/high_res/horz_flux/divUN_trac%02d.data',n);
fidout=fopen(out,'w','b');
fwrite(fidout,divUN,'real*4');
fclose(fidout);

out=sprintf('/scratch/sclayton/high_res/horz_flux/divVN_trac%02d.data',n);
fidout=fopen(out,'w','b');
fwrite(fidout,divVN,'real*4');
fclose(fidout);

end %n
clear Nu Nv UN VN divUN divVN
end %t

fclose(fid);





