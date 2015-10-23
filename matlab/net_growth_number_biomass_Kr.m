% script to calculate the number of phytoplanton types from 1o and 1/6o
% model output that have either positive or negative net growth above a
% certain threshold.
% the script also calculate the sensitivity of the results to different
% time scales (10 yrs to 1000 yrs)

% Sophie Clayton, sclayton@mit.edu
% January 2012

clear all

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']);
plankton=plankton_ini_char_nohead;

small=find(plankton(:,3)==0);
big=find(plankton(:,3)==1);

HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);
% load growth rate and phytoplankton concentrations
CRmu=readbin('/scratch/sclayton/coarse_rerun2/extract/MU/munetP.z1.1999.data',[360 160 78]);
HRmu=HRknit_MunetPave(1);

CRphy=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
CRphy=squeeze(CRphy(:,:,1,:));

HRphy=readbin('/scratch/sclayton/high_res/Phyto/AveSurfPhyto.1999.data',[3060 510 78]);

% parameters
sens=([10;100;1000].*(60*60*24*365)).^-1;
thresh0=200e-12;
thresh4=1e-5;

% calculate the number of types in pos/neg growth

CRpos_big=zeros(360,160);
CRpos_small=zeros(360,160);
CRpos_Bbig=zeros(360,160);
CRpos_Bsmall=zeros(360,160);

CRneg_big=zeros(360,160);
CRneg_small=zeros(360,160);
CRneg_Bbig=zeros(360,160);
CRneg_Bsmall=zeros(360,160);

total=sum(CRphy,3).*10.*HFCR;
CRbio_big=sum(CRphy(:,:,big),3);
CRbio_small=sum(CRphy(:,:,small),3);

for i=1:360;
    for j=1:160;
        for p=1:78;
            if total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)>0 && plankton(p,3)==1
                CRpos_Bbig(i,j)=CRpos_Bbig(i,j)+CRphy(i,j,p);
                CRpos_big(i,j)=CRpos_big(i,j)+1;
                
            elseif total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)>0 && plankton(p,3)==0
                CRpos_Bsmall(i,j)=CRpos_Bsmall(i,j)+CRphy(i,j,p);
                CRpos_small(i,j)=CRpos_small(i,j)+1;
                
            elseif total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)<0 && plankton(p,3)==1
                CRneg_Bbig(i,j)=CRneg_Bbig(i,j)+CRphy(i,j,p);
                CRneg_big(i,j)=CRneg_big(i,j)+1;
                
            elseif total(i,j)>thresh0 && CRphy(i,j,p)*10*HFCR(i,j)>total(i,j)*thresh4 && CRmu(i,j,p)<0 && plankton(p,3)==0
                CRneg_Bsmall(i,j)=CRneg_Bsmall(i,j)+CRphy(i,j,p);
                CRneg_small(i,j)=CRneg_small(i,j)+1;
            end
            
        end
    end
end

CRpos_Bbig(HFCR==0)=NaN;
CRpos_big(HFCR==0)=NaN;
CRneg_Bbig(HFCR==0)=NaN;
CRneg_big(HFCR==0)=NaN;

CRpos_Bsmall(HFCR==0)=NaN;
CRpos_small(HFCR==0)=NaN;
CRneg_Bsmall(HFCR==0)=NaN;
CRneg_small(HFCR==0)=NaN;

clear totphy

CRpos_perbig=CRpos_Bbig./CRbio_big.*100;
CRpos_persmall=CRpos_Bsmall./CRbio_small.*100;
CRneg_perbig=CRneg_Bbig./CRbio_big.*100;
CRneg_persmall=CRneg_Bsmall./CRbio_small.*100;

CRdiv_big=CRneg_big+CRpos_big;
CRdiv_small=CRneg_small+CRpos_small;
CRdiv=CRdiv_small+CRdiv_big;

CRposd_perbig=CRpos_big./CRdiv_big.*100;
CRposd_persmall=CRpos_small./CRdiv_small.*100;
CRposd_persmall(CRdiv_small==0)=0;
CRnegd_perbig=CRneg_big./CRdiv_big.*100;
CRnegd_persmall=CRneg_small./CRdiv_small.*100;
CRnegd_persmall(CRdiv_small==0)=0;

