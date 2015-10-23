% Script to output annual, seasonal and monthly average and anomaly values for U,V,W, and nutrients from 1^o darwin model output
% Sophie Clayton, June 2011
% sclayton@mit.edu


%clear all

% velocity data is in 6hrly format and time steps beginning from Jan 1992
% work out the indexing for beg/end 1999
% indices start in 1992 to end of 1999

it1=(365*5+366*2)*24;
it2=it1+(365*24);
i=it1:6:it2;

year=1999;
step=6;

iit=0;
nz=23;

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160 23]);

%HFCR=squeeze(HFCR(:,:,1));

annual=zeros(360,160,23);
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
hours=days.*4;
startday=cumsum(days)+1;
endday=cumsum(days(2:end));
alldays=1:365;
monthly=zeros(360,160,23,12);

for m=1:12;
in=sprintf('/scratch/sclayton/coarse_rerun/extract/KPP/log10KPPdiffs_monthly.1999%02d.data',m);
    KPP_ave = readbin(in,[360 160 23]);
    
    for day=startday(m):endday(m);
    U=zeros(360,160,23);
        
        for hourly=i((day*4)-3):6:i(day*4);
           inU=sprintf('/scratch/heimbach/ecco/run_c61/diag_iter73_dir_forw_6hr_all/dir_forw_DKPPdiffs/DKPPdiffs.00000%05d.data',hourly);
           tmp=readbin(inU,[360 160 23]);
           U=U+log10(tmp);
        end %hourly

    U=U./4;
    U(HFCR==0)=NaN;

    monthly(:,:,:,m)=monthly(:,:,:,m)+(KPP_ave-U).^2;

    out=sprintf('/scratch/sclayton/coarse_rerun/extract/KPP/log10KPPdiffs_daily.1999.%04d.data',day);
    fid=fopen(out,'w','ieee-be');
    fwrite(fid,U,'float32');
    fclose(fid);

    clear U
    end %day

    monthly(:,:,:,m)=monthly(:,:,:,m)./days(m+1);
    outm=sprintf('/scratch/sclayton/coarse_rerun/extract/KPP/log10KPPvar_monthly.1999%02d.data',m);
    fid=fopen(outm,'w','ieee-be');
    fwrite(fid,monthly(:,:,:,m),'float32');
    fclose(fid);
    m
    %annual=annual+monthly(:,:,:,m);
end %m

% annual=annual./12;
% outa='/scratch/sclayton/coarse_rerun/extract/KPP/CR_KPPvar.1999.data';
% fid=fopen(outa,'w','ieee-be');
% fwrite(fid,annual,'float32');
% fclose(fid);



