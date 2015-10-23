% script to make global annual averaged U, V, W fields from tiled cube-sphere ECCO2 model output fields

% clear all

ncs = 510;
tnx = 102;
tny = 51;
tnz = 50;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;

for it=184176;
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/UVEL/UVEL_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny,tnz);
input=readbin(in,[tnx tny tnz]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

u(:,xt+1,fc+1,:,yt+1,:)=input;

%p(:,xt+1,fc+1,:,yt+1)=p(:,xt+1,fc+1,:,yt+1) +  input;
clear input in
itile
end
end

u=reshape(u,[3060 510 50]);

for it=184176;
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/VVEL/VVEL_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny,tnz);


input=readbin(in,[tnx tny tnz]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

v(:,xt+1,fc+1,:,yt+1,:)=input;

%p(:,xt+1,fc+1,:,yt+1)=p(:,xt+1,fc+1,:,yt+1) +  input;
clear input in
itile
end
end
v=reshape(v,[3060 510 50]);


for it=184176;
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/WVEL/WVEL_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny,tnz);
input=readbin(in,[tnx tny tnz]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

w(:,xt+1,fc+1,:,yt+1,:)=input;

%p(:,xt+1,fc+1,:,yt+1)=p(:,xt+1,fc+1,:,yt+1) +  input;
clear input in
itile
end
end
w=reshape(w,[3060 510 50]);









