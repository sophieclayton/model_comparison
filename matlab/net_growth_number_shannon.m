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
%load growth rate and phytoplankton concentrations
CRmu=readbin('/scratch/sclayton/coarse_rerun2/extract/MU/munetP.z1.1999.data',[360 160 78]);
HRmu=HRknit_MunetPave(1);

CRphy=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
CRphy=squeeze(CRphy(:,:,1,:));
CRphy(CRphy<0)=0;

HRphy=readbin('/scratch/sclayton/high_res/Phyto/AveSurfPhyto.1999.data',[3060 510 78]);
HRphy(HRphy<0)=0;

% calculate the number of types in pos/neg growth
CRpos=zeros(360,160,78);
CRneg=zeros(360,160,78);
total=nansum(CRphy,3);
% totpos=zeros(360,160);
% totneg=zeros(360,160);

for i=1:360;
    for j=1:160;
        for p=1:78;
            if  total(i,j)>0 && CRmu(i,j,p)>0
%                 totpos(i,j)=totpos(i,j)+CRphy(i,j,p);
                CRpos(i,j,p)=CRphy(i,j,p);
                                           
            elseif total(i,j)>0 && CRmu(i,j,p)<0
                CRneg(i,j,p)=CRphy(i,j,p);
%                 totneg(i,j)=totpos(i,j)+CRphy(i,j,p);
            end
            
        end %p
       
     end
end

clear CRmu

CRSW_pos=zeros(360,160,78);
CRSW_neg=zeros(360,160,78);
CRSW=zeros(360,160,78);

for p=1:78;CRSW(:,:,p)=((CRphy(:,:,p)./total).*log(CRphy(:,:,p)./total));end
CRSW=-nansum(CRSW,3);
CRSW(HFCR==0)=NaN;
clear CRphy

for p=1:78;CRSW_pos(:,:,p)=((CRpos(:,:,p)./total).*log(CRpos(:,:,p)./total));end
CRSW_pos=-nansum(CRSW_pos,3);
CRSW_pos(HFCR==0)=NaN;
clear CRpos

for p=1:78;CRSW_neg(:,:,p)=((CRneg(:,:,p)./total).*log(CRneg(:,:,p)./total));end
CRSW_neg=-nansum(CRSW_neg,3);
CRSW_neg(HFCR==0)=NaN;
clear CRneg

clear total HFCR

HRpos=zeros(3060,510,78);
HRneg=zeros(3060,510,78);
total=nansum(HRphy,3);
% totpos=zeros(3060,510);
% totneg=zeros(3060,510);
for i=1:3060;
    for j=1:510;
        for p=1:78;
            if total(i,j)>0 && HRmu(i,j,p)>0
%                 totpos(i,j)=totpos(i,j)+HRphy(i,j,p);
                HRpos(i,j,p)=HRphy(i,j,p);
            elseif total(i,j)>0 && HRmu(i,j,p)<0
                HRneg(i,j,p)=HRphy(i,j,p);
%                 totneg(i,j)=totpos(i,j)+HRphy(i,j,p);
            end
            
        end
    end
end

clear HRmu

HRSW_pos=zeros(3060,510,78);
HRSW_neg=zeros(3060,510,78);
HRSW=zeros(3060,510,78);

for p=1:78;HRSW(:,:,p)=((HRphy(:,:,p)./total).*log(HRphy(:,:,p)./total));end
HRSW=-nansum(HRSW,3);
HRSW(HFHR==0)=NaN;
clear HRphy

for p=1:78;HRSW_pos(:,:,p)=((HRpos(:,:,p)./total).*log(HRpos(:,:,p)./total));end
HRSW_pos=-nansum(HRSW_pos,3);
HRSW_pos(HFHR==0)=NaN;
clear HRpos

for p=1:78;HRSW_neg(:,:,p)=((HRneg(:,:,p)./total).*log(HRneg(:,:,p)./total));end
HRSW_neg=-nansum(HRSW_neg,3);
HRSW_neg(HFHR==0)=NaN;
clear HRneg HFHR







