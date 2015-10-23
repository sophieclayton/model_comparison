
%%%%%%%%%%%
%load grid:
%%%%%%%%%%%

dirGrid='/raid3/gforget/gcmfaces/sample_input/GRIDv4/';
global mygrid;
if isempty(mygrid);
  gcmfaces_path; grid_load(dirGrid,5);
  LATS=[-89:89]'; LATS_MASKS=line_zonal_TUV_MASKS(LATS);
  SECTIONS_MASKS=line_greatC_TUV_MASKS_v4;
end;

%%%%%%%%%%%%
%define run:
%%%%%%%%%%%%

dirIn='./';
dirOut=[dirIn 'matlabDiags/']; if isempty(dir(dirOut)); eval(['mkdir ' dirOut ';']); end;

%%%%%%%%%%%%%%
%define diags:
%%%%%%%%%%%%%%

suffOut='basic';

listDiags='fldBAR fldOV fldTRANSPORTS fldMT_H fldMT_FW';
listDiags=[listDiags ' fldTzonmean fldSzonmean fldSSHzonmean fldSIzonmean fldMLDzonmean'];
listDiags=[listDiags ' fldTZzonmean fldTMzonmean fldTFLzonmean fldSFLzonmean'];
listDiags=[listDiags ' IceAreaNorth IceAreaSouth IceVolNorth IceVolSouth SnowVolNorth SnowVolSouth'];
jj=strfind(listDiags,' '); jj=[0 jj length(listDiags)+1];
for ii=1:length(jj)-1;
  tmp1=listDiags(jj(ii)+1:jj(ii+1)-1); 
  if ii==1; listDiags2={tmp1}; else; listDiags2{ii}=tmp1; end;
end;

%%%%%%%%%%%%%%
%detect files:
%%%%%%%%%%%%%%

listTimes=[]; 
tmp1=dir([dirIn 'diags/diags_3d_set1.00*data']);
for tt=1:length(tmp1); listTimes=[listTimes;str2num(tmp1(tt).name(end-14:end-5))]; end;

listFlds={'UVEL','VVEL','THETA','SALT','ADVx_TH','ADVy_TH','ADVx_SLT','ADVy_SLT',...
        'ETAN','SIarea','SIheff','SIhsnow','oceTAUX','oceTAUY','TFLUX','SFLUX','MXLDEPTH'};
listFiles={'diags_2d_set1','diags_3d_set1','diags_ice_set1'};
listSubdirs={'diags'};

for ii=1:length(listFiles);
  tmp0='';
  for jj=1:length(listSubdirs);
    tmp1=listFiles{ii}; tmp2=listSubdirs{jj};
    if ~isempty(dir([dirIn tmp2 '/' tmp1 '*meta']));
      tmp0=[dirIn tmp2 '/' tmp1]; listFiles{ii}=tmp0;
    end;
  end;
  if isempty(tmp0); fprintf([' not found: ' tmp1 '\n']); listFiles{ii}=''; end;
end;

%%%%%%%%%%%%%%%%%%%%
%do the computation:
%%%%%%%%%%%%%%%%%%%%
for ttt=1:length(listTimes);

tt=listTimes(ttt);

tic;
for iFile=1:length(listFiles);
  fileFld=listFiles{iFile};
  if ~isempty(fileFld);
    rdmds2workspace(fileFld,tt);
  end;
end;
%toc; 

%tic;
fldU=UVEL.*mygrid.mskW; fldV=VVEL.*mygrid.mskS; 
fldT=THETA.*mygrid.mskC; fldS=SALT.*mygrid.mskC;
if ~isempty(whos('ADVx_TH')); 
  ADVx_TH=ADVx_TH.*mygrid.mskW; ADVy_TH=ADVy_TH.*mygrid.mskS;
  ADVx_SLT=ADVx_SLT.*mygrid.mskW; ADVy_SLT=ADVy_SLT.*mygrid.mskS;
end;
fldSSH=ETAN.*mygrid.mskC(:,:,1); 
fldSI=SIarea.*mygrid.mskC(:,:,1); 
fldMLD=MXLDEPTH.*mygrid.mskC(:,:,1);
fldTFL=TFLUX.*mygrid.mskC(:,:,1);
fldSFL=SFLUX.*mygrid.mskC(:,:,1);
fldTX=oceTAUX.*mygrid.mskW(:,:,1);
fldTY=oceTAUY.*mygrid.mskS(:,:,1);
%toc;

%tic;
[fldBAR]=calc_barostream(fldU,fldV);
[fldOV]=calc_overturn(fldU,fldV,LATS_MASKS);
[fldTRANSPORTS]=calc_transports(fldU,fldV,SECTIONS_MASKS);
if ~isempty(whos('ADVx_TH'));
  [fldMT_H]=1e-15*4e6*calc_MeridionalTransport(ADVx_TH,ADVy_TH,LATS_MASKS);
  [fldMT_FW]=1e-6/35*calc_MeridionalTransport(ADVx_SLT,ADVy_SLT,LATS_MASKS);
else;
  fldMT_H=[]; fldMT_FW=[];
end;
[fldTzonmean]=calc_zonmean_T(fldT,LATS_MASKS);
[fldSzonmean]=calc_zonmean_T(fldS,LATS_MASKS);
[fldSSHzonmean]=calc_zonmean_T(fldSSH,LATS_MASKS);
[fldSIzonmean]=calc_zonmean_T(fldSI,LATS_MASKS);
[fldMLDzonmean]=calc_zonmean_T(fldMLD,LATS_MASKS);
[fldTZ,fldTM]=calc_UEVNfromUXVY(fldTX,fldTY);
[fldTZzonmean]=calc_zonmean_T(fldTZ,LATS_MASKS); 
[fldTMzonmean]=calc_zonmean_T(fldTM,LATS_MASKS);
[fldTFLzonmean]=calc_zonmean_T(fldTFL,LATS_MASKS);
[fldSFLzonmean]=calc_zonmean_T(fldSFL,LATS_MASKS);
%
fld=SIarea.*mygrid.RAC.*(mygrid.YC>0); IceAreaNorth=sum(fld);
fld=SIarea.*mygrid.RAC.*(mygrid.YC<0); IceAreaSouth=sum(fld);
fld=SIheff.*mygrid.RAC.*(mygrid.YC>0); IceVolNorth=sum(fld);
fld=SIheff.*mygrid.RAC.*(mygrid.YC<0); IceVolSouth=sum(fld);
fld=SIhsnow.*mygrid.RAC.*(mygrid.YC>0); SnowVolNorth=sum(fld);
fld=SIhsnow.*mygrid.RAC.*(mygrid.YC<0); SnowVolSouth=sum(fld);
%toc;

eval(['save ' dirOut 'diags_' suffOut '_' num2str(tt) '.mat ' listDiags ';']);
fprintf([num2str(ttt) '/' num2str(length(listTimes)) ' done in ' num2str(toc) '\n']);

end;


