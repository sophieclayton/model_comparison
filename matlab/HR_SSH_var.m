clear all

% set the in/output directories

outdir='/scratch/sclayton/high_res/SSH/';
indir='/scratch/jahn/ecco2/cube84/assembled/L1/ETAN/';
load /home/jahn/matlab/cube66lonlat long latg

nx=3060;
ny=510;

HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
it=[184176:72:210384];

T=zeros(3060,510);

% load in data to be averaged
for day=1:365;
    ii=it(day);
    in=sprintf('%sETAN_day.%010d.data',indir,ii);
    T=T+readbin(in,[3060 510]);
    day
end

T=T./length(it);

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

out=sprintf('%sSSH.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,T,'float32');
fclose(fid);

