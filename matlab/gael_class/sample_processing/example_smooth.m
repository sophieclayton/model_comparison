
%use the field produced in sample_proccessing/example_bin_average.m
fld=obsmap; fld(find(isnan(fld)))=0; fld(find(mygrid.hFacCsurf==0))=NaN;

%choose smoothing scale: here 3 X grid spacing
distXC=3*mygrid.DXC; distYC=3*mygrid.DYC;

%do the smoothing:
obsmap_smooth=diffsmooth2D(fld,distXC,distYC);

%display results:
OBS_smooth=convert2array(obsmap_smooth);

figure; set(gcf,'Units','Normalized','Position',[0.3 0.1 0.4 0.6]);
imagescnan(OBS_smooth','nancolor',[1 1 1]*0.8); axis xy; caxis([-1 1]*0.1); colorbar;

