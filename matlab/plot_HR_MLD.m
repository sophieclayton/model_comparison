% plot the monthly MLD from the 1/6^o model

clear all

load /home/jahn/matlab/cube66lonlat long latg
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510 50]);
HFHR=squeeze(HFHR(:,:,1));

figure(1)
for m=1:12;
    in=sprintf('/scratch/sclayton/high_res/MLD/MLD.1999%02d.data',m);
    mld=readbin(in,[3060 510]);
    mld(HFHR==0)=NaN;
%     subplot(4,3,m);
figure(m);
    plotcube(long,latg,mld,360);grid off;colorbar;caxis([0 300]);
end
    