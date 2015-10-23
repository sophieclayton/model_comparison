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
CRpos=zeros(360,160,78);
CRneg=zeros(360,160,78);
total=sum(CRphy,3).*10.*HFCR;
for i=1:360;
    for j=1:160;
        for p=1:78;
            if total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)>0
                CRpos(i,j,p)=1;
            elseif total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)<0
                CRneg(i,j,p)=1;
            end
            
        end
    end
end
CRpos=sum(CRpos,3);
CRpos(HFCR==0)=NaN;
CRneg=sum(CRneg,3);
CRneg(HFCR==0)=NaN;

CRdiv=CRpos+CRneg;
CRpos_per=CRpos./CRdiv.*100;
CRneg_per=CRneg./CRdiv.*100;

CRSW=zeros(360,160,78);
totphy=nansum(CRphy,3);
for p=1:78;CRSW(:,:,p)=((CRphy(:,:,p)./totphy).*log(CRphy(:,:,p)./totphy));end
CRSW=-nansum(CRSW,3);
CRSW(HFCR==0)=NaN;

HRpos=zeros(3060,510,78);
HRneg=zeros(3060,510,78);
total=nansum(HRphy,3).*5.*HFHR;
for i=1:3060;
    for j=1:510;
        for p=1:78;
            if total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)>0
                HRpos(i,j,p)=1;
            elseif total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)<0
                HRneg(i,j,p)=1;
            end
            
        end
    end
end
HRpos=sum(HRpos,3);
HRpos(HFHR==0)=NaN;
HRneg=sum(HRneg,3);
HRneg(HFHR==0)=NaN;

HRSW=zeros(3060,510,78);
totphy=nansum(HRphy,3);
for p=1:78;HRSW(:,:,p)=((HRphy(:,:,p)./totphy).*log(HRphy(:,:,p)./totphy));end
HRSW=-nansum(HRSW,3);
HRSW(HFHR==0)=NaN;

clear totphy

HRdiv=HRpos+HRneg;
HRpos_per=HRpos./HRdiv.*100;
HRneg_per=HRneg./HRdiv.*100;

% % sensitivity analysis
% CRpos_sens=zeros(360,160,78,3);
% CRneg_sens=zeros(360,160,78,3);
% totphy=sum(CRphy,3);
% 
% 
% for i=1:360;
%     for j=1:160;
%         for p=1:78;
%             for s=1:3;
%             if totphy(i,j)>thresh0 && CRphy(i,j,p)>totphy(i,j)*thresh4 && CRmu(i,j,p)>sens(s)
%                 CRpos_sens(i,j,p,s)=1;
%             elseif totphy(i,j)>thresh0 && CRphy(i,j,p)>totphy(i,j)*thresh4 && CRmu(i,j,p)<-sens(s)
%                 CRneg_sens(i,j,p,s)=1;
%             end
%             end
%         end
%     end
% end
% CRpos_sens=sum(CRpos_sens,3);
% CRpos_sens(HFCR==0)=NaN;
% CRneg_sens=sum(CRneg_sens,3);
% CRneg_sens(HFCR==0)=NaN;
% 
% 
% clear totphy
% 
% HRpos_sens=zeros(3060,510,78,3);
% HRneg_sens=zeros(3060,510,78,3);
% totphy=sum(HRphy,3);
% for i=1:3060;
%     for j=1:510;
%         for p=1:78;
%             for s=1:3;
%             if totphy(i,j)>thresh0 && HRphy(i,j,p)>totphy(i,j)*thresh4 && HRmu(i,j,p)>sens(s)
%                 HRpos_sens(i,j,p,s)=1;
%             elseif totphy(i,j)>thresh0 && HRphy(i,j,p)>totphy(i,j)*thresh4 && HRmu(i,j,p)<-sens(s)
%                 HRneg_sens(i,j,p,s)=1;
%             end
%             end
%         end
%     end
% end
% HRpos_sens=sum(HRpos_sens,3);
% HRpos_sens(HFHR==0)=NaN;
% HRneg_sens=sum(HRneg_sens,3);
% HRneg_sens(HFHR==0)=NaN;
% 
% 
% for s=1:3;
%     tmp=HRpos_sens(:,:,s);
%     tmp(HFHR==0)=NaN;
%     HRpos_sens(:,:,s)=tmp;
%     clear tmp
%     tmp=HRneg_sens(:,:,s);
%     tmp(HFHR==0)=NaN;
%     HRneg_sens(:,:,s)=tmp;
%     clear tmp
%     tmp=CRpos_sens(:,:,s);
%     tmp(HFCR==0)=NaN;
%     CRpos_sens(:,:,s)=tmp;
%     clear tmp
%     tmp=CRneg_sens(:,:,s);
%     tmp(HFCR==0)=NaN;
%     CRneg_sens(:,:,s)=tmp;
%     clear tmp
%     
% end

