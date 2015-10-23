% script to regrid the HR model output data onto a regular lat/lon grid
% using meshgrid.

% Sophie Clayton (sclayton@mit.edu) Januaury 2010

indir=['kuroshio_hr'];
infile=['TRA_KURO'];

% load in the coordinates for the model output points
load('/home/jahn/matlab/cube66.mat','long','latg');
is=3*510+1:3*510+102;
js=1:102;
x=long(is,js);
x=reshape(x,1,10404);
y=latg(is,js);
y=reshape(y,10404,1);

LON=[140:0.167:150];
LONgrid=nan(60,60);
for n=1:60;
    LONgrid(n,:)=LON(1,:);
end

clear n

LAT=[35:-0.167:25]';
LATgrid=nan(60,60);
for n=1:60
    LATgrid(:,n)=LAT(:,1);
end


for year=1994:1999;
    for month=01:12;
        for tracer=02;
            
            fhr=sprintf('%s/%s%02d.%04d%02d.bin',indir,infile,tracer,year,month);
            tra=readbin(fhr,[10404 1]);
            
            region=griddata(x,y,tra,LON,LAT);            
            
            outdir=['kuroshio_hr'];
            outfile=['REGION_grid_TRA'];
            fo=sprintf('%s/%s%02d.%04d%02d.bin',outdir,outfile,tracer,year,month);
            fid=fopen(fo,'w','b');
            fwrite(fid,region,'float32');
            fclose(fid);
        end
    end
end