% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

%clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/intrPP/';
outdir='/scratch/sclayton/high_res/monthly/';

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
% HFHR=HFHR(:,:,1);
iter=[184176:72:210384];

days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));

%it=[184176:72:210384];
annual=zeros(3060,510);
% load in data to be averaged
%for it=184176:72:210384;
for m=1:12;
    monthly=zeros(3060,510);
    
    for day=iter(startday(m)):72:iter(endday(m));
        in=sprintf('%sday.%010d.data',indir,day);
        tmp=readbin(in,[3060 510]);
        
        %         for p=1:21;
        %             tmptmp=tmp(:,:,:,p);
        %             tmptmp(HFHR==0)=NaN;
        %             tmp(:,:,p)=tmptmp;
        %             clear tmptmp
        %         end
        
        monthly=monthly+tmp;
        
    end
    clear tmp
    monthly=monthly./days(m+1);
    monthly(HFHR==0)=NaN;
    annual=annual + monthly;
    
    out=sprintf('%sintPP.monthly.1999%02d.data',outdir,m);
    fid=fopen(out,'w','ieee-be');
    fwrite(fid,monthly,'float32');
    fclose(fid);
    m
    clear monthly
    
end

annual=annual./12;

out=sprintf('%sintPP.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,annual,'float32');
fclose(fid);