% load grid data
load /home/jahn/matlab/cube66lonlat long latg
X=readbin('/scratch/sclayton/coarse_rerun/grid/XC.data',[360 160]);
Y=readbin('/scratch/sclayton/coarse_rerun/grid/YC.data',[360 160]);

% % plot up data
% figure(1);
% subplot(2,2,1);plotcube(long,latg,HRpos,360);colorbar;title('E2 - \mu_{NET}>0');grid off
% subplot(2,2,2);plotcube(long,latg,HRneg,360);colorbar;title('E2 - \mu_{NET}<0');grid off
% subplot(2,2,3);pcolor(X',Y',CRpos');colorbar;title('EG - \mu_{NET}>0');shading flat;caxis([0 17])
% subplot(2,2,4);pcolor(X',Y',CRneg');colorbar;title('EG - \mu_{NET}<0');shading flat;caxis([0 17])
% 
% 
% figure(2);
% subplot(2,2,1);plotcube(long,latg,HRpos_sens(:,:,1),360);colorbar;title('E2 - \mu_{NET}>0.1 yr^{-1}');grid off
% subplot(2,2,2);plotcube(long,latg,HRneg_sens(:,:,1),360);colorbar;title('E2 - \mu_{NET}<-0.1 yr^{-1}');grid off
% subplot(2,2,3);pcolor(X,Y,CRpos_sens(:,:,1));colorbar;title('EG - \mu_{NET}>0.1 yr^{-1}');shading flat;caxis([0 17])
% subplot(2,2,4);pcolor(X,Y,CRneg_sens(:,:,1));colorbar;title('EG - \mu_{NET}<-0.1 yr^{-1}');shading flat;caxis([0 17])
% 
% figure(3);
% subplot(2,2,1);plotcube(long,latg,HRpos_sens(:,:,2),360);colorbar;title('E2 - \mu_{NET}>0.01 yr^{-1}');grid off
% subplot(2,2,2);plotcube(long,latg,HRneg_sens(:,:,2),360);colorbar;title('E2 - \mu_{NET}<-0.01 yr^{-1}');grid off
% subplot(2,2,3);pcolor(X,Y,CRpos_sens(:,:,2));colorbar;title('EG - \mu_{NET}>0.01 yr^{-1}');shading flat;caxis([0 17])
% subplot(2,2,4);pcolor(X,Y,CRneg_sens(:,:,2));colorbar;title('EG - \mu_{NET}<-0.01 yr^{-1}');shading flat;caxis([0 17])
% 
% figure(4);
% subplot(2,2,1);plotcube(long,latg,HRpos_sens(:,:,3),360);colorbar;title('E2 - \mu_{NET}>0.001 yr^{-1}');grid off
% subplot(2,2,2);plotcube(long,latg,HRneg_sens(:,:,3),360);colorbar;title('E2 - \mu_{NET}<-0.001 yr^{-1}');grid off
% subplot(2,2,3);pcolor(X,Y,CRpos_sens(:,:,3));colorbar;title('EG - \mu_{NET}>0.001 yr^{-1}');shading flat;caxis([0 17])
% subplot(2,2,4);pcolor(X,Y,CRneg_sens(:,:,3));colorbar;title('EG - \mu_{NET}<-0.001 yr^{-1}');shading flat;caxis([0 17])
% 
% figure(5);
% plotcube(long,latg,HRneg_per,360);colorbar;title('E2 - % diversity due to phyto with \mu_{NET}<0');grid off
% 
% 

