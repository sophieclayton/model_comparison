function [FLD]=calc_transports(fldU,fldV,SECTIONS_MASKS);

global mygrid;

%initialize output:
n3=max(size(fldU.f1,3),1); n4=max(size(fldV.f1,4),1);
FLD=NaN*squeeze(zeros(length(SECTIONS_MASKS),n3,n4));

%prepare fldU/fldV:
fldU(isnan(fldU))=0; fldV(isnan(fldV))=0;

dxg=mk3D(mygrid.DXG,fldU); dyg=mk3D(mygrid.DYG,fldU); drf=mk3D(mygrid.DRF,fldU);
for k4=1:n4;
fldU(:,:,:,k4)=fldU(:,:,:,k4).*dyg.*drf.*mygrid.hFacW*1e-6;
fldV(:,:,:,k4)=fldV(:,:,:,k4).*dxg.*drf.*mygrid.hFacS*1e-6;
end;

%use array format to speed up computation below:
fldU=convert2array(fldU); fldV=convert2array(fldV);
n1=size(fldU,1); n2=size(fldU,2);
fldU=reshape(fldU,n1*n2,n3*n4); fldV=reshape(fldV,n1*n2,n3*n4); 

for iy=1:length(SECTIONS_MASKS); 

   %get list ofpoints that form a zonal band:
   mmu=convert2array(SECTIONS_MASKS(iy).mmuIn);
   nnu=find(~isnan(mmu)); mmu=mmu(nnu)*ones(1,n3*n4);
   mmv=convert2array(SECTIONS_MASKS(iy).mmvIn);
   nnv=find(~isnan(mmv)); mmv=mmv(nnv)*ones(1,n3*n4);

   %do the area weighed average along this band:
   tmpu=sum(fldU(nnu,:).*mmu,1);
   tmpv=sum(fldV(nnv,:).*mmv,1);

   %store:
   FLD(iy,:)=reshape(tmpu+tmpv,n3,n4);

end; 


