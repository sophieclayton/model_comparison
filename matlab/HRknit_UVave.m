% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields

function [uu,vv]=HRknit_UVave(it,k);

ncs = 510;
tnx = 102;
tny = 51;
tnz = 50;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;

co=readbin('/scratch/jahn/grid/cube84/AngleCS.data',[3060 510]);
si=readbin('/scratch/jahn/grid/cube84/AngleSN.data',[3060 510]);

%for it=184176;%
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/UVEL/UVEL_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
ufid=fopen(in,'r','ieee-be');
input=fread(ufid,[tnx tny],'real*4');

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

u(:,xt+1,fc+1,:,yt+1)=input;

%p(:,xt+1,fc+1,:,yt+1)=p(:,xt+1,fc+1,:,yt+1) +  input;
clear input in

end

u=reshape(u,[3060 510]);


for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/VVEL/VVEL_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);

vfid=fopen(in,'r','ieee-be');
input=fread(vfid,[tnx tny],'real*4');

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

v(:,xt+1,fc+1,:,yt+1)=input;

%p(:,xt+1,fc+1,:,yt+1)=p(:,xt+1,fc+1,:,yt+1) +  input;
clear input in
%itile
end

v=reshape(v,[3060 510]);

uu=u.*co-v.*si;
vv=u.*si+v.*co;


if k=30, fclose(ufid); fclose(vfid);end;
end


