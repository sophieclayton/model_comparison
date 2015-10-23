% script to plot monthly transects of log10 KPPdiffS from ECCO2

clear all

lon1=320;
lon2=340;
lat1=-80;
lat2=30;

[LONi,LATi,depth,region]=KPP_transect(lon1,lon2,lat1,lat2);
depth=depth.*-1;

month=['JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC'];
figure;

for m=1:12;
    
    subplot(4,3,m);
    pcolor(squeeze(LATi(:,1,:)),squeeze(depth(:,1,:)),squeeze(region(:,1,:,m)));shading flat
    set(gca,'YDir','reverse');
    axis([lat1 lat2 5 500]);
    title(month(m,:));
    colorbar;
    caxis([-4.5 0]);
    
end
    
