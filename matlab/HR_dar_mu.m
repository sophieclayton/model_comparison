% script to back calculate the growth rates of the different phytoplankton types for the 1^o model output
% Sophie Clayton, June 2011
% sclayton@gmail.com

% test this using annual mean values of biological forcing


clear all

nx=3060;
ny=510;
nz=50;
np=78;

% import phytoplankton params (np,20)
plankton=load('/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat');
% parameters by column
% 1 - diatom
% 2 - diazotroph
% 3 - size
% 4 - mu, max growth rate
% 5 - mort, mortality rate
% 6 - Rnp, N:P ratio
% 7 - Rfep,Fe:P ratio
% 8 - Rsip, Si:P ratio
% 9 - wsink, sinking velocity
% 10 - KsP, phosphate half saturation
% 11 - KsN, 
% 12 - KsFe, Fe half saturation
% 13 - KsSi, Si half saturation
% 14 - palat1, % 15 - palat2, palatability
% 16 - Kpar, PAR saturation coefficient
% 17 - Kinh, PAR inhibition coefficient
% 18 - Topt, temperature optimum
% 19 - nsrc, nitrogen source {1:NH4&NO2 2:NH4 3:ALL Sources}
% 20 - np, phytoplankton number

% other parameters needed
psi=4.6; % ammonia/nitrate inhibition
v=0.1; % nitrate consumption cost

% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
%munetP=zeros(nx,ny,np,365);
ave_mortP=zeros(nx,ny,np);
ave_grazP=zeros(nx,ny,np);
ave_muP=zeros(nx,ny,np);
mortP=zeros(nx,ny,np);
grazP=zeros(nx,ny,np);
muP=zeros(nx,ny,np);

for day=1:365;

% load nutrient and zooplankton fields
inn=sprintf('/scratch/sclayton/high_res/Nuts/DailySurfNutrients.1999.%04d.data',day);
nfid=fopen(inn,'r','ieee-be');
nuts=fread(nfid,nx*ny*21,'real*4');
nuts=reshape(nuts,[nx ny 21]);
nuts(nuts<0)=0;
nuts(HFHR==0)=NaN;
fclose(nfid);

% import PAR fields
inpar=sprintf('/scratch/sclayton/high_res/',day);
parfid=fopen(inpar,'r','ieee-be');
par=fread(parfid,[nx ny],'real*4');
fclose(parfid);

% load phytoplankton fields
inphy=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',day);
pfid=fopen(inphy,'r','ieee-be');
phy=fread(pfid,nx*ny*nz*78,'real*4');
phy=reshape(phy,[nx ny nz 78]);
phy=squeeze(phy(:,:,1,:));
phy(phy<0)=0;
fclose(pfid);

% load in temperature
int=sprintf('/scratch/sclayton/coarse_rerun/extract/Temp/Temp_daily.1999.%04d.data',day);
tfid=fopen(int,'r','ieee-be');
temp=fread(tfid,[nx ny],'real*4');
fclose(tfid);


par(HFCR==0)=NaN;
temp(HFCR==0)=NaN;

A1=zeros(nx,ny);
A2=zeros(nx,ny);
for p=1:np;
A1=A1+(plankton(p,14).*phy(:,:,p));
A2=A2+(plankton(p,15).*phy(:,:,p));
end
clear phy

fid=fopen(inphy,'r','ieee-be');

% step through the different phytoplankton types
for p=1:np;

% load phytoplankton fields

phy=fread(fid,360*160*23,'real*4');
phy=reshape(phy,[360 160 23]);
phy=squeeze(phy(:,:,1));
phy(phy<0)=0;

% calculate nutrient limitation

kno2(p)=plankton(p,11);
knh4(p)=0.5.*plankton(p,11);

nh4lim=nuts(:,:,20)./(nuts(:,:,20)+knh4(p));
no2lim=nuts(:,:,21)./(nuts(:,:,21)+kno2(p));
no2no3lim=(nuts(:,:,21)+nuts(:,:,2))./(nuts(:,:,21)+nuts(:,:,2)+kno2(p)+plankton(p,11));

nlim(:,:,1)=nuts(:,:,1)./(nuts(:,:,1)+plankton(p,10));% PO4

% nitrogen source limitation
if plankton(p,19)==1, nlim(:,:,2)=no2lim.*exp(psi.*nuts(:,:,20))+nh4lim;% N
elseif plankton(p,19)==2, nlim(:,:,2)=nh4lim;
elseif plankton(p,19)==3, nlim(:,:,2)=no2no3lim.*exp(psi.*nuts(:,:,20))+nh4lim;% N
end
%clear no2lim no2no3lim nh4lim

