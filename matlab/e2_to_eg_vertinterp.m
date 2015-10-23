% script to interpolate regridded ECCO2 model output onto the same vertical grid as ECCO-GODAE
% Sophie Clayton, June 2100
% sclayton@mit.edu

clear all

% infield is the initial data in [360 160 50]
infield=readbin('/scratch/sclayton/HR2CR_initial/nz50/HR2CR_PHY_nz50.data',[360 160 50]);
% hrf is the E2 vertical grid [50 1]
hrc=readbin('/scratch/jahn/run/ecco2/cube84/d0006/run.13/RC.data',[50 1]);
% crf is the EG vertical grid [23 1]
crc=readbin('/scratch/sclayton/coarse_rerun/grid/RC.data',[23 1]);

[nx ny hnz] = size(infield);
cnz=23;
outfield=zeros(nx,ny,cnz);

for x=1:nx;
for y=1:ny;
outfield(x,y,:)=interp1(hrc',squeeze(infield(x,y,:)),crc');
end 
end

outfield(isnan(outfield))=0;

fid=fopen('/scratch/sclayton/HR2CR_initial/HR2CR_PHY_init.data','w','ieee-be');
fwrite(fid,outfield,'float32');
fclose(fid);




