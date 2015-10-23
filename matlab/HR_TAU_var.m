clear all

% set the in/output directories

outdir='/scratch/sclayton/high_res/';
indir='/scratch/jahn/ecco2/cube84/assembled/L1/';
load /home/jahn/matlab/cube66lonlat long latg

nx=3060;
ny=510;

HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
it=[184176:72:210384];

Tx=zeros(3060,510);
Ty=zeros(3060,510);

% load in data to be averaged
for day=1:365;
    ii=it(day);
    in=sprintf('%soceTAUX/oceTAUX_day.%010d.data',indir,ii);
    Tx=Tx+readbin(in,[3060 510]);
        
    in=sprintf('%soceTAUY/oceTAUY_day.%010d.data',indir,ii);
    Ty=Ty+readbin(in,[3060 510]);
    day
    
end

Tx=Tx./length(it);
Ty=Ty./length(it);

% T_ave=nanmean(T,3);
% T_var = zeros(3060,510);

% for day=1:365;
%     T_var=T_var + (T(:,:,day)-T_ave).^2;
% end
% 
% T_var=(T_var./365);
% T_var(HFHR==0)=NaN;
% 
% out=sprintf('%sSSH_var.1999.data',outdir);
% fid=fopen(out,'w','ieee-be');
% fwrite(fid,T_var,'float32');
% fclose(fid);
% clear out

out=sprintf('%sTAUx.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,Tx,'float32');
fclose(fid);

out=sprintf('%sTAUy.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,Ty,'float32');
fclose(fid);

