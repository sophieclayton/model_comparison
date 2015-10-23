
doComp=0;
doSave=0;
doPlot=1;
doPrint=1;

%%%%%%%%%%%
%load grid:
%%%%%%%%%%%

dirGrid='/net/weddell/raid3/gforget/gcmfaces/sample_input/GRIDv4/';
global mygrid;
if isempty(mygrid);
  gcmfaces_path; grid_load(dirGrid,5);
  LATS=[-89:89]'; LATS_MASKS=line_zonal_TUV_MASKS(LATS);
%  SECTIONS_MASKS=line_greatC_TUV_MASKS_v4;
end;

%%%%%%%%%%%%%%%
%define pathes:
%%%%%%%%%%%%%%%

dirData='/net/altix3700/raid4/gforget/mysetups/ecco_v4/INPUTS_90x50/';
dirIn='./';
dirOut=[dirIn 'matlabDiagsCost/']; if isempty(dir(dirOut)); eval(['mkdir ' dirOut ';']); end;
runName=pwd; tmp1=strfind(runName,'/'); runName=runName(tmp1(end)+1:end);

%%%%%%%%%%%%%%%%%
%do computations:
%%%%%%%%%%%%%%%%%

if doComp==0; 
  eval(['load ' dirOut 'cost_altimeter.mat myflds;']);
else;

tic;
%mdt cost function term (misfit plot)
dif_mdt=rdmds2gcmfaces('barfiles/mdtdiff_smooth');
sig_mdt=v4_read_bin([dirData 'sigma_MDT_glob_eccollc.bin'],1,0);
%store:
myflds.dif_mdt=dif_mdt;
myflds.sig_mdt=sig_mdt;

toc; tic;
%lsc cost function term:
sladiff_smooth=rdmds2gcmfaces('barfiles/sladiff_smooth');
%skip blanks:
sladiff_smooth=sladiff_smooth(:,:,1:7:6147); sladiff_smooth(sladiff_smooth==0)=NaN;
%compute rms:
rms_sladiff_smooth=sqrt(nanmean(sladiff_smooth.^2,3));
%get weight:
sig_sladiff_smooth=v4_read_bin([dirData 'sigma_SLA_smooth_eccollc.bin'],1,0);
%store:
myflds.rms_sladiff_smooth=rms_sladiff_smooth;
myflds.sig_sladiff_smooth=sig_sladiff_smooth;

toc; tic;
%pointwise/35days cost function term:
sladiff_35d=rdmds2gcmfaces('barfiles/sladiff_raw');
%skip blanks:
sladiff_35d=sladiff_35d(:,:,1:7:6147); sladiff_35d(sladiff_35d==0)=NaN;
%compute rms:
rms_sladiff_35d=sqrt(nanmean(sladiff_35d.^2,3));
%store:
myflds.rms_sladiff_35d=rms_sladiff_35d;

toc; tic;
%pointwise/1day terms:
sum_all=0*mygrid.XC; msk_all=sum_all;
for ii=1:3; 
  if ii==1; myset='tp'; elseif ii==2; myset='gfo'; else; myset='ers'; end;
  %topex pointwise misfits:
  sladiff_point=rdmds2gcmfaces(['barfiles/sladiff_' myset '_raw']);
  %compute rms:
  msk_tmp=1*(sladiff_point~=0); 
  msk_tmp=sum(msk_tmp,3); sum_tmp=sum(sladiff_point.^2,3);
  sum_all=sum_all+sum_tmp; msk_all=msk_all+msk_tmp;
  eval(['rms_' myset '=sum_tmp./msk_tmp;']);
end;
%compute overall rms:
rms_sladiff_point=sqrt(sum_all./msk_all);
%fill blanks:
rms_sladiff_point=diffsmooth2D_extrap_inv(rms_sladiff_point,mygrid.mskC(:,:,1));
%get weight:
sig_sladiff_point=v4_read_bin([dirData 'sigma_SLA_PWS07r2_glob_eccollc.bin'],1,0);
%store:
myflds.rms_tp=rms_tp; myflds.rms_gfo=rms_gfo; myflds.rms_ers=rms_ers; 
myflds.rms_sladiff_point=rms_sladiff_point;
myflds.sig_sladiff_point=sig_sladiff_point;

%compute zonal mean/median:
for ii=1:3;
  switch ii;
    case 1; tmp1='mdt'; cost_fld=(mygrid.mskC(:,:,1).*myflds.dif_mdt./myflds.sig_mdt).^2;
    case 2; tmp1='lsc'; cost_fld=(mygrid.mskC(:,:,1).*myflds.rms_sladiff_smooth./myflds.sig_sladiff_smooth).^2;
    case 3; tmp1='point'; cost_fld=(mygrid.mskC(:,:,1).*myflds.rms_sladiff_point./myflds.sig_sladiff_point).^2;
  end;    
  cost_zmean=calc_zonmean_T(cost_fld,LATS_MASKS); eval(['mycosts_mean.' tmp1 '=cost_zmean;']);
  cost_zmedian=calc_zonmedian_T(cost_fld,LATS_MASKS); eval(['mycosts_median.' tmp1 '=cost_zmedian;']);
end;

toc; %write to disk:
if doSave; eval(['save ' dirOut 'cost_altimeter.mat myflds mycosts_mean mycosts_median;']); end;

end;%if doComp

if doPlot; 
figure; m_map_gcmfaces(myflds.dif_mdt,0,[-0.2:0.02:0.2]); drawnow;
figure; m_map_gcmfaces(myflds.rms_sladiff_smooth,0,[0:0.01:0.1]); drawnow;
figure; m_map_gcmfaces(myflds.rms_sladiff_35d,0,[0:0.01:0.1]); drawnow;
figure; m_map_gcmfaces(myflds.rms_sladiff_point,0,[0:0.02:0.2]); drawnow; 
end;

if doPlot&doPrint;
  dirFig='../figs/altimeter/'; ff0=gcf-4;
  for ff=1:4; 
    figure(ff+ff0); saveas(gcf,[dirFig runName '_fig' num2str(ff)],'fig'); 
    eval(['print -depsc ' dirFig runName '_fig' num2str(ff) '.eps;']);   
    eval(['print -djpeg90 ' dirFig runName '_fig' num2str(ff) '.jpg;']); 
  end;
end;

