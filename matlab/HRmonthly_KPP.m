% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

%clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/KPP/';
outdir='/scratch/sclayton/high_res/KPP/';

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510 50]);
HFHR=HFHR(:,:,1:30);

days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

% load in data to be averaged
for m=1:12;
    monthly=zeros(3060,510,50);    

    for day=startday(m):1:endday(m);
        in=sprintf('%sKPPdiffs.%04d.1999.data',indir,day);
        tmp=readbin(in,[3060 510 50]);
        
        monthly=monthly+log10(tmp);

    end
    clear tmp
    monthly=monthly./days(m+1);
    

out=sprintf('%sKPP.monthly.1999%02d.data',outdir,m);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);
m
clear monthly

end

