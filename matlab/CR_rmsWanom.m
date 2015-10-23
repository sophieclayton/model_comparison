% Script to calculate the meridional flux divergence of nutrients for the output of the 1^o darwin model.
% Both the eddy and mean fluxes are calculated for each grid cell.
% Sophie Clayton, June 2011
% sclayton@mit.edu

%clear all

% import the grid data needed
clear fpat vars
vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
vars(3).name = 'Z';
vars(4).name = 'HFacC';

fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose
%

HFacC=permute(HFacC,[3 2 1]);

% import the annual mean velocity fields
uvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/U_annave.1999.data',[360 160 23]);
vvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/V_annave.1999.data',[360 160 23]);
wvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/W_annave.1999.data',[360 160 23]);

uvel_anom=zeros(360,160,23);
vvel_anom=zeros(360,160,23);
wvel_anom=zeros(360,160,23);


for t=1:365;
inu=sprintf('/scratch/sclayton/coarse_rerun/extract/Udaily/Udaily.1999.%04d.data',t);
uvel_tmp=readbin(inu,[360 160 23]);
inv=sprintf('/scratch/sclayton/coarse_rerun/extract/Vdaily/Vdaily.1999.%04d.data',t);
vvel_tmp=readbin(inv,[360 160 23]);
inw=sprintf('/scratch/sclayton/coarse_rerun/extract/Wdaily/Wdaily.1999.%04d.data',t);
wvel_tmp=readbin(inw,[360 160 23]);
clear in inu inv inw


uvel_anom=uvel_anom+(uvel_tmp-uvel_mean).^2;
vvel_anom=vvel_anom+(vvel_tmp-vvel_mean).^2;
wvel_anom=wvel_anom+(wvel_tmp-wvel_mean).^2;

end

uvel_anom=sqrt(uvel_anom./365);
vvel_anom=sqrt(vvel_anom./365);
wvel_anom=sqrt(wvel_anom./365);

