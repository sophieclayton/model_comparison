% script to make global annual averaged U, V fields from tiled cube-sphere ECCO2 model output fields


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

dpdt=zeros(3060,510,78);

for day=1:365;

in=sprintf('/scratch/sclayton/high_res/Phyto/DailySurfPhyto.1999.%04d.data',day);
uu=readbin(in,[3060 510 78]);

if day>1, dpdt=dpdt+(uu-tmp);end
clear tmp    
tmp=uu;  
clear uu
day
end

dpdt=dpdt./364;
disp('HR dpdt average done')

out = ('/scratch/sclayton/high_res/DPDT.1999.data');
fid=fopen(out,'w','ieee-be');
fwrite(fid,dpdt,'float32');
fclose(fid);



