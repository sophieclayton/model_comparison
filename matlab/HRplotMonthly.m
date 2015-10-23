% plot monthly fields from daily output from the darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

% define input fields
load /home/jahn/matlab/cube66lonlat long latg
monthly=zeros(3060,510,12);

figure
t=3;
for m=1:12;
    
    in=sprintf('/scratch/sclayton/high_res/Nuts/SurfNutsZoo.monthly.1999%02d.data',m);
    tmp=readbin(in,[3060 510 21]);
    monthly(:,:,m)=tmp(:,:,t);
    clear tmp
end

for m=1:12;
    subplot(4,3,m);
    plotcube(long,latg,squeeze(monthly(:,:,m)),360);
    shading flat;
    caxis([0 max(max(max(monthly)))]);
    colorbar
    
end

subplot(4,3,2);title('Monthly Surface FeT mmol/m^3');
