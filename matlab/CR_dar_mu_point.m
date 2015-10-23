% script to back calculate the growth rates of the different phytoplankton types for the 1^o model output
% Sophie Clayton, June 2011
% sclayton@gmail.com

% test this using annual mean values of biological forcing


clear all

nx=360;
ny=160;
nz=23;
np=78;

% set the grid square you want to look at
px=300;
py=115;

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
% 12 - KsFe, Fe half saturation, this is in mMol, but needs to be in uM
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
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
%munetP=zeros(nx,ny,np,365);
%mortP=zeros(nx,ny,np);
%grazP=zeros(nx,ny,np);
%muP=zeros(nx,ny,np);

for day=1:365;

% load nutrient and zooplankton fields
inn=sprintf('/scratch/sclayton/coarse_rerun2/extract/NutsZoo/NutsZoo.1999.%04d.data',day);
nfid=fopen(inn,'r','ieee-be');
nuts=fread(nfid,nx*ny*nz*21,'real*4');
nuts=reshape(nuts,[nx ny nz 21]);
nuts=squeeze(squeeze(squeeze(nuts(px,py,1,:))));
nuts(nuts<0)=0;
fclose(nfid);

% import PAR fields
inpar=sprintf('/scratch/sclayton/coarse_rerun2/extract/PAR/PAR.1999.%04d.data',day);
parfid=fopen(inpar,'r','ieee-be');
par=fread(parfid,[nx ny],'real*4');
par=squeeze(squeeze(squeeze(par(px,py,1))));
fclose(parfid);

% load phytoplankton fields
inphy=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',day);
pfid=fopen(inphy,'r','ieee-be');
phy=fread(pfid,nx*ny*nz*78,'real*4');
phy=reshape(phy,[nx ny nz 78]);
phy=squeeze(squeeze(squeeze(phy(px,py,1,:))));
phy(phy<0)=0;
fclose(pfid);

% load in temperature
int=sprintf('/scratch/sclayton/coarse_rerun/extract/Temp/Temp_daily.1999.%04d.data',day);
tfid=fopen(int,'r','ieee-be');
temp=fread(tfid,[nx ny],'real*4');
temp=squeeze(squeeze(temp(px,py)));
fclose(tfid);


%par(HFCR==0)=NaN;
%temp(HFCR==0)=NaN;

A1=0;
A2=0;
for p=1:np;
A1=A1+(plankton(p,14).*phy(p));
A2=A2+(plankton(p,15).*phy(p));
end
clear phy

fid=fopen(inphy,'r','ieee-be');

% step through the different phytoplankton types
for p=1:np;
p
% load phytoplankton fields

phy=fread(fid,360*160*23,'real*4');
phy=reshape(phy,[360 160 23]);
phy=squeeze(squeeze(squeeze(phy(px,py,1))));
phy(phy<0)=0;

% calculate nutrient limitation

kno2(p)=plankton(p,11);
knh4(p)=0.5.*plankton(p,11);

nh4lim=nuts(20)./(nuts(20)+knh4(p));
no2lim=nuts(21)./(nuts(21)+kno2(p));
no2no3lim=(nuts(21)+nuts(2))./(nuts(21)+nuts(2)+kno2(p)+plankton(p,11));

nlim(1)=nuts(1)./(nuts(1)+plankton(p,10));% PO4

% nitrogen source limitation
if plankton(p,19)==1, nlim(2)=no2lim.*exp(psi.*nuts(20))+nh4lim;% N
elseif plankton(p,19)==2, nlim(2)=nh4lim;
elseif plankton(p,19)==3, nlim(2)=no2no3lim.*exp(psi.*nuts(20))+nh4lim;% N
end
%clear no2lim no2no3lim nh4lim


nlim(3)=nuts(3)./(nuts(3)+(plankton(p,12)/1000));% FeT
nlim(4)=nuts(4)./(nuts(4)+plankton(p,13));% SiO4
nlim(nlim<0)=0;

if plankton(p,2)==1, abslim=min(nlim);
else absnlim=min(nlim(1:3));
end %plankton
%clear nlim 

% calculate temperature dependent growth

if plankton(p,3)==1, B=3*10^-3;
elseif plankton(p,3)==0, B=1*10^-3;end

tlim=0.33.*((1.04.^temp).*exp(-B.*(temp - plankton(p,18)).^4)-0.3);

% calculate light limitation
kpar=plankton(p,16)./10; 
kinh=plankton(p,17)./1000;
Fo=((kpar+kinh)/kpar).*exp(-(kinh./kpar).*log((kinh/kpar+kinh)));
ilim=(1/Fo).*(1 - exp(-par.*kpar)).*(exp(-par.*kinh));

if ilim>=1, ilim=1;end

% calculate growth rate
muP(p,day)=phy.*(1/plankton(p,4)).*tlim.*ilim.*absnlim;
%muP(:,:,p,day)=(phy(:,:).*(1/plankton(p,4).*tlim(:,:).*ilim(:,:).*absnlim(:,:)));
%clear tlim ilim absnlim

% calculate grazing
if plankton(p,3)==1, gmax1=0.033; gmax2=0.2;
else gmax1=0.2; gmax2=0.2; 
end
kz=0.1;
gr1=gmax1*(plankton(p,14)*phy./A1).*(A1./(A1+kz));
gr2=gmax2*(plankton(p,15)*phy./A2).*(A2./(A2+kz));
grtot1=gr1.*nuts(8);
grtot2=gr2.*nuts(12);
clear gr1 gr2 

grazP(p,day)=grtot1+grtot2;
%grazP(:,:,p,day)=grtot1+grtot2;
%clear grtot1 grtot2

% calculate mortality losses
mortP(p,day)=(1/plankton(p,5).*phy);
%mortP(:,:,p,day)=(1/plankton(p,5)).*phy(:,:);

%munetP(:,:,p,day)=muP(:,:,P)-mortP(:,:,p)-grazP(:,:,p);
end % phyto
fclose(fid);
day


end % day


