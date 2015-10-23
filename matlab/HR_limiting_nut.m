% script to calculate limiting nutrient
% darwin model
% Sophie Clayton, December 2012
% sclayton@mit.edu

%clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/';
outdir='/scratch/sclayton/high_res/';

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']);
plankton=plankton_ini_char_nohead;

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);

% load in data to be averaged
monthly=zeros(3060,510,12);

%alltrac=readbin('/scratch/sclayton/high_res/extract/IntTrac50m.1999.data',[3060 510 99])./50;
mallphyt=readbin('/scratch/sclayton/high_res/Phyto/AveSurfPhyto.1999.data',[3060 510 78]);
%mallphyt=alltrac(:,:,22:99);
mtotphy=nansum(mallphyt,3);

nuts=readbin('/scratch/sclayton/high_res/Nuts/AveSurfNutrients.1999.data',[3060 510 21]);
%nuts=alltrac(:,:,1:21);
mnut=nuts(:,:,1:4);clear nuts;

clear alltrac

totpop=zeros(3060,510);

for ip=1:78;
    fracpop=squeeze(mallphyt(:,:,ip))./squeeze(mtotphy(:,:));
    totpop=totpop+fracpop;
    limp=squeeze(mnut(:,:,1))./(squeeze(mnut(:,:,1))+plankton(ip,10));
    limn=squeeze(mnut(:,:,2))./(squeeze(mnut(:,:,2))+plankton(ip,11));
    limfe=squeeze(mnut(:,:,3))./(squeeze(mnut(:,:,3))+plankton(ip,12)*1e-3);
    
    if (plankton(ip,1)==1);
        limsi=squeeze(mnut(:,:,4))./(squeeze(mnut(:,:,4))+plankton(ip,13));
    else
        limsi=1;
    end
    
    % biomass averaged values of most limiting nutrient
    if (ip==1),
        plimp=zeros(size(limp)); plimn=plimp; plimfe=plimp; plimsi=plimp;
        dplimp=plimp; dplimfe=plimp; dplimsi=plimp;
    end % if
    clear fi, fi=find(limp<limn & limp<limfe & limp<limsi);
    plimp(fi)=plimp(fi)+fracpop(fi);
    clear fi, fi=find(limn<limp & limn<limfe & limn<limsi);
    plimn(fi)=plimn(fi)+fracpop(fi);
    clear fi, fi=find(limfe<limn & limfe<limp & limfe<limsi);
    plimfe(fi)=plimfe(fi)+fracpop(fi);
    clear fi, fi=find(limsi<limn & limsi<limfe & limsi<limp);
    plimsi(fi)=plimsi(fi)+fracpop(fi);
    
end % for ip

limall=plimp+plimn+plimsi+plimfe;

HR_lim=zeros(3060,510);
HR_lim(plimp>plimn & plimp>plimfe & plimp>plimsi)=1;
HR_lim(plimn>plimp & plimn>plimfe & plimn>plimsi)=2;
HR_lim(plimfe>plimp & plimfe>plimn & plimfe>plimsi)=3;
HR_lim(plimsi>plimp & plimsi>plimn & plimsi>plimfe)=4;

 out=sprintf('%slimNUTsurf.1999.data',outdir);
 fid=fopen(out,'w','ieee-be');
 fwrite(fid,HR_lim,'float32');
 fclose(fid);

