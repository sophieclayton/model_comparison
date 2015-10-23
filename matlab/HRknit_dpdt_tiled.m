% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields

function [u]=HRknit_dpdt(z);
z=1;
ncs = 510;
tnx = 102;
tny = 51;
tnz = 30;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;
nt=99;
np = 78;

u=zeros(tnx,ntx,nfc,tny,nty,1,np);
day=0;
dpdt=zeros(3060,510,78);

for it=184176:72:210384;
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/ecco2/cube84/tiles/L30/res_%04d/ptracers/ptracers_day.%010d.%03d.001.data',itile,it,itile+1);

input=zeros(tnx,tny,tnz,nt);

input=readbin(in,[tnx tny tnz nt]);
input=input(:,:,:,22:99);
input=reshape(input,[tnx,1,1,tny,1,tnz,np]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

u(:,xt+1,fc+1,:,yt+1,1,:)= u(:,xt+1,fc+1,:,yt+1,1,:) + input(:,:,:,:,:,z,:);
clear input in
% itile

end
day =day +1

uu=reshape(u,[3060 510 78]);

if day>1, dpdt=dpdt+(uu-tmp);end
clear tmp    
tmp=uu;  
clear uu

end

dpdt=dpdt./(length(it)-1);
disp('HR dpdt average done')

out = ('/scratch/sclayton/high_res/DPDT.1999.data');
fid=fopen(out,'w','ieee-be');
fwrite(fid,dpdt,'float32');
fclose(fid);



