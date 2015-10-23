% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all

% set the in/output directories
indir='/scratch/sclayton/coarse_rerun2/extract/PP/';
outdir='/scratch/sclayton/coarse_rerun2/extract/monthly/';

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
%HFCR=squeeze(HFCR(1,:,:))';

monthly=zeros(360,160,12);
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

% load in data to be averaged
for m=1:12;
    
    for day=startday(m):1:endday(m);
        in=sprintf('%sIntPP.1999.%04d.data',indir,day);
        tmp=readbin(in,[360 160]);
        tmp(HFCR==0)=NaN;
        
%         for p=1:78;
%             tmptmp=tmp(:,:,p);
%             tmptmp(HFCR==0)=NaN;
%             tmp(:,:,p)=tmptmp;
%             clear tmptmp
%         end
%         
        monthly(:,:,m)=monthly(:,:,m)+tmp;
    end
    clear tmp
    monthly(:,:,m)=monthly(:,:,m)./days(m+1);
    
end

for m=1:12;
    tmp=monthly(:,:,m);tmp(HFCR==0)=NaN;
    monthly(:,:,m)=tmp;
end

out=sprintf('%sIntPP.monthly.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);

