function [FLD]=diffsmooth2D(fld,mskOut,eps);

%object: implementation (gforget@mit.edu) of a diffusive smoother (Weaver and Courtier 2001)

%input:	fld	field to be smoothed (masked with NaN)
%       dxCsm,dyCsm	scale in first/second direction
%output:FLD	smoothed field

%asumption: dxCsm/dyCsm are assumed to be given at the positions of U/V points

global mygrid;

dxC=mygrid.DXC; dyC=mygrid.DYC; 
dxG=mygrid.DXG; dyG=mygrid.DYG; 
rA=mygrid.RAC;

dxCsm=dxC; dyCsm=dyC;
mskFreeze=fld; mskFreeze(find(~isnan(mskFreeze)))=0; mskFreeze(find(isnan(mskFreeze)))=1;

%put first guess:
x=convert2array(mygrid.XC);
y=convert2array(mygrid.YC);
z=convert2array(fld);
m=convert2array(mskOut);
tmp1=find(~isnan(z));
tmp2=find(~isnan(m));
zz=z;
zz(tmp2) = griddata(x(tmp1),y(tmp1),z(tmp1),x(tmp2),y(tmp2),'nearest');
fld=convert2array(zz,fld);

%put 0 first guess if needed and switch land mask:
fld(find(isnan(fld)))=0; fld=fld.*mskOut;

%scale the diffusive operator:
tmp0=dxCsm./dxC; tmp0(isnan(mskOut))=NaN; tmp00=nanmax(tmp0);
tmp0=dyCsm./dyC; tmp0(isnan(mskOut))=NaN; tmp00=max([tmp00 nanmax(tmp0)]);
smooth2D_nbt=tmp00;
smooth2D_nbt=ceil(1.1*2*smooth2D_nbt^2);

smooth2D_dt=1;
smooth2D_T=smooth2D_nbt*smooth2D_dt;
smooth2D_Kux=dxCsm.*dxCsm/smooth2D_T/2;
smooth2D_Kvy=dyCsm.*dyCsm/smooth2D_T/2;

%time-stepping loop:
FLD=fld;

test1=0; it=0;
while ~test1;

    it=it+1;

    [dTdxAtU,dTdyAtV]=calc_T_grad(FLD,0);
    tmpU=dTdxAtU.*smooth2D_Kux;
    tmpV=dTdyAtV.*smooth2D_Kvy;
    [fldDIV]=calc_UV_div(tmpU,tmpV);
    dFLDdt=smooth2D_dt*fldDIV./rA;
    dFLDdt=dFLDdt.*mskFreeze;
    FLD=FLD-dFLDdt;

    tmp1=max(abs(dFLDdt));
    if mod(it,10)==0; fprintf([num2str(it) ' del=' num2str(tmp1) ' eps=' num2str(eps) ' \n']); end;
    test1=tmp1<eps;

    FLDstore{it}=dFLDdt;
end;

if 1;
   jj=1; FLDstore2=zeros([size(FLD{jj}) length(FLDstore)]);
   for ii=1:length(FLDstore); FLDstore2(:,:,ii)=FLDstore{ii}{jj}; end;
   tmp1=abs(FLDstore2(:,:,end)); [ii,jj]=find(tmp1==max(tmp1(:)));
   figure; plot(cumsum(squeeze(FLDstore2(ii,jj,:))));
end;



