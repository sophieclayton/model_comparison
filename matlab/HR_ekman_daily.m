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
f=2.*om.*sind(latc);

co=readbin('/scratch/jahn/grid/cube84/AngleCS.data',[3060 510]);
si=readbin('/scratch/jahn/grid/cube84/AngleSN.data',[3060 510]);

rho=1025;

day=0;
for it=184176-54:72:210384;
for itile=0:299;

% y component of velocity
% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUX/oceTAUX.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
input=readbin(in,[tnx tny]);
in2=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUX/oceTAUX.%010d.%03d.001.data',itile,it+18,itile+1);
input=input+readbin(in2,[tnx  tny]);
in3=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUX/oceTAUX.%010d.%03d.001.data',itile,it+36,itile+1);
input=input+readbin(in3,[tnx  tny]);
in4=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUX/oceTAUX.%010d.%03d.001.data',itile,it+54,itile+1);
input=input+readbin(in4,[tnx  tny]);
input=input./4;
input=reshape(input,[tnx,1,1,tny,1]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

wx(:,xt+1,fc+1,:,yt+1)=input;
clear input in in2 in3 in4

% y component of velocity
% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUY/oceTAUY.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
input=readbin(in,[tnx tny]);
in2=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUY/oceTAUY.%010d.%03d.001.data',itile,it,itile+1);
input=input+readbin(in2,[tnx tny]);
in3=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUY/oceTAUY.%010d.%03d.001.data',itile,it,itile+1);
input=input+readbin(in3,[tnx tny]);
in4=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.6hr/1999/res_%04d/oceTAUY/oceTAUY.%010d.%03d.001.data',itile,it,itile+1);
input=input+readbin(in4,[tnx tny]);
input=input./4;
input=reshape(input,[tnx,1,1,tny,1]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

wy(:,xt+1,fc+1,:,yt+1)=input;
clear input in in2 in3 in4

end

wx=reshape(wx,[3060 510]);
wy=reshape(wy,[3060 510]);

wxx=wx.*co-wy.*si;
wyy=wx.*si+wy.*co;


u=(1./(rho.*f).*wyy);
v=(-1./(rho.*f).*wxx);
day=day+1

clear wx wy

out=sprintf('/scratch/sclayton/high_res/U_EK/U_EK.%04d.1999.data',day);
fid=fopen(out,'w','ieee-be');
fwrite(fid,u,'real*4');
fclose(fid);
clear out 

out=sprintf('/scratch/sclayton/high_res/V_EK/V_EK.%04d.1999.data',day);
fid=fopen(out,'w','ieee-be');
fwrite(fid,v,'real*4');
fclose(fid);

clear u v
end

% make annual average fields