nlim(:,:,3)=nuts(:,:,3)./(nuts(:,:,3)+(plankton(p,12)/1000));% FeT
nlim(:,:,4)=nuts(:,:,4)./(nuts(:,:,4)+plankton(p,13));% SiO4
nlim(nlim<0)=0;

if plankton(p,2)==1, abslim=min(nlim,[],3);
else absnlim=min(nlim(:,:,1:3),[],3);
end %plankton
%clear nlim 

% calculate temperature dependent growth

if plankton(p,3)==1, B=3*10^-4;
elseif plankton(p,3)==0, B=1*10^-3;end

tlim=0.33.*((1.04.^temp).*exp(-B.*(temp - plankton(p,18)).^4)-0.3);

% calculate light limitation
kpar=plankton(p,16)./10; % probably need to repmat these fields to be the same size as the domain
kinh=plankton(p,17)./1000;
Fo=((kpar+kinh)/kpar).*exp(-(kinh./kpar).*log((kinh/kpar+kinh)));
ilim=(1/Fo).*(1 - exp(-par.*kpar)).*(exp(-par.*kinh));

if ilim(:,:)>=1, ilim(:,:)=1;end

% calculate growth rate
muP(:,:,p)=(phy(:,:).*(1/plankton(p,4).*tlim(:,:).*ilim(:,:).*absnlim(:,:)));
ave_muP(:,:,p)=ave_muP(:,:,p)+muP(:,:,p);

%clear tlim ilim absnlim

% calculate grazing
if plankton(p,3)==1, gmax1=0.033; gmax2=0.2;
else gmax1=0.2; gmax2=0.2; 
end
kz=0.1;
gr1=gmax1*(plankton(p,14)*phy(:,:)./A1).*(A1./(A1+kz));
gr2=gmax2*(plankton(p,15)*phy(:,:)./A2).*(A2./(A2+kz));
grtot1=gr1.*nuts(:,:,8);
grtot2=gr2.*nuts(:,:,12);
clear gr1 gr2 

grazP(:,:,p)=grtot1+grtot2;
ave_grazP(:,:,p)=ave_grazP(:,:,p)+grazP(:,:,p);
%
clear grtot1 grtot2

% calculate mortality losses

mortP(:,:,p)=(1/plankton(p,5)).*phy(:,:);
ave_mortP(:,:,p)=ave_mortP(:,:,p)+mortP(:,:,p);

if p==78, fclose(fid); end

end % phyto
day
outmu=sprintf('/scratch/sclayton/coarse_rerun2/extract/MU_MORT_GRAZ/MU.%04d.1999.data',day);
outfid=fopen(outmu,'w','ieee-be');
fwrite(outfid,muP,'real*4');
fclose(outfid);

outgraz=sprintf('/scratch/sclayton/coarse_rerun2/extract/MU_MORT_GRAZ/GRAZ.%04d.1999.data',day);
outfid=fopen(outgraz,'w','ieee-be');
fwrite(outfid,grazP,'real*4');
fclose(outfid);

outmort=sprintf('/scratch/sclayton/coarse_rerun2/extract/MU_MORT_GRAZ/MORT.%04d.1999.data',day);
outfid=fopen(outmort,'w','ieee-be');
fwrite(outfid,mortP,'real*4');
fclose(outfid);

end % day

ave_grazP=ave_grazP./365;
ave_mortP=ave_mortP./365;
ave_muP=ave_muP./365;

outmu=sprintf('/scratch/sclayton/coarse_rerun2/extract/MU_MORT_GRAZ/MU.1999.data');
outfid=fopen(outmu,'w','ieee-be');
fwrite(outfid,ave_muP,'real*4');
fclose(outfid);

outgraz=sprintf('/scratch/sclayton/coarse_rerun2/extract/MU_MORT_GRAZ/GRAZ.1999.data');
outfid=fopen(outgraz,'w','ieee-be');
fwrite(outfid,ave_grazP,'real*4');
fclose(outfid);

outmort=sprintf('/scratch/sclayton/coarse_rerun2/extract/MU_MORT_GRAZ/MORT.1999.data',day);
outfid=fopen(outmort,'w','ieee-be');
fwrite(outfid,ave_mortP,'real*4');
fclose(outfid);
