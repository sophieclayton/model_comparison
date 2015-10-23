% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu


% set the in/output directories
indir='/scratch/sclayton/coarse_rerun/extract/NutsZoo/';
outdir='/scratch/sclayton/coarse_rerun/extract/NutsZoo/monthly/';

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[23 160 360]);
%HFCR=squeeze(HFCR(1,:,:))';
HFCR=permute(HFCR,[3 2 1]);

monthly=zeros(360,160,23,21);
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

% load in data to be averaged
for m=1:12;
    
    for day=startday(m):1:endday(m);
        in=sprintf('%sNutsZoo.1999.%04d.data',indir,day);
        tmp=readbin(in,[360 160 23 21]);
%        tmp=squeeze(tmp(:,:,1,:));
        
        for p=1:21;
            tmptmp=tmp(:,:,:,p);
            tmptmp(HFCR==0)=NaN;
            tmp(:,:,:,p)=tmptmp;
            clear tmptmp
        end %p
        
        monthly=monthly+tmp;
    end %day
    clear tmp
    monthly(:,:,:,:)=monthly(:,:,:,:)./days(m+1);

    out=sprintf('%sNutsZoo.monthly.1999%04d.data',outdir,m);
    fid=fopen(out,'w','ieee-be');
    fwrite(fid,monthly,'float32');
    fclose(fid);
    m

end % monthly


