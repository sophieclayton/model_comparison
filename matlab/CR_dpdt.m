% script to calculate dp/dt from daily output of the 1 degree darwin model run

clear all

% pre-assign matrices
p1=zeros(360,160,23,78);
p2=zeros(360,160,23,78);
% dpdt=zeros(360,160,23,78,364);
dpdt=zeros(360,160,23,78);

% start time stepping to read in files
for day=1:364;

if day==1, 
in1=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',day);
p1=readbin(in1,[360 160 23 78]);
end

in2=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',day+1);
p2=readbin(in2,[360 160 23 78]);
tmp=p2-p1;
dpdt=dpdt+tmp;
p1=p2;
% write out the daily dpdt
out=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/DPDT.1999.%04d.data',day+1);
fid=fopen(out,'w','ieee-be');
fwrite(fid,tmp,'float32');
fclose(fid);

clear p2 tmp out 
day
end

% calculate annual average dpdt
dpdt=dpdt./364;
fid=fopen('/scratch/sclayton/coarse_rerun2/extract/Phyto/DPDT.1999.data','w','ieee-be');
fwrite(fid,dpdt,'float32');
fclose(fid);

