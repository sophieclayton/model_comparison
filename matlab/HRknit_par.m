% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields

   function [par]=HRknit_par(it);

ncs = 510;
tnx = 102;
tny = 51;
tnz = 30;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;

for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.top30/1999/res_%04d/PAR/PAR_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny,tnz);
fid=fopen(in,'r','b');
input=fread(in,tnx*tny*tnz,'real*4');
fclose(fid);
input=reshape(input,[tnx tny tnz]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

par(:,xt+1,fc+1,:,yt+1,:)=input;

clear input in

end
end

par=reshape(par,[3060 510 30]);





