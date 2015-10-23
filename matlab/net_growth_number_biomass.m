% script to calculate the number of phytoplanton types from 1o and 1/6o
% model output that have either positive or negative net growth above a
% certain threshold.
% the script also calculate the sensitivity of the results to different
% time scales (10 yrs to 1000 yrs)

% Sophie Clayton, sclayton@mit.edu
% January 2012

clear all

HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
% load growth rate and phytoplankton concentrations
CRmu=readbin('/scratch/sclayton/coarse_rerun2/extract/MU/munetP.z1.1999.data',[360 160 78]);
HRmu=HRknit_MunetPave(1);

CRphy=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
CRphy=squeeze(CRphy(:,:,1,:));
CRphy(CRphy<0)=0;

HRphy=readbin('/scratch/sclayton/high_res/Phyto/AveSurfPhyto.1999.data',[3060 510 78]);
HRphy(HRphy<0)=0;

% parameters
sens=([10;100;1000].*(60*60*24*365)).^-1;
thresh0=200e-12;
thresh4=1e-5;

% calculate the number of types in pos/neg growth

CRposB=zeros(360,160);
CRnegB=zeros(360,160);
total=sum(CRphy,3).*10.*HFCR;
CRbio=sum(CRphy,3);

for i=1:360;
    for j=1:160;
        for p=1:78;
            if total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)>0
                CRposB(i,j)=CRposB(i,j)+CRphy(i,j,p);
            elseif total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)<0
                CRnegB(i,j)=CRnegB(i,j)+CRphy(i,j,p);
            end
           
        end
    end
end

CRposB(HFCR==0)=NaN;

CRnegB(HFCR==0)=NaN;
clear totphy

CRpos_per=CRposB./CRbio.*100;
CRneg_per=CRnegB./CRbio.*100;

HRposB=zeros(3060,510);
HRnegB=zeros(3060,510);
total=sum(HRphy,3).*5.*HFHR;
HRbio=sum(HRphy,3);

for i=1:3060;
    for j=1:510;
        for p=1:78;
            if total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)>0
                HRposB(i,j)=HRposB(i,j)+HRphy(i,j,p);
            elseif total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)<0
                HRnegB(i,j)=HRnegB(i,j)+HRphy(i,j,p);
            end
            
        end
    end
end

HRposB(HFHR==0)=NaN;
HRnegB(HFHR==0)=NaN;

clear totphy

HRpos_per=HRposB./HRbio.*100;
HRneg_per=HRnegB./HRbio.*100;

