function [secX,secY,secFLD]=gcmfaces_section(lons,lats,fld);
%purpose: extract a great circle section (defined by two points) from a field
%
%inputs:	lons/lats are the longitude/latitude vector
%		fld is the gcmfaces field (can incl. depth/time dimensions)
%outputs:	secX/secY is the vector of grid points longitude/latitude
%		secFLD is the vector/matrix of grid point values (from fld)

global mygrid;

line_cur=line_greatC_TUV_mask(lons,lats);
secP=find(~isnan(line_cur.mmtIn));
secN=sum(~isnan(line_cur.mmtIn));

%lon/lat vectors:
secX=zeros(secN,1); secY=zeros(secN,1); 
%sections:
n3=max(size(fld{1},3),1); n4=max(size(fld{4},4),1); secFLD=zeros(secN,n3,n4);
%counter:
ii0=0; 
for ff=1:secP.nFaces;
  tmp0=secP{ff}; [tmpI,tmpJ]=ind2sub(size(mygrid.XC{ff}),tmp0);
  tmp1=mygrid.XC{ff}; for ii=1:length(tmpI); secX(ii+ii0)=tmp1(tmpI(ii),tmpJ(ii)); end;
  tmp1=mygrid.YC{ff}; for ii=1:length(tmpI); secY(ii+ii0)=tmp1(tmpI(ii),tmpJ(ii)); end;
  tmp1=fld{ff}; for ii=1:length(tmpI); secFLD(ii+ii0,:,:)=squeeze(tmp1(tmpI(ii),tmpJ(ii),:,:)); end;
  ii0=ii0+length(tmpI);
end;

%sort according to increasing latitude:
[tmp1,ii]=sort(secY); %sort according to increasing latitude
secX=secX(ii); secY=secY(ii); secFLD=secFLD(ii,:,:);

