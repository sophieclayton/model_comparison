% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu


% set the in/output directories
indir='/scratch/sclayton/coarse_rerun2/extract/Phyto/';
outdir='/scratch/sclayton/coarse_rerun2/extract/monthly/';

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
%HFCR=squeeze(HFCR(1,:,:))';

monthly=zeros(360,160,78,12);
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

% load in data to be averaged
for m=1:12;
    
    for day=startday(m):1:endday(m);
        in=sprintf('%sIntPhyto.1999.%04d.data',indir,day);
        tmp=readbin(in,[360 160 78]);
        
        for p=1:78;
            tmptmp=tmp(:,:,p);
            tmptmp(HFCR==0)=NaN;
            tmp(:,:,p)=tmptmp;
            clear tmptmp
        end
        
        monthly(:,:,:,m)=monthly(:,:,:,m)+tmp;
    end
    clear tmp
    monthly(:,:,:,m)=monthly(:,:,:,m)./days(m+1);
    
end
out=sprintf('%sIntPhyto.monthly.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);
