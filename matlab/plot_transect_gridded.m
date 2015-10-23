% script for plotting Kuroshio transects of phyto types

clear all

% choose the year and month of the data you want
year=1999;
month=10;

% choose which lonigtude you want to take a section across
lon=145.5;
extra=0.15;

LAT=[40:-0.167:30]';
dd=length(LAT);

LON=[143:0.167:146];
ee=length(LON);

[LONgrid,LATgrid]=meshgrid(LON,LAT);

indir=['kuroshio_hr'];
subdir=['gridded'];
infile=['TRA'];

transect=nan(dd,99);

for tracer=01:99;
    
    fhr=sprintf('%s/%s/%s%02d.%04d%02d.bin',indir,subdir,infile,tracer,year,month);
    var=readbin(fhr,[60 18]);
    
    ll=find(LONgrid>=lon & LONgrid<=(lon+extra));
    transect(:,tracer)=var(ll);
   
      
end

zz=find(transect<0);
transect(zz)=0;

outdir=['kuroshio_hr'];
outsubdir=['transects'];
outfile=['TRANSECT_lon'];
fo=sprintf('%s/%s/%s%05d.%04d%02d.bin',outdir,outsubdir,outfile,lon,year,month);
fid=fopen(fo,'w','b');
fwrite(fid,transect,'float32');
fclose(fid);

% plot the transect with latitude on the y axis and phyto type on the x
% axis
type=1:78;

% figure;
% subplot(1,6,1)
% plot(transect(:,1),LAT);
% ylabel('latitude');xlabel('nitrate (mmol/m^2');
% subplot(1,6,2:6)
% pcolor(type,LAT,log10(transect(:,22:99)));
% shading flat;
% mm=max(caxis);
% caxis([-6 mm]);
% xlabel('model phytoplankton type');
% colorbar;
% title(['Model Phytoplankton Community Structure along ', num2str(lon), '^{o}E, October 1999']);

lat=LAT;
data=transect;

% call script to plot species distribution
mean_pos


