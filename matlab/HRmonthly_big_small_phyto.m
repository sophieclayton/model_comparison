% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

%clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/global.intr.mon/';
outdir='/scratch/sclayton/high_res/monthly/';

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']); 
plankton=plankton_ini_char_nohead;

sm=find(plankton(:,3)==0)+21;
bi=find(plankton(:,3)==1)+21;

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);

% load in data to be averaged
monthly=zeros(3060,510,12);
type=1:99;

  for m=1:12;  
      
    for p=1:length(sm);
        t=type(sm(p));
        in=sprintf('%sintrTRAC%02d/intrTRAC%02d_mon.1999%02d.data',indir,t,t,m);
        tmp=readbin(in,[3060 510]);
        tmp(HFHR==0)=NaN;
        %         for p=1:21;
        %             tmptmp=tmp(:,:,:,p);
        %             tmptmp(HFHR==0)=NaN;
        %             tmp(:,:,p)=tmptmp;
        %             clear tmptmp
        %         end
        
        monthly(:,:,m)=monthly(:,:,m)+tmp;
        
    end
    clear tmp
        
    out=sprintf('%sintSmallP.monthly.1999%02d.data',outdir,m);
    fid=fopen(out,'w','ieee-be');
    fwrite(fid,squeeze(monthly(:,:,m)),'float32');
    fclose(fid);
    m
        
end

annual=nanmean(monthly,3);

out=sprintf('%sintSmallP.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,annual,'float32');
fclose(fid);

clear monthly annual

monthly=zeros(3060,510,12);

  for m=1:12;  
      
    for p=1:length(bi);
	t=type(bi(p));
        in=sprintf('%sintrTRAC%02d/intrTRAC%02d_mon.1999%02d.data',indir,t,t,m);
        tmp=readbin(in,[3060 510]);
        tmp(HFHR==0)=NaN;
        %         for p=1:21;
        %             tmptmp=tmp(:,:,:,p);
        %             tmptmp(HFHR==0)=NaN;
        %             tmp(:,:,p)=tmptmp;
        %             clear tmptmp
        %         end
        
        monthly(:,:,m)=monthly(:,:,m)+tmp;
        
    end
    clear tmp
        
    out=sprintf('%sintBigP.monthly.1999%02d.data',outdir,m);
    fid=fopen(out,'w','ieee-be');
    fwrite(fid,squeeze(monthly(:,:,m)),'float32');
    fclose(fid);
    m
        
end

annual=nanmean(monthly,3);

out=sprintf('%sintBigP.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,annual,'float32');
fclose(fid);

