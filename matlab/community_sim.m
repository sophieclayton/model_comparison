% script to calculate the community similarity between the ECCO2 and
% ECCO-Godae Darwin model runs for Clayton et al (2015)

% Sophie Clayton, February 2015
% sclayton@uw.edu
clear all

addpath /Users/sclayton/Documents/MIT_work/comparison/matlab/

% load in grid details
HFCR = readbin('/Volumes/My Passport/coarse_run/grid/HFacC.data',[360 160]);
X = readbin('/Volumes/My Passport/coarse_run/grid/XC.data',[360 160]);
Y = readbin('/Volumes/My Passport/coarse_run/grid/YC.data',[360 160]);

% load in depth integrated the EG data (top 200m)
EGphy = readbin('/Volumes/My Passport/coarse_run/extract/Phyto/IntPhyto.1999.data',[360 160 78]);
for p=1:78;
    tmp = EGphy(:,:,p);
    tmp(HFCR==0) = NaN;
    EGphy(:,:,p)=tmp;
    clear tmp
end

EGtot = sum(EGphy,3);
EGf = zeros(360,160,78);

% load in depth integrated the interpolated E2 data (top 200m)
E2phy = zeros(360,160,78);
for p=1:78;
    in = sprintf('/Volumes/My Passport/HR2CRdata/HR2CRptracers/HR2CRptracer%02d.1999.data',p+21);
    tmp = readbin(in,[360 160]);
    tmp(HFCR==0)=NaN;
    E2phy(:,:,p) = tmp;
    clear tmp
end

E2tot = sum(E2phy,3);
E2f = zeros(360,160,78);

% calculate relative abundance of each type
for p=1:78;
    EGf(:,:,p) = EGphy(:,:,p)./EGtot;
    E2f(:,:,p) = E2phy(:,:,p)./E2tot;
end

EGf(EGf<0)=0;
EGf(EGf>1)=1;
E2f(E2f<0)=0;
E2f(E2f>1)=1;

CS = sqrt(sum((E2f - EGf).^2,3));

% get the phytoplankton traits
% trait=load('/scratch/sclayton/coarse_res/run89k_iav/plankton_ini_char_nohead.dat');


% figure;
% subplot(2,1,1);pcolor(X,Y,CRgroup');shading flat;colorbar;title(['CR dominant group']);axis([0 360 -90 90]);
% subplot(2,1,2); plotcube(long,latg,HRgroup,360);shading flat; colorbar;title(['HR dominant group']);grid off;axis([0 360 -90 90]);
