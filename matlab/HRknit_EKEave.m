% script to make global annual averaged fields of EKE from ECCO2

clear all

HRumean=readbin('/scratch/sclayton/high_res/UVELrot_1999.data',[3060 510]);
HRvmean=readbin('/scratch/sclayton/high_res/VVELrot_1999.data',[3060 510]);

EKE=zeros(3060,510);
U=zeros(3060,510);
V=zeros(3060,510);

for d=2:365;
    
inu=sprintf('/scratch/sclayton/high_res/UVEL/UVELrot.%04d.1999.data',d);
inv=sprintf('/scratch/sclayton/high_res/VVEL/VVELrot.%04d.1999.data',d);

U=readbin(inu,[3060 510]);% - HRumean;
V=readbin(inv,[3060 510]);% - HRvmean;
d

EKE=EKE+(0.5*(U.^2+V.^2));
clear inu inv U V uu vv

end

EKE=EKE./364;