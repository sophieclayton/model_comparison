% script to extract daily data for subsets of the global model output from
% the EG runs
% Sophie Clayton, August 2012
% sclayton@mit.edu

clear all

XX=readbin('/scratch/sclayton/coarse_rerun/grid/XC.data',[360 160]);
YY=readbin('/scratch/sclayton/coarse_rerun/grid/YC.data',[360 160]);

% set the area to be extracted
lat_min=40;
lat_max=45;
lon_min=290;
lon_max=310;

% set the days to be extracted
day1=1;
day2=365;
max_day=day2-day1+1;

[a,b]=find(XX>=lon_min & XX<=lon_max & YY>=lat_min & YY<=lat_max);
phy_day=zeros(78,max_day);

HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);
HFCR=HFCR(a,b);
HFCR=repmat(HFCR,[1 1 78]);

for day=day1:day2;
    in=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',day);
    tmp=readbin(in,[360 160 23 78]);
    tmp=squeeze(tmp(:,:,1,:));
    tmp=tmp(a,b,:);
    tmp(HFCR==0)=NaN;
        
    for p=1:78;
        tt=tmp(:,:,p);
        phy_day(p,day)=nanmean(tt(:));
        clear tt
    end
    day
    clear tmp
    
end


    