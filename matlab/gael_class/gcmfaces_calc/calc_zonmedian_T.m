function [FLD]=calc_zonmedian_T(fld,LATS_MASKS);

%by assumption: zonmean_TUV_mask is done, and grid_load is done
global mygrid;

%initialize output:
n3=max(size(fld.f1,3),1); n4=max(size(fld.f1,4),1);
FLD=NaN*squeeze(zeros(length(LATS_MASKS),n3,n4));

%use array format to speed up computation below:
fld=convert2array(fld.*mygrid.mskC); 
n1=size(fld,1); n2=size(fld,2); 
fld=reshape(fld,n1*n2,n3*n4); 

for iy=1:length(LATS_MASKS); 

   %get list ofpoints that form a zonal band:
   mm=convert2array(LATS_MASKS(iy).mmt);
   mm=find(~isnan(mm));

   %do the median along this band: 
   tmp1=nanmedian(fld(mm,:),1); 

   %store:
   FLD(iy,:,:)=reshape(tmp1,n3,n4);

end; 


