% this is a script to extract a specific region of interest from the output
% of the eddy permitting MIT Ecosystem model run. It also regrids the data
% onto a regular lat/lon grid

clear all

% set the input directories
upindir=['high_res/global.intr.mon'];
subdir=['intrTRAC'];
infile=['_mon'];

% set the output directories
outdir=['kuroshio_hr'];
outsubdir=['gridded'];
outfile=['TRA'];

load('/home/jahn/matlab/cube66.mat','lonc','latc');

lon=reshape(lonc,3060*510,1);
lat=reshape(latc,3060*510,1);

% set the region of interest witha range of lat and lon coordinates
coord=find(lon>=143 & lon<=146 & lat>=30 & lat<=45);

x=lon(coord);
y=lat(coord);
LON=[143:0.167:146];
LAT=[40:-0.167:30]';

[LONgrid,LATgrid]=meshgrid(LON,LAT);

for tracer=01:99;
for year=1999;
    for month=10;
fhr=sprintf('%s/%s%02d/%s%02d%s.%04d%02d.data',upindir,subdir,tracer,subdir,tracer,infile,year,month);
tra=readbin(fhr,[3060*510 1]);

tra_grid=tra(coord);
region=griddata(x,y,tra_grid,LON,LAT,'nearest');

% write the gridded data out to a bin file

fo=sprintf('%s/%s/%s%02d.%04d%02d.bin',outdir,outsubdir,outfile,tracer,year,month);
fid=fopen(fo,'w','b');
fwrite(fid,region,'float32');
fclose(fid);

    end
end
end