CRpostotd_perbig=CRpos_big./CRdiv.*100;
CRpostotd_persmall=CRpos_small./CRdiv.*100;
CRnegtotd_perbig=CRneg_big./CRdiv.*100;
CRnegtotd_persmall=CRneg_small./CRdiv.*100;


% do the analysis for the E2 model

HRpos_Bbig=zeros(3060,510);
HRpos_Bsmall=zeros(3060,510);
HRneg_Bbig=zeros(3060,510);
HRneg_Bsmall=zeros(3060,510);

HRpos_big=zeros(3060,510);
HRpos_small=zeros(3060,510);
HRneg_big=zeros(3060,510);
HRneg_small=zeros(3060,510);

total=sum(HRphy,3).*5.*HFHR;
HRbio_big=sum(HRphy(:,:,big),3);
HRbio_small=sum(HRphy(:,:,small),3);
totphy=sum(HRphy,3);

for i=1:3060;
    for j=1:510;
        for p=1:78;
            if total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)>0 && plankton(p,3)==1
                HRpos_Bbig(i,j)=HRpos_Bbig(i,j)+HRphy(i,j,p);
                HRpos_big(i,j)=HRpos_big(i,j)+1;
                
            elseif total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)>0 && plankton(p,3)==0
                HRpos_Bsmall(i,j)=HRpos_Bsmall(i,j)+HRphy(i,j,p);
                HRpos_small(i,j)=HRpos_small(i,j)+1;
                
            elseif total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)<0 && plankton(p,3)==0
                HRneg_Bsmall(i,j)=HRneg_Bsmall(i,j)+HRphy(i,j,p);
                HRneg_small(i,j)=HRneg_small(i,j)+1;
                
            elseif total(i,j)>thresh0 && HRphy(i,j,p)*5*HFHR(i,j)>total(i,j)*thresh4 && HRmu(i,j,p)<0 && plankton(p,3)==1
                HRneg_Bbig(i,j)=HRneg_Bbig(i,j)+HRphy(i,j,p);
                HRneg_big(i,j)=HRneg_big(i,j)+1;
            end
            
        end
    end
end

HRpos_Bbig(HFHR==0)=NaN;
HRpos_Bsmall(HFHR==0)=NaN;
HRneg_Bbig(HFHR==0)=NaN;
HRneg_Bsmall(HFHR==0)=NaN;

HRpos_big(HFHR==0)=NaN;
HRpos_small(HFHR==0)=NaN;
HRneg_big(HFHR==0)=NaN;
HRneg_small(HFHR==0)=NaN;

HRdiv_big=HRneg_big+HRpos_big;
HRdiv_small=HRneg_small+HRpos_small;
HRdiv=HRdiv_small+HRdiv_big;



HRposB_perbig=HRpos_Bbig./totphy.*100;
HRposB_persmall=HRpos_Bsmall./totphy.*100;
HRnegB_perbig=HRneg_Bbig./totphy.*100;
HRnegB_persmall=HRneg_Bsmall./totphy.*100;

HRpos_perbig=HRpos_Bbig./HRbio_big.*100;
HRpos_persmall=HRpos_Bsmall./HRbio_small.*100;
HRneg_perbig=HRneg_Bbig./HRbio_big.*100;
HRneg_persmall=HRneg_Bsmall./HRbio_small.*100;

HRposd_perbig=HRpos_big./HRdiv_big.*100;
HRposd_persmall=HRpos_small./HRdiv_small.*100;
HRposd_persmall(HRdiv_small==0)=0;
HRnegd_perbig=HRneg_big./HRdiv_big.*100;
HRnegd_persmall=HRneg_small./HRdiv_small.*100;
HRnegd_persmall(HRdiv_small==0)=0;

HRpostotd_perbig=HRpos_big./HRdiv.*100;
HRpostotd_persmall=HRpos_small./HRdiv.*100;
HRnegtotd_perbig=HRneg_big./HRdiv.*100;
HRnegtotd_persmall=HRneg_small./HRdiv.*100;


