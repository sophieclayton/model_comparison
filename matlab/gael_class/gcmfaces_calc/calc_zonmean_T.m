function [FLD]=calc_zonmean_T(fld,LATS_MASKS);

%by assumption: zonmean_TUV_mask is done, and grid_load is done
global mygrid;

%initialize output:
n3=max(size(fld.f1,3),1); n4=max(size(fld.f1,4),1);
FLD=NaN*squeeze(zeros(length(LATS_MASKS),n3,n4));

%use array format to speed up computation below:
fld=convert2array(fld); 
n1=size(fld,1); n2=size(fld,2); 
fld=reshape(fld,n1*n2,n3*n4); 
fld(isnan(fld))=0;
rac=reshape(convert2array(mygrid.RAC),n1*n2,1)*ones(1,n3*n4);
if n3==length(mygrid.RC); 
   hFacC=reshape(convert2array(mygrid.hFacC),n1*n2,n3*n4);
else; 
   hFacC=reshape(convert2array(mygrid.mskC(:,:,1)),n1*n2,1)*ones(1,n3*n4);
   hFacC(isnan(hFacC))=0;
end;
rac=rac.*hFacC;
fld=fld.*rac;

%masked area only:
rac(isnan(fld))=0;

for iy=1:length(LATS_MASKS); 

   %get list ofpoints that form a zonal band:
   mm=convert2array(LATS_MASKS(iy).mmt);
   mm=find(~isnan(mm));

   %do the area weighed average along this band: 
   tmp1=sum(fld(mm,:),1); 
   tmp2=sum(rac(mm,:),1); 
   tmp2(tmp2==0)=NaN;
   tmp1=tmp1./tmp2;

   %store:
   FLD(iy,:,:)=reshape(tmp1,n3,n4);

end; 


