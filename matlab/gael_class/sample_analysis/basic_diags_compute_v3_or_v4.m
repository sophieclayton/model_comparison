
%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%

choiceV3orV4='v3'

if ~isempty(choiceV3orV4)&isempty(whos('mygrid'));
  gcmfaces_path;
  dir0=[gcmfaces_dir '/sample_input/'];
  dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
  dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
  if strcmp(choiceV3orV4,'v4'); nF=5; else; nF=1; end;
  global mygrid; mygrid=[]; grid_load(dirGrid,nF);

  if strcmp(choiceV3orV4,'v4'); LATS=[-89:89]'; else; LATS=[-75:75]'; end;
  LATS_MASKS=line_zonal_TUV_MASKS(LATS);
  eval(['SECTIONS_MASKS=line_greatC_TUV_MASKS_' choiceV3orV4 ';']);
  RF=squeeze(mygrid.RF)';

  dirOut=[dirIn 'matlabDiags/']; eval(['mkdir ' dirOut ';']);
end;

%%%%%%%%%%%%%%%%%
%do computations:
%%%%%%%%%%%%%%%%%

listFld=dir([dirIn 'DDtheta.00*data']);
listTimes=[]; for tt=1:length(listFld); listTimes=[listTimes;str2num(listFld(tt).name(9:end-5))]; end; 

for setDiags=1:2

for ttt=1:length(listTimes);

tt=listTimes(ttt);
tic;

if setDiags==1;
fileFld='DDuvel'; msk=mygrid.hFacC; fldU=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldU=mean(fldU,4); fldU(msk==0)=NaN;
fileFld='DDvvel'; msk=mygrid.hFacC; fldV=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldV=mean(fldV,4); fldV(msk==0)=NaN;
[fldBAR]=calc_barostream(fldU,fldV);
[fldOV]=calc_overturn(fldU,fldV,LATS_MASKS);
[fldTRANSPORTS]=calc_transports(fldU,fldV,SECTIONS_MASKS);
listDiags='fldBAR fldOV fldTRANSPORTS';
elseif setDiags==2;
fileFld='DDtheta'; msk=mygrid.hFacC; fldT=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldT=mean(fldT,4); fldT(msk==0)=NaN;
fileFld='DDsalt'; msk=mygrid.hFacC; fldS=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldS=mean(fldS,4); fldS(msk==0)=NaN;
fileFld='ADVx_TH'; msk=mygrid.hFacW; fldADVTX=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldADVTX=mean(fldADVTX,4); fldADVTX(msk==0)=NaN;
fileFld='ADVy_TH'; msk=mygrid.hFacS; fldADVTY=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldADVTY=mean(fldADVTY,4); fldADVTY(msk==0)=NaN;
fileFld='ADVx_SLT'; msk=mygrid.hFacW; fldADVSX=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldADVSX=mean(fldADVSX,4); fldADVSX(msk==0)=NaN;
fileFld='ADVy_SLT'; msk=mygrid.hFacS; fldADVSY=rdmds2gcmfaces([dirIn fileFld],tt,nF); fldADVSY=mean(fldADVSY,4); fldADVSY(msk==0)=NaN;
[fldTzonmean]=calc_zonmean_T(fldT,LATS_MASKS);
[fldSzonmean]=calc_zonmean_T(fldS,LATS_MASKS);
[fldMT_H]=1e-15*4e6*calc_MeridionalTransport(fldADVTX,fldADVTY,LATS_MASKS);
[fldMT_FW]=1e-6/35*calc_MeridionalTransport(fldADVSX,fldADVSY,LATS_MASKS);
listDiags='fldTzonmean fldSzonmean fldMT_H fldMT_FW';
end;

eval(['save ' dirOut 'set' num2str(setDiags) '_' num2str(tt) '.mat ' listDiags ';']);
fprintf([num2str(ttt) '/' num2str(length(listTimes)) ' done in ' num2str(toc) '\n']);

end;%for ttt=1:length(listTimes);
end;%for setDiags=1:2


