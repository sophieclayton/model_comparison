% script to calculate limiting nutrient
% darwin model
% Sophie Clayton, December 2012
% sclayton@mit.edu

clear all

% set the in/output directories
indir='/scratch/sclayton/coarse_rerun2/';
outdir='/scratch/sclayton/coarse_rerun2/';

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']);
plankton=plankton_ini_char_nohead;

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);

% load in data to be averaged
monthly=zeros(360,160,12);

%mallphyt=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Int55m/Int55mPhyto.1999.data',[360 160 78])./55;
mallphyt=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
mallphyt=squeeze(mallphyt(:,:,1,:));
mtotphy=nansum(mallphyt,3);

%nuts=readbin('/scratch/sclayton/coarse_rerun2/extract/NutsZoo/Int55m/Int55mNutsZoo.1999.data',[360 160 21])./55;
nuts=readbin('/scratch/sclayton/coarse_rerun2/extract/NutsZoo/NutsZoo.1999.data',[360 160 23 21]);
nuts=squeeze(nuts(:,:,1,:));
mnut=nuts(:,:,1:4);clear nuts;

totpop=zeros(360,160);

plimp=zeros(360,160); plimn=plimp; plimfe=plimp; plimsi=plimp;
mp=zeros(360,160);
type=1:78;

for x=1:360;for y=1:160;
tmp=(max(max(squeeze(mallphyt(x,y,:))))); 
dom=find(tmp==squeeze(mallphyt(x,y,:)));
if isscalar(dom);
mp(x,y)=type(dom);
else mp(x,y)=NaN;
end
clear tmp dom
end;end

for ip=1:78;

    fracpop=squeeze(mallphyt(:,:,ip))./squeeze(mtotphy(:,:));
    totpop=totpop+fracpop;
    limp=squeeze(mnut(:,:,1))./(squeeze(mnut(:,:,1))+plankton(ip,10));
    limn=squeeze(mnut(:,:,2))./(squeeze(mnut(:,:,2))+plankton(ip,11));
    limfe=squeeze(mnut(:,:,3))./(squeeze(mnut(:,:,3))+plankton(ip,12).*10^-3);
    
    if (plankton(ip,1)==1);
        limsi=squeeze(mnut(:,:,4))./(squeeze(mnut(:,:,4))+plankton(ip,13));
    else
        limsi=1;
    end
    
    % biomass averaged values of most limiting nutrient
    clear fi, fi=find(limp<limn & limp<limfe & limp<limsi);
    plimp(fi)=plimp(fi)+fracpop(fi);
    clear fi, fi=find(limn<limp & limn<limfe & limn<limsi);
    plimn(fi)=plimn(fi)+fracpop(fi);
    clear fi, fi=find(limfe<limn & limfe<limp & limfe<limsi);
    plimfe(fi)=plimfe(fi)+fracpop(fi);
    clear fi, fi=find(limsi<limn & limsi<limfe & limsi<limp);
    plimsi(fi)=plimsi(fi)+fracpop(fi);
ip    
end % for ip

splimp(:,:)=plimp;
splimn(:,:)=plimn;
splimfe(:,:)=plimfe;
splimsi(:,:)=plimsi;
limall=plimp+plimn+plimsi+plimfe;

CR_lim=zeros(360,160);
CR_lim(plimp>plimn & plimp>plimfe & plimp>plimsi)=1;
CR_lim(plimn>plimp & plimn>plimfe & plimn>plimsi)=2;
CR_lim(plimfe>plimp & plimfe>plimn & plimfe>plimsi)=3;
CR_lim(plimsi>plimp & plimsi>plimn & plimsi>plimfe)=4;

figure;pcolor(CR_lim');shading flat;caxis([1 4]);colorbar

out=sprintf('%slimNUT_55m.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,CR_lim,'float32');
fclose(fid);

