% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/Nuts/';
outdir='/scratch/sclayton/high_res/Nuts/';

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510 50]);
HFHR=HFHR(:,:,1:30);

days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

% load in data to be averaged
for m=1:12;
    monthly=zeros(3060,510,21,30);    

    for day=startday(m):1:endday(m);
        in=sprintf('%sDailyNutrients.1999.%04d.data',indir,day-1);
        tmp=readbin(in,[3060 510 30 21]);
        
        for p=1:21;
            tmptmp=tmp(:,:,:,p);
            tmptmp(HFHR==0)=NaN;
            tmp(:,:,p)=tmptmp;
            clear tmptmp
        end
        
        monthly=monthly+tmp;

    end
    clear tmp
    monthly=monthly./days(m+1);
    

out=sprintf('%sNutsZoo.monthly.1999%02d.data',outdir,m);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);
m
clear monthly

end

