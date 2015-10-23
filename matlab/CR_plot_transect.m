% script to plot monthly transects of log10 KPPdiffS from ECCO-Godae

clear all

% set the longitude needed for the transect
lon1=320;
lat1=30;
lat2=60;

vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
vars(3).name = 'drF';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

XX=repmat(X,1,160);
YY=(repmat(Y,1,360))';

lon=find(XX>=lon1-0.25 & XX<=lon1+0.25);

HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160 23]);

depth=zeros(24,1);
depth(2:end,1)=cumsum(drF);
depth(1,1)=0;
depth=(depth(1:end-1)+depth(2:end))./2;

[a,b]=size(XX);
depth=repmat(depth,1,[a,b]);
depth=permute(depth,[2 3 1]);

for z=1:23;
    YY(:,:,z)=YY(:,:,1);
end

month=['JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC'];
figure;

for m=1:12;
    in=sprintf('/scratch/sclayton/coarse_rerun/extract/KPP/log10KPPdiffs_monthly.1999%02d.data',m);
    kpp=readbin(in,[360 160 23]);
    kpp(HFCR==0)=NaN;
    kpp=kpp(:,:,2:end);
    
    subplot(4,3,m);
    pcolor(squeeze(YY(lon1,:,2:end)),squeeze(depth(lon1,:,2:end)),squeeze(kpp(lon1,:,:)));
    shading flat
    set(gca,'YDir','reverse');
    axis([lat1 lat2 10 500]);
    title(month(m,:));
    colorbar;
    caxis([-4.5 0])
        
end