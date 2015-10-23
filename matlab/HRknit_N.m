% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields

   function [trac]=HRknit_N(it,n);

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
input=zeros(tnx,tny,tnz);
fid=fopen(in,'r','b');
input=fread(fid,tnx*tny*tnz,'real*4');
fclose(fid);
input=reshape(input,[tnx tny tnz]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

trac(:,xt+1,fc+1,:,yt+1,:)=input;

clear input in

end
if n==4, fclose(fid); end

trac=reshape(trac,[3060 510 30]);
end



