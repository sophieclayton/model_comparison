% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all

% set the in/output directories
indir='/scratch/sclayton/coarse_rerun2/extract/Phyto/';
outdir='/scratch/sclayton/coarse_rerun2/extract/monthly/';

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']); 
plankton=plankton_ini_char_nohead;

sm=find(plankton(:,3)==0);
bi=find(plankton(:,3)==1);

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
%HFCR=squeeze(HFCR(1,:,:))';

monthly_big=zeros(360,160,12);
monthly_small=zeros(360,160,12);

days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

% load in data to be averaged
for m=1:12;
    
    for day=startday(m):1:endday(m);
        in=sprintf('%sIntPhyto.1999.%04d.data',indir,day);
        tmp=readbin(in,[360 160 78]);
        small=squeeze(nansum(tmp(:,:,sm),3));
        big=squeeze(nansum(tmp(:,:,bi),3));
        clear tmp
        big(HFCR==0)=NaN;
        small(HFCR==0)=NaN;
        
%         for p=1:78;
%             tmptmp=tmp(:,:,p);
%             tmptmp(HFCR==0)=NaN;
%             tmp(:,:,p)=tmptmp;
%             clear tmptmp
%         end

        monthly_big(:,:,m)=monthly_big(:,:,m)+big; 
        monthly_small(:,:,m)=monthly_small(:,:,m)+small;
    end
    clear tmp
    monthly_big(:,:,m)=monthly_big(:,:,m)./days(m+1);
    monthly_small(:,:,m)=monthly_small(:,:,m)./days(m+1);
    m
end

out=sprintf('%sIntBig.monthly.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly_big,'float32');
fclose(fid);

out=sprintf('%sIntSmall.monthly.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly_small,'float32');
fclose(fid);

