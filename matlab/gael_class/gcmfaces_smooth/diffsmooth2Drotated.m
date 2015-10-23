function [FLD]=diffsmooth2D(fld,dxLarge,dxSmall,fldRef);

%object: implementation (gforget@mit.edu) of a diffusive smoother (Weaver and Courtier 2001)

%input:	fld	field to be smoothed (masked with NaN)
%       dxCsm,dyCsm	scale in first/second direction
%output:FLD	smoothed field

%asumption: dxCsm/dyCsm are assumed to be given at the positions of U/V points

global mygrid;

dxC=mygrid.DXC; dyC=mygrid.DYC; 
dxG=mygrid.DXG; dyG=mygrid.DYG; 
rA=mygrid.RAC;

%compute the direction of main axis:
%%[dFLDdx,dFLDdy,ddFLDdxdx,ddFLDdydy]=calc_T_grad(fldRef,1);
%%dFLDn=sqrt(dFLDdx.^2+dFLDdy.^2);
%%ddFLDn=sqrt(ddFLDdxdx.^2+ddFLDdydy.^2);
[dFLDdx,dFLDdy]=calc_T_grad(fldRef,1);
dFLDn=sqrt(dFLDdx.^2+dFLDdy.^2);
if 0;
   %FLDratio=dFLDn.*sqrt(mygrid.RAC)./max(fldRef,100);
   FLDratio=dFLDn.*dxLarge./max(fldRef,100);
end;
cs=dFLDdy; sn=-dFLDdx;  
%%cs=dFLDdx; sn=dFLDdy;
cs(dFLDn>0)=cs(dFLDn>0)./dFLDn(dFLDn>0); 
sn(dFLDn>0)=sn(dFLDn>0)./dFLDn(dFLDn>0);
if 0;
   FLDangle=fldRef;
   for iF=1:fldRef.nFaces; FLDangle{iF}=atan2(sn{iF},cs{iF}); end;
end;

%scale the diffusive operator:
tmp0=dxLarge./dxC; tmp0(isnan(fld))=NaN; tmp00=nanmax(tmp0);
tmp0=dxLarge./dyC; tmp0(isnan(fld))=NaN; tmp00=max([tmp00 nanmax(tmp0)]);
smooth2D_nbt=tmp00;
smooth2D_nbt=ceil(1.1*2*smooth2D_nbt^2);

smooth2D_dt=1;
smooth2D_T=smooth2D_nbt*smooth2D_dt;

smooth2D_kLarge=dxLarge.*dxLarge/smooth2D_T/2;
smooth2D_kSmall=dxSmall.*dxSmall/smooth2D_T/2;

smooth2D_Kux=cs.*cs.*smooth2D_kLarge+sn.*sn.*smooth2D_kSmall;
smooth2D_Kuy=cs.*sn.*(-smooth2D_kLarge+smooth2D_kSmall);
smooth2D_Kvy=sn.*sn.*smooth2D_kLarge+cs.*cs.*smooth2D_kSmall;
smooth2D_Kvx=cs.*sn.*(-smooth2D_kLarge+smooth2D_kSmall);

%time-stepping loop:
FLD=fld;

for it=1:smooth2D_nbt;
    if mod(it,ceil(smooth2D_nbt/50))==0; fprintf([num2str(it) '/' num2str(smooth2D_nbt) ' done\n']); end;

    [dTdxAtU,dTdyAtV]=calc_T_grad(FLD,0);

    dTdyAtU=dTdxAtU; dTdxAtV=dTdyAtV;
    [dTdxAtU,dTdyAtV]=exch_UV_N(dTdxAtU,dTdyAtV);
    for iF=1:FLD.nFaces;
        msk=dTdxAtU{iF}(2:end-1,2:end-1); msk(~isnan(msk))=1;
        tmp1=dTdyAtV{iF}; tmp1(isnan(tmp1))=0;
        dTdyAtU{iF}=0.25*msk.*(tmp1(1:end-2,2:end-1)+tmp1(1:end-2,3:end)+...
                tmp1(2:end-1,2:end-1)+tmp1(2:end-1,3:end));

        msk=dTdyAtV{iF}(2:end-1,2:end-1); msk(~isnan(msk))=1;
        tmp1=dTdxAtU{iF}; tmp1(isnan(tmp1))=0;
        dTdxAtV{iF}=0.25*msk.*(tmp1(2:end-1,1:end-2)+tmp1(3:end,1:end-2)+...
                tmp1(2:end-1,2:end-1)+tmp1(3:end,2:end-1));
    end;
    dTdxAtU=cut_T_N(dTdxAtU);
    dTdyAtV=cut_T_N(dTdyAtV);

    tmpU=dTdxAtU.*smooth2D_Kux+dTdyAtU.*smooth2D_Kuy;
    tmpV=dTdyAtV.*smooth2D_Kvy+dTdxAtV.*smooth2D_Kvx;
    [fldDIV]=calc_UV_div(tmpU,tmpV);
    dFLDdt=smooth2D_dt*fldDIV./rA;
    FLD=FLD-dFLDdt;

end;


