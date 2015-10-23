% plot the monthly MLD from the 1/6^o model

clear all

load /home/jahn/matlab/cube66lonlat long latg
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160 23]);
HFCR=(squeeze(HFCR(:,:,1)));

vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

mld=readbin('/scratch/sclayton/coarse_rerun/MLDmonthly.1999.data',[360 160 12]);

figure
for m=1:12;
    tmp=squeeze(mld(:,:,m));
    tmp(HFCR==0)=NaN;
    subplot(4,3,m);
    pcolor(X,Y,tmp');colorbar;caxis([0 300]);shading flat
    clear tmp
end
    
