addpath /home/stephd/Diags_darwin_igsm/seawater_ver3_0

outdir='/scratch/sclayton/coarse_rerun/extract/monthly/';

clear all
vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
vars(3).name = 'Z';
vars(4).name = 'HFacC';
vars(5).name = 'rA';
vars(6).name = 'Depth';
vars(7).name = 'drF';
vars(8).name = 'dxC';
vars(9).name = 'dxG';
vars(10).name = 'dyC';
vars(11).name = 'dyG';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

% work out the indexing for beg/end 1999
% indices start in 1992 to end of 1999

it1=(365*5+366*2)*24;
it2=it1+(365*24);

year=1999;
it=1;
for i=it1:6:it2;
    it
    insst=sprintf('/scratch/heimbach/ecco/run_c61/diag_iter73_dir_forw_6hr_all/dir_forw_DDtheta/DDtheta.00000%05d.data',i);
    tmp=readbin(insst,[360 160 23]);
    sst(:,:,it)=tmp(:,:,1);
    clear tmp
it=it+1;
end
    
avesst = nanmean(sst,3);

out=sprintf('/scratch/sclayton/coarse_rerun/CRSST.1999.data'); 
fid=fopen(out,'w','ieee-be');
fwrite(fid,avesst,'float32');
fclose(fid);

% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[23 160 360]);
HFCR=squeeze(HFCR(1,:,:))';

monthly=zeros(360,160,21,12);
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
hours=days.*4;
startday=cumsum(hours)+1;
endday=cumsum(hours(2:end));

% load in data to be averaged
for m=1:12;
    
    for day=startday(m):1:endday(m);
        tmp=sst(:,:,day);
          
        tmp(HFCR==0)=NaN;
                 
        monthly(:,:,m)=monthly(:,:,m)+tmp;
    end
    clear tmp
    monthly(:,:,m)=monthly(:,:,m)./hours(m+1);
    
end
out=sprintf('%sSST.monthly.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);




