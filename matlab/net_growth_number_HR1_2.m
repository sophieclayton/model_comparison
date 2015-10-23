% script to calculate the number of phytoplanton types from 1o and 1/6o
% moel output that have either positive or negative net growth above a
% certain threshold.
% the script also calculate the sensitivity of the results to different
% time scales (10 yrs to 1000 yrs)

% Sophie Clayton, sclayton@mit.edu
% January 2012

clear all

HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
drfCR=readbin('
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
drfHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/RF.data');
% load growth rate and phytoplankton concentrations
CRmu=readbin('/scratch/sclayton/coarse_rerun2/extract/MU/munetP.z1.1999.data',[360 160 78]);
HRmu=HRknit_MunetPave(1);
HRmu=0.5.*(HRmu+HRknit_MunetPave(2));

CRphy=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
CRphy=squeeze(CRphy(:,:,1,:));

HRphy=HRknit_Pave(1);
HRphy=0.5*(HRphy+HRknit_Pave(2));

% parameters
sens=([10;100;1000].*(60*60*24*365)).^-1;
thresh0=200e-12;
thresh4=1e-5;

% calculate the number of types in pos/neg growth
CRpos=zeros(360,160,78);
CRneg=zeros(360,160,78);
totphy=sum(CRphy,3).*HFCR.*drfCR;
for i=1:360;
    for j=1:160;
        for p=1:78;
            if totphy(i,j)>thresh0 && CRphy(i,j,p)>totphy(i,j)*thresh4 && CRmu(i,j,p)>0
                CRpos(i,j,p)=1;
            elseif totphy(i,j)>thresh0 && CRphy(i,j,p)>totphy(i,j)*thresh4 && CRmu(i,j,p)<0
                CRneg(i,j,p)=1;
            end
            
        end
    end
end
CRpos=sum(CRpos,3);
CRpos(HFCR==0)=NaN;
CRneg=sum(CRneg,3);
CRneg(HFCR==0)=NaN;
clear totphy

HRpos=zeros(3060,510,78);
HRneg=zeros(3060,510,78);
totphy=sum(HRphy,3);
for i=1:3060;
    for j=1:510;
        for p=1:78;
            if totphy(i,j)>thresh0 && HRphy(i,j,p)>totphy(i,j)*thresh4 && HRmu(i,j,p)>0
                HRpos(i,j,p)=1;
            elseif totphy(i,j)>thresh0 && HRphy(i,j,p)>totphy(i,j)*thresh4 && HRmu(i,j,p)<0
                HRneg(i,j,p)=1;
            end
            
        end
    end
end
HRpos=sum(HRpos,3);
HRpos(HFHR==0)=NaN;
HRneg=sum(HRneg,3);
HRneg(HFHR==0)=NaN;
clear totphy

% sensitivity analysis
CRpos_sens=zeros(360,160,78,3);
CRneg_sens=zeros(360,160,78,3);
totphy=sum(CRphy,3);
for i=1:360;
    for j=1:160;
        for p=1:78;
            for s=1:3;
            if totphy(i,j)>thresh0 && CRphy(i,j,p)>totphy(i,j)*thresh4 && CRmu(i,j,p)>sens(s)
                CRpos_sens(i,j,p,s)=1;
            elseif totphy(i,j)>thresh0 && CRphy(i,j,p)>totphy(i,j)*thresh4 && CRmu(i,j,p)<-sens(s)
                CRneg_sens(i,j,p,s)=1;
            end
            end
        end
    end
end
CRpos_sens=sum(CRpos_sens,3);
CRpos_sens(HFCR==0)=NaN;
CRneg_sens=sum(CRneg_sens,3);
CRneg_sens(HFCR==0)=NaN;
clear totphy

HRpos_sens=zeros(3060,510,78,3);
HRneg_sens=zeros(3060,510,78,3);
totphy=sum(HRphy,3);
for i=1:3060;
    for j=1:510;
        for p=1:78;
            for s=1:3;
            if totphy(i,j)>thresh0 && HRphy(i,j,p)>totphy(i,j)*thresh4 && HRmu(i,j,p)>sens(s)
                HRpos_sens(i,j,p,s)=1;
            elseif totphy(i,j)>thresh0 && HRphy(i,j,p)>totphy(i,j)*thresh4 && HRmu(i,j,p)<-sens(s)
                HRneg_sens(i,j,p,s)=1;
            end
            end
        end
    end
end
HRpos_sens=sum(HRpos_sens,3);
HRpos_sens(HFHR==0)=NaN;
HRneg_sens=sum(HRneg_sens,3);
HRneg_sens(HFHR==0)=NaN;
clear totphy

% load grid data
load /home/jahn/matlab/cube66lonlat long latg
X=readbin('/scratch/sclayton/coarse_rerun/grid/XC.data',[360 160]);
Y=readbin('/scratch/sclayton/coarse_rerun/grid/YC.data',[360 160]);

% plot up data
figure(1);
subplot(2,2,1);plotcube(long,latg,HRpos,360);colorbar;title('E2 - \mu_{NET}>0');grid off
subplot(2,2,2);plotcube(long,latg,HRneg,360);colorbar;title('E2 - \mu_{NET}<0');grid off
subplot(2,2,3);pcolor(X',Y',CRpos');colorbar;title('EG - \mu_{NET}>0');shading flat;caxis([0 17])
subplot(2,2,4);pcolor(X',Y',CRneg');colorbar;title('EG - \mu_{NET}<0');shading flat;caxis([0 17])