% script to calculate the difference in the proportion of k and r adapted species between the coarse resolution and eddy permitting model runs, with the eddy permitting run output interpolated to the coarse grid

clear all

upindir=['high_res/global.intr.mon'];
subdir=['intrTRAC'];
infile=['_mon'];

load('/home/jahn/matlab/cube66.mat','lonc','latc');

lon=reshape(lonc,3060*510,1);
lat=reshape(latc,3060*510,1);

% set the region of interest witha range of lat and lon coordinates
coord=find(lon>=140 & lon<=160 & lat>=30 & lat<=50);

x=lon(coord);
y=lat(coord);
LON=[140:0.167:160];
LAT=[50:-0.167:30]';

[LONgrid,LATgrid]=meshgrid(LON,LAT);

for tracer=1:99;
for year=1994:1999;
    for month=01:12;
fhr=sprintf('%s/%s%02d/%s%02d%s.%04d%02d.data',upindir,subdir,tracer,subdir,tracer,infile,year,month);
tra=readbin(fhr,[3060*510 1]);

tra_kuro=tra(coord);
region=griddata(x,y,tra,LON,LAT);

% write the data out to a bin file, [160 360 2], with the k and the r difference
outdir=['kuroshio_hr'];
outfile=['TRA_KURO'];
fo=sprintf('%s/%s%02d.%04d%02d.bin',outdir,outfile,tracer,year,month);
fid=fopen(fo,'w','b');
fwrite(fid,tra_kuro,'float32');
fclose(fid);

    end
end
end

