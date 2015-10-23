% script for plotting Kuroshio transects of phyto types

clear all

load('/home/jahn/matlab/cube66.mat','lonc','latc');

is=3*510+1:3*510+102;
js=1:102;

ll=25;

lonc=lonc(is,js);
latc=latc(is,js);
lat=latc(:,50);

type=1:78;

% choose the year and month of the data you want
year=1997;
month=01;
 
indir=['kuroshio_hr'];
infile=['TRANSECT'];

fhr=sprintf('%s/%s.%04d%02d.bin',indir,infile,year,month);
transect=readbin(fhr,[78 102]);

zz=find(transect<0);
transect(zz)=0;

% plot the transect with latitude on the y axis and phyto type on the x
% axis
figure;
pcolor(type,lat,log10(transect)');
shading flat;
mm=max(caxis);
caxis([-6 mm]);
colorbar;


