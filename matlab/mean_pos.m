% simple script for getting the mean position of different phytoplankton
% types along the transect

% choose longitude, year and month of data

indir=['kuroshio_hr'];
insubdir=['transects'];
infile=['TRANSECT_lon'];
fin=sprintf('%s/%s/%s%03d.%04d%02d.bin',indir,insubdir,infile,lon,year,month);

diff=-0.167;

for j=01:99;
    for i=1:length(LAT)-1;
    top(i,j)=(lat(i+1)-lat(i))*((data(i,j)+data(i+1,j))/2)*((lat(i)+lat(i+1))/2);
    bottom(i,j)=(lat(i+1)-lat(i))*((data(i,j)+data(i+1,j))/2);
    end
end

top=sum(top,1);
bottom=sum(bottom,1);
dd=top./bottom;
% figure;plot(22:99,dd(22:99),'.');xlabel('phytoplankton type');ylabel('mean position (latitude)');

[B,IX]=sort(dd(:,22:99));

phyto=data(:,22:99);

figure;
subplot(1,6,1)
plot(data(:,1),LAT);
ylabel('latitude');xlabel('nitrate (mmol/m^2');

subplot(1,6,2:6)
pcolor(type,LAT,log10(phyto(:,IX)));
mm=max(caxis);
caxis([-6 mm]);shading flat;colorbar
set(gca,'XTick',1:1:78)
set(gca,'XTickLabel',{type(IX)})
xlabel('phytoplankton type');
title(['Model Phytoplankton Community Structure along ', num2str(lon), '^{o}E', num2str(month), num2str(year)]);

