% this is a script to extract a specific region of interest from the output
% of the eddy permitting MIT Ecosystem model run. It also regrids the data
% onto a regular lat/lon grid

%clear all

load high_res/model199910.mat
load high_res/T_days.mat

lon=reshape(lons,102*51,1);
lat=reshape(lats,102*51,1);

% set the region of interest witha range of lat and lon coordinates
coord=find(lon>=143 & lon<=146 & lat>=30 & lat<=45);

x=lon(coord);
y=lat(coord);
LON=[143:0.167:146];
LAT=[40:-0.167:30]';

[LONgrid,LATgrid]=meshgrid(LON,LAT);

outdir=['kuroshio_hr'];
outsubdir=['gridded_groups'];
outfile=['phygrp'];

for group=1:5;
    for day=1:31;
        for depth=1:30;
            tra=phy_1999(:,:,depth,group,day);
            tra_long=reshape(tra,102*51,1);
            tra_grid=tra_long(coord);
            region(:,:,depth)=griddata(x,y,tra_grid,LON,LAT,'nearest');
            
            % write the gridded data out to a bin file
        end
        
%         fo=sprintf('%s/%s/%s%02d.%04d%02d.bin',outdir,outsubdir,outfile,group,day);
%         fid=fopen(fo,'w','b');
%         fwrite(fid,region,'float32');
%         fclose(fid);
                
    end
end

year=1999;
month=10;
outfile2=['T'];

for day=1:31;
    for depth=1:30;
        var=T_days(:,:,depth,day);
        var_long=reshape(var,102*51,1);
        var_grid=var_long(coord);
        Tregion(:,:,depth)=griddata(x,y,var_grid,LON,LAT,'nearest');
    end
    
    fo=sprintf('%s/%s/%s%04d%02d.%02d.bin',outdir,outsubdir,outfile2,year,month,day);
    fid=fopen(fo,'w','b');
    fwrite(fid,Tregion,'float32');
    fclose(fid);
    
    
end



