function [FLD]=diffsmooth2D(fld,dxCsm,dyCsm);

%object: implementation (gforget@mit.edu) of a diffusive smoother (Weaver and Courtier 2001)

%input:	fld	field to be smoothed (masked with NaN)
%       dxCsm,dyCsm	scale in first/second direction
%output:FLD	smoothed field

%asumption: dxCsm/dyCsm are assumed to be given at the positions of U/V points

global mygrid;

dxC=mygrid.DXC; dyC=mygrid.DYC; 
dxG=mygrid.DXG; dyG=mygrid.DYG; 
rA=mygrid.RAC;

%scale the diffusive operator:
tmp0=dxCsm./dxC; tmp0(isnan(fld))=NaN; tmp00=nanmax(tmp0);
tmp0=dyCsm./dyC; tmp0(isnan(fld))=NaN; tmp00=max([tmp00 nanmax(tmp0)]);
smooth2D_nbt=tmp00;
smooth2D_nbt=ceil(1.1*2*smooth2D_nbt^2);

smooth2D_dt=1;
smooth2D_T=smooth2D_nbt*smooth2D_dt;
smooth2D_Kux=dxCsm.*dxCsm/smooth2D_T/2;
smooth2D_Kvy=dyCsm.*dyCsm/smooth2D_T/2;

%time-stepping loop:
FLD=fld;

for it=1:smooth2D_nbt;
%    if mod(it,ceil(smooth2D_nbt/50))==0; fprintf([num2str(it) '/' num2str(smooth2D_nbt) ' done\n']); end;

    [dTdxAtU,dTdyAtV]=calc_T_grad(FLD,0);
    tmpU=dTdxAtU.*smooth2D_Kux;
    tmpV=dTdyAtV.*smooth2D_Kvy;
    [fldDIV]=calc_UV_div(tmpU,tmpV);
    dFLDdt=smooth2D_dt*fldDIV./rA;
    FLD=FLD-dFLDdt;

end;