% 
% % plot everything
% % load grid data
load /home/jahn/matlab/cube66lonlat long latg
X=readbin('/scratch/sclayton/coarse_rerun/grid/XC.data',[360 160]);
Y=readbin('/scratch/sclayton/coarse_rerun/grid/YC.data',[360 160]);
% 
% figure(1);
% subplot(2,2,1);pcolor(X, Y,CRpos_perbig);colorbar;title('EG opportunists - % biomass with \mu_{NET}>0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,2);pcolor(X,Y,CRpos_persmall);colorbar;title('EG gleaners - % biomass with \mu_{NET}>0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,3);pcolor(X,Y,CRneg_perbig);colorbar;title('EG opportunists - % biomass with \mu_{NET}<0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,4);pcolor(X,Y,CRneg_persmall);colorbar;title('EG gleaners - % biomass with \mu_{NET}<0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% 
% figure(2);
% subplot(2,2,1);plotcube(long,latg,HRpos_perbig,360);colorbar;title('E2 opportunists - % biomass with \mu_{NET}>0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,2);plotcube(long,latg,HRpos_persmall,360);colorbar;title('E2 gleaners - % biomass with \mu_{NET}>0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,3);plotcube(long,latg,HRneg_perbig,360);colorbar;title('E2 opportunists - % biomass with \mu_{NET}<0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,4);plotcube(long,latg,HRneg_persmall,360);colorbar;title('E2 gleaners - % biomass with \mu_{NET}<0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% 
% figure(3);
% subplot(2,2,1);pcolor(X, Y,CRposd_perbig);colorbar;title('EG opportunists - % diversity with \mu_{NET}>0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,2);pcolor(X,Y,CRposd_persmall);colorbar;title('EG gleaners - % diversity with \mu_{NET}>0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,3);pcolor(X,Y,CRnegd_perbig);colorbar;title('EG opportunists - % diversity with \mu_{NET}<0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,4);pcolor(X,Y,CRnegd_persmall);colorbar;title('EG gleaners - % diversity with \mu_{NET}<0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% 
% figure(4);
% subplot(2,2,1);plotcube(long,latg,HRposd_perbig,360);colorbar;title('E2 opportunists - % diversity with \mu_{NET}>0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,2);plotcube(long,latg,HRposd_persmall,360);colorbar;title('E2 gleaners - % diversity with \mu_{NET}>0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,3);plotcube(long,latg,HRnegd_perbig,360);colorbar;title('E2 opportunists - % diversity with \mu_{NET}<0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,4);plotcube(long,latg,HRnegd_persmall,360);colorbar;title('E2 gleaners - % diversity with \mu_{NET}<0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% 
% figure(5);
% subplot(2,2,1);pcolor(X, Y,CRpostotd_perbig);colorbar;title('EG opportunists - % total diversity with \mu_{NET}>0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,2);pcolor(X,Y,CRpostotd_persmall);colorbar;title('EG gleaners - % total diversity with \mu_{NET}>0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,3);pcolor(X,Y,CRnegtotd_perbig);colorbar;title('EG opportunists - % total diversity with \mu_{NET}<0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% subplot(2,2,4);pcolor(X,Y,CRnegtotd_persmall);colorbar;title('EG gleaners - % total diversity with \mu_{NET}<0');shading flat;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));
% 
% figure(6);
% subplot(2,2,1);plotcube(long,latg,HRpostotd_perbig,360);colorbar;title('E2 opportunists - % total diversity with \mu_{NET}>0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));box on
% subplot(2,2,2);plotcube(long,latg,HRpostotd_persmall,360);colorbar;title('E2 gleaners - % total diversity with \mu_{NET}>0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));box on
% subplot(2,2,3);plotcube(long,latg,HRnegtotd_perbig,360);colorbar;title('E2 opportunists - % total diversity with \mu_{NET}<0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));box on
% subplot(2,2,4);plotcube(long,latg,HRnegtotd_persmall,360);colorbar;title('E2 gleaners - % total diversity with \mu_{NET}<0');grid off;caxis([0 100]);
% colormap default, cmap=colormap; colormap(cmap([18  20 24:2:58],:));box on

