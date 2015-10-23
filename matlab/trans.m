% script to pull out a transect of data from the kuroshio files for the EP
% ecosystem model run

% Sophie Clayton (sclayton@mit.edu)
% January 2010

clear all

transect=nan(78,102);

indir=['kuroshio_hr'];
infile=['TRA_KURO'];
for year=1994:1999;
    for month=01:12;
for tracer=22:99;
fhr=sprintf('%s/%s%02d.%04d%02d.bin',indir,infile,tracer,year,month);
tra=readbin(fhr,[102 102]);
tra=tra(:,50);

it=tracer-21;

transect(it,:)=tra;
end

outdir=['kuroshio_hr'];
outfile=['TRANSECT'];
fo=sprintf('%s/%s.%04d%02d.bin',outdir,outfile,year,month);
fid=fopen(fo,'w','b');
fwrite(fid,transect,'float32');
fclose(fid);
    end 
end