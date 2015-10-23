% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields

function [N]=HRknit_phy(it,k);

ncs = 510;
tnx = 102;
tny = 51;
tnz = 30;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;
    
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/ecco2/cube84/tiles/L30/res_%04d/ptracers/ptracers_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny);
fid=fopen(in,'r','b');
input=fread(in,[tnx tny],'real*4');
fclose(fid);

input=reshape(input,[tnx tny]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

N(:,xt+1,fc+1,:,yt+1)=input;

clear input in

end
day=day+1

N=reshape(N,[3060 510]);

end



