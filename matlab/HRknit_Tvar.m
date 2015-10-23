% script to make global fields from tiled cube-sphere ECCO2 model output fields



%clear all

ncs = 510;
tnx = 102;
tny = 51;
tnz = 30;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;
np = 78;

p=zeros(tnx,ntx,nfc,tny,nty);


for itile=0:299;

% read in tiled files
in=sprintf('/scratch/sclayton/high_res/Tvar/T_var.1999.%03d.001.data',itile);
input=zeros(tnx,tny);
input=readbin(in,[tnx tny]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

p(:,xt+1,fc+1,:,yt+1)=input;
clear input
itile
end

HRsstvar=reshape(p,[3060,510]);









