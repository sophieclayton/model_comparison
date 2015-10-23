% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

%clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/global.intr.mon/';
outdir='/scratch/sclayton/high_res/monthly/';

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);

% load in data to be averaged
monthly=zeros(3060,510,12);
type=[8 12];
  for m=1:12;  
      
    for p=1:2;
        tt=type(p);
        in=sprintf('%sintrTRAC%02d/intrTRAC%02d_mon.1999%02d.data',indir,tt,tt,m);
        tmp=readbin(in,[3060 510]);
        tmp(HFHR==0)=NaN;
        %         for p=1:21;
        %             tmptmp=tmp(:,:,:,p);
        %             tmptmp(HFHR==0)=NaN;
        %             tmp(:,:,p)=tmptmp;
        %             clear tmptmp
        %         end
        
        monthly(:,:,m)=monthly(:,:,m)+tmp;
    p    
    end
    clear tmp
        
    out=sprintf('%sintZoo.monthly.1999%02d.data',outdir,m);
    fid=fopen(out,'w','ieee-be');
    fwrite(fid,squeeze(monthly(:,:,m)),'float32');
    fclose(fid);
    m
        
end

annual=nanmean(monthly,3);

out=sprintf('%sintZoo.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,annual,'float32');
fclose(fid);