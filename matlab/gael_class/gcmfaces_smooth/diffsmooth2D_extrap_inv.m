function [FLD]=diffsmooth2D(fld,mskOut,varargin);

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

%check for domain edge points where no exchange is possible:
tmp1=mskOut; tmp1(:)=1; tmp2=exch_T_N(tmp1);
for iF=1:mskOut.nFaces;
tmp3=mskOut{iF}; tmp4=tmp2{iF}; 
tmp4=tmp4(2:end-1,1:end-2)+tmp4(2:end-1,3:end)+tmp4(1:end-2,2:end-1)+tmp4(3:end,2:end-1);
if ~isempty(find(isnan(tmp4)&~isnan(tmp3))); fprintf('warning: mask was modified\n'); end;
tmp3(isnan(tmp4))=NaN; mskOut{iF}=tmp3; 
end;

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

%form matrix problem:
tmp1=convert2array(mskOut);
kk=find(~isnan(tmp1));
KK=tmp1; KK(kk)=kk; KK=convert2array(KK,fld);
nn=length(kk);
NN=tmp1; NN(kk)=[1:nn]; %NN=convert2array(NN,fld); 

if nargin==3; doFormMatrix=varargin{1}; else; doFormMatrix=1; end;

global dFLDdt_op; 
if doFormMatrix==1;

dFLDdt_op=sparse([],[],[],nn,nn,nn*5);

for iF=1:fld.nFaces; for ii=1:3; for jj=1:3;
    FLDones=fld; FLDones(find(~isnan(fld)))=0; 
    FLDones{iF}(ii:3:end,jj:3:end)=1;
    FLDones(find(isnan(fld)))=NaN;

    FLDkkFROMtmp=fld; FLDkkFROMtmp(find(~isnan(fld)))=0;
    FLDkkFROMtmp{iF}(ii:3:end,jj:3:end)=KK{iF}(ii:3:end,jj:3:end);
    FLDkkFROMtmp(find(isnan(fld)))=0;

    FLDkkFROM=exch_T_N(FLDkkFROMtmp); 
    FLDkkFROM(find(isnan(FLDkkFROM)))=0;
    for iF2=1:fld.nFaces; 
       tmp1=FLDkkFROM{iF2}; tmp2=zeros(size(tmp1)-2);
       for ii2=1:3; for jj2=1:3; tmp2=tmp2+tmp1(ii2:end-3+ii2,jj2:end-3+jj2); end; end;
       FLDkkFROM{iF2}=tmp2; 
    end;
    %clear FLDkkFROMtmp;

    [dTdxAtU,dTdyAtV]=calc_T_grad(FLDones,0);
    tmpU=dTdxAtU.*smooth2D_Kux;
    tmpV=dTdyAtV.*smooth2D_Kvy;
    [fldDIV]=calc_UV_div(tmpU,tmpV);
    dFLDdt=smooth2D_dt*fldDIV./rA;
    dFLDdt=dFLDdt.*mskFreeze;

    dFLDdt=convert2array(dFLDdt); FLDkkFROM=convert2array(FLDkkFROM); FLDkkTO=convert2array(KK);
    tmp1=find(dFLDdt~=0&~isnan(dFLDdt)); 
    dFLDdt=dFLDdt(tmp1); FLDkkFROM=FLDkkFROM(tmp1); FLDkkTO=FLDkkTO(tmp1);
    dFLDdt_op=dFLDdt_op+sparse(NN(FLDkkTO),NN(FLDkkFROM),dFLDdt,nn,nn);

end; end; end;

end;%if doFormMatrix==1;

%figure; spy(dFLDdt_op);

FLD_vec=convert2array(fld);
mskFreeze_vec=convert2array(mskFreeze);
FLD_vec(find(mskFreeze_vec==1))=0;
FLD_vec=FLD_vec(kk);

INV_op=1-mskFreeze_vec(kk);
INV_op=sparse([1:nn],[1:nn],INV_op,nn,nn);
INV_op=INV_op+dFLDdt_op;
INV_vec=INV_op\FLD_vec;
INV_fld=convert2array(mskOut);
INV_fld(find(~isnan(INV_fld)))=INV_vec;

FLD=convert2array(INV_fld,fld);

return;

%time step using matrix:
FLD_vec=convert2array(fld);
FLD_vec=FLD_vec(find(~isnan(FLD_vec)));
dFLDdt_vec=dFLDdt_op*FLD_vec;
dFLDdt_fld=convert2array(FLD); 
dFLDdt_fld(find(~isnan(dFLDdt_fld)))=dFLDdt_vec;
dFLDdt_fld(find(isnan(dFLDdt_fld)))=0;

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



