% this is a script to extract a specific region of interest from the output
% of the eddy permitting MIT Ecosystem model run. It also regrids the data
% onto a regular lat/lon grid

clear all

% set the input directories
upindir=['/scratch/sclayton/high_res/'];
subdir=['KPP/'];
infile=['KPP.monthly'];

% set the output directories
outdir=['/scratch/sclayton/high_res/'];
outsubdir=['gridded/'];
outfile=['KPP.monthly'];

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


for year=1999;
    for month=1:12;
fhr=sprintf('%s%s%s.%04d%02d.data',upindir,subdir,infile,year,month);
tra=readbin(fhr,[3060 510 50]);

tra_grid=tra(coord);
region=griddata(x,y,tra_grid,LON,LAT,'nearest');

% write the gridded data out to a bin file

fo=sprintf('%s%s%s.%04d%02d.bin',outdir,outsubdir,outfile,year,month);
fid=fopen(fo,'w','b');
fwrite(fid,region,'float32');
fclose(fid);

    end
end
end

