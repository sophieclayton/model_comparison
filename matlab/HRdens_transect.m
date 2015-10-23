% this is a script to extract a specific region of interest from the output
function [LONi,LATi,z_grid,region]=HRdens_transect(lon1,lon2,lat1,lat2)

% of the eddy permitting MIT Ecosystem model run. It also regrids the data
% onto a regular lat/lon grid

% set the input directories
dir='/scratch/sclayton/high_res/KPP/';

% set the output directories
outsubdir='transect';

RF=readbin('/scratch/jahn/run/ecco2/cube84/d0006/grid/RF.data',[50]);
depth=cumsum(RF(2:end))./2;
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510 50]);

load('/home/jahn/matlab/cube66.mat','lonc','latc');

lonc=mod(lonc,360);

lon=reshape(lonc,3060*510,1);
lat=reshape(latc,3060*510,1);

coord=find(lon>=lon1 & lon<=lon2 & lat>=lat1 & lat<=lat2);

x=lon(coord);
y=lat(coord);
LON=[lon1:0.167:lon2]';
LAT=[lat2:-0.167:lat1];

[LONgrid,LATgrid]=meshgrid(LON,LAT);

for year=1999;
    for m=1:12;
        fhr=sprintf('%sKPP.monthly.%04d%02d.data',dir,year,m);
        tra=readbin(fhr,[3060,510,50]);
        tra(HFHR==0)=NaN;
        tra=reshape(tra,[3060*510,50]);
        
        for z=2:50;
            tmp=tra(:,z);
            tra_grid=tmp(coord);
            [LONi(:,:,z-1),LATi(:,:,z-1),region(:,:,z-1,m)]=griddata(x,y,tra_grid,LON,LAT,'nearest');
            clear tmp
        end
    end
end

[a,b]=size(LONi(:,:,1,1));
depth=repmat(depth,1,[a,b]);
z_grid=permute(depth,[2 3 1]);
clear depth

end
