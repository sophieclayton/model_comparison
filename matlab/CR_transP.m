% script to calculate transportP from daily output of the 1 degree darwin model run

clear all

HFCR = readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
HFCRp=repmat(HFCR,[1 1],78);

transp=zeros(360,160,78);
grow = zeros(360,160,78);

% read phyto biomass and unet by type
p=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
p=squeeze(p(:,:,1,:));p(p<0)=0;
p(HFCRp==0)=NaN;


unet = readbin('/scratch/sclayton/coarse_rerun2/extract/MU/munetP.z1.1999.data',[360,160,78]);
unet(HFCRp==0)=NaN;
unet=unet.*(60*60*24); % convert to mmol P/m3/day

% calculate annual average trans P
dpdt=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/DPDT.1999.data',[360 160 23 78]);
dpdt = squeeze(dpdt(:,:,1,:));
dpdt(HFCRp==0)=NaN;
grow = unet;

clear HFCRp

transp = grow - (dpdt);

% write out trans P
% out = ('/scratch/sclayton/coarse_rerun2/extract/Phyto/TRANSP.1999.data');
% fid=fopen(out,'w','ieee-be');
% fwrite(fid,transp,'float32');
% fclose(fid);

% find phyto/areas where transport is larger than growth
transp=abs(transp);
grow=abs(grow);
dpdt=abs(dpdt);

mapt=zeros(360,160,78);
mapt(transp > grow & p>10^-12)=1;
mapg=zeros(360,160,78);
mapg(grow > transp & p>10^-12)=1;

mapt=sum(mapt,3);
mapt(HFCR==0)=NaN;
mapg=sum(mapg,3);
mapg(HFCR==0)=NaN;


HFCR = readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);


figure;pcolor(mapt');shading flat;title('number phyto with transP>>\mu_{netP}')
figure;pcolor(mapg');shading flat;title('number phyto with transP<<\mu_{netP}')





                                            