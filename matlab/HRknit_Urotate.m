% script to make global annual averaged fields of EKE from ECCO2

%clear all


co=readbin('/scratch/jahn/grid/cube84/AngleCS.data',[3060 510]);
si=readbin('/scratch/jahn/grid/cube84/AngleSN.data',[3060 510]);

% HRumean=readbin('/scratch/sclayton/high_res/UVEL_1999.data',[3060 510 1]);
% HRvmean=readbin('/scratch/sclayton/high_res/VVEL_1999.data',[3060 510 1]);
% 
% EKE=zeros(3060,510,365);
uave=zeros(3060,510);
vave=zeros(3060,510);

for day=2:365;
    
inu=sprintf('/scratch/sclayton/high_res/UVEL/UVEL.%04d.1999.data',day);
inv=sprintf('/scratch/sclayton/high_res/VVEL/VVEL.%04d.1999.data',day);

U=readbin(inu,[3060 510]);% - HRumean;
V=readbin(inv,[3060 510]);% - HRvmean;

uu=U.*co-V.*si;
vv=U.*si+V.*co;

out=sprintf('/scratch/sclayton/high_res/UVEL/UVELrot.%04d.1999.data',day);
fid=fopen(out,'w','ieee-be');
fwrite(fid,uu,'real*4');
fclose(fid);
clear out 

out=sprintf('/scratch/sclayton/high_res/VVEL/VVELrot.%04d.1999.data',day);
fid=fopen(out,'w','ieee-be');
fwrite(fid,vv,'real*4');
fclose(fid);

uave=uave+uu;
vave=vave+vv;

day

%EKE(:,:,d)=0.5*(U.^2+V.^2);
clear out inu inv U V uu vv

end

uave=uave./364;
vave=vave./364;

out='/scratch/sclayton/high_res/UVELrot_1999.data';
fid=fopen(out,'w','ieee-be');
fwrite(fid,uave,'real*4');
fclose(fid);

out='/scratch/sclayton/high_res/VVELrot_1999.data';
fid=fopen(out,'w','ieee-be');
fwrite(fid,vave,'real*4');
fclose(fid);
