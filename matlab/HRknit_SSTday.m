% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields

function [u]=HRknit_SSTday(day);

ncs = 510;
tnx = 102;
tny = 51;
tnz = 50;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;

its=184176:72:210384;
it=its(day);

u=zeros(tnx,ntx,nfc,tny,nty);

for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/T/T.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
ufid=fopen(in,'r','ieee-be');
input=fread(ufid,[tnx tny],'real*4');
input=reshape(input,[tnx,1,1,tny,1]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

u(:,xt+1,fc+1,:,yt+1)=u(:,xt+1,fc+1,:,yt+1)+input;

%p(:,xt+1,fc+1,:,yt+1)=p(:,xt+1,fc+1,:,yt+1) +  input;
clear input in

end


u=reshape(u,[3060 510]);


