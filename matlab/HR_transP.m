% script to calculate transportP from daily output of the 1 degree darwin model run
clear all

HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
HFHRp=repmat(HFHR,[1 1],78);

transp=zeros(3060,510,78);
grow = zeros(3060,510,78);

% read phyto biomass and unet by type
p=readbin('/scratch/sclayton/high_res/Phyto/AveSurfPhyto.1999.data',[3060 510 78]);
p(HFHRp==0)=NaN;
p(p<0)=0;

unet=HRknit_MunetPave(1);
unet(HFHRp==0)=NaN;

% calculate annual average trans P
dpdt=readbin('/scratch/sclayton/high_res/DPDT.1999.data',[3060 510 78]);
dpdt(HFHRp==0)=NaN;
grow = unet.*(60*60*24);

clear HFCRp unet

transp = grow - dpdt;

% write out trans P
out = ('/scratch/sclayton/high_res/TRANSP.1999.data');
fid=fopen(out,'w','ieee-be');
fwrite(fid,transp,'float32');
fclose(fid);

% find phyto/areas where transport is larger than growth
transp=abs(transp);
grow=abs(grow);

mapt=zeros(3060,510,78);
mapt(transp > grow.*100 & p>10^-12)=1;
mapg=zeros(3060,510,78);
mapg(grow > transp.*100 & p>10^-12)=1;

mapt= sum(mapt,3);
mapt(HFHR==0)=NaN;
mapg=sum(mapg,3);
mapg(HFHR==0)=NaN;

% you are poisonous little beach ball. 
load /home/jahn/matlab/cube66lonlat long latg
figure;plotcube(long,latg,mapt,360);shading flat;title('number phyto with transP>>\mu_{netP}')
figure;plotcube(long,latg,mapg,360);shading flat;title('number phyto with transP<<\mu_{netP}')




                                            