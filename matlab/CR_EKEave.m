% script to make global annual averaged fields of EKE from ECCO Godae

CRumean=readbin('/scratch/sclayton/coarse_rerun/extract/U_annave.1999.data',[360 160 1]);
CRvmean=readbin('/scratch/sclayton/coarse_rerun/extract/V_annave.1999.data',[360 160 1]);

CREKE=zeros(360,160,365);
CRKE=zeros(360,160);
U=zeros(360,160);
V=zeros(360,160);

CRKE=0.5.*(CRumean.^2+CRvmean.^2);

for d=1:365;
    
inu=sprintf('/scratch/sclayton/coarse_rerun/extract/Udaily/Udaily.1999.%04d.data',d);
inv=sprintf('/scratch/sclayton/coarse_rerun/extract/Vdaily/Vdaily.1999.%04d.data',d);
U=readbin(inu,[360 160]) - CRumean;
V=readbin(inv,[360 160]) - CRvmean;
CREKE(:,:,d)=0.5*(U.^2+V.^2);
clear inu inv U V 
d
end

CREKE=mean(CREKE,3);

fid=fopen('/scratch/sclayton/coarse_rerun/EKE.1999.data','w','ieee-be');
fwrite(fid,CREKE,'float32');
fclose(fid)

clear fid

fid=fopen('/scratch/sclayton/coarse_rerun/KE.1999.data','w','ieee-be');
fwrite(fid,CRKE,'float32');
fclose(fid)