% script to calculate annual average ekman transport at the surface of ECCO
% model
% Sophie Clayton, sclayton@mit.edu, August 2012

clear all

u=zeros(3060, 510);
v=zeros(3060, 510);

ncs = 510;
tnx = 102;
tny = 51;
tnz = 50;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;

load('/home/jahn/matlab/cube66.mat','latc');
om=7.27*10^-5;
f=2.*om.*sin(latc);

rho=1025;

day=0;
for it=184176:18:210384;
for itile=0:299;

% y component of velocity
% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUX/oceTAUX.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
input=readbin(in,[tnx tny]);
input=reshape(input,[tnx,1,1,tny,1]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

wx(:,xt+1,fc+1,:,yt+1)=  input;
clear input in

% y component of velocity
% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUY/oceTAUY.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
input=readbin(in,[tnx tny]);
input=reshape(input,[tnx,1,1,tny,1]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

wy(:,xt+1,fc+1,:,yt+1)= input;
clear input in

end

wx=reshape(wx,[3060 510]);
v=v+(-1./(rho.*f).*wx);

wy=reshape(wy,[3060 510]);
u=u+(1./(rho.*f).*wy);
 
day=day+1

clear wx wy

end

u=u./length(it);
v=v./length(it);

out='/scratch/sclayton/high_res/U_EK.1999.data';
fid=fopen(out,'w','ieee-be');
fwrite(fid,u,'real*4');
fclose(fid)
clear out 

out='/scratch/sclayton/high_res/V_EK.1999.data';
fid=fopen(out,'w','ieee-be');
fwrite(fid,v,'real*4');
fclose(fid)
