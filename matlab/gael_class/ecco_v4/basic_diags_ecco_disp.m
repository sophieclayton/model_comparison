
%%%%%%%%%%%
%load grid:
%%%%%%%%%%%

dirGrid='/raid3/gforget/gcmfaces/sample_input/GRIDv4/';
global mygrid;
if isempty(mygrid);
  gcmfaces_path; grid_load(dirGrid,5);
  LATS=[-89:89]'; LATS_MASKS=line_zonal_TUV_MASKS(LATS);
  SECTIONS_MASKS=line_greatC_TUV_MASKS_v4;
  RF=mygrid.RF'; RC=mygrid.RC';
end;

%%%%%%%%%%%%%%%%%%%%%%
%define run and atlas:
%%%%%%%%%%%%%%%%%%%%%%

dirIn='./';
dirIn=[dirIn 'matlabDiags/'];
suffIn='basic';

%timeStep=64800;
timeStep=3600;

nRunMean=12;

dirAtlas='/net/altix3700/raid4/gforget/mysetups/ecco_v4/INPUTS_90x50/ATLASmatlabDIAGS/';

%%%%%%%%%%%%%%%%%%%%%%%%%
%load pre-computed diags:
%%%%%%%%%%%%%%%%%%%%%%%%%

[alldiag,alldiag_anom]=alldiag_load(dirIn,suffIn,timeStep);

%%%%%%%%%%%%%%%
%display diags:
%%%%%%%%%%%%%%%

choiceAve=2;
if choiceAve==1;
%plot time average:
%------------------
tt0=7; tt1=tt0+16*12-1; tt=[tt0:tt1];
elseif choiceAve==2;
%plot 04-06 average:
%------------------
tt0=12*12+1; tt1=15*12; tt=[tt0:tt1];
elseif choiceAve==3;
%plot single year averages:
%------------------------
ycur=15; 
TT=alldiag.listTimes; 
tt=find(TT>(ycur-1)*365&TT<=ycur*365)';
end;

TT=alldiag.listTimes(tt);
nt=length(TT);

%barotropic streamfunction:
fld=mean(alldiag.fldBAR(:,:,tt),3);
cc=[[-80:20:-40] [-25 -15:5:15 25] [40:40:200]]; title0='Horizontal Stream Function';
figure; m_map_gcmfaces(fld,0,cc,1,title0);

%meridional streamfunction:
fld=mean(alldiag.fldOV(:,:,tt),3);
X=LATS*ones(1,length(RF)); Y=ones(length(LATS),1)*RF;
cc=[[-50:10:-30] [-24:3:24] [30:10:50]]; title0='Meridional Stream Function';
figure; set(gcf,'Renderer','zbuffer'); set(gcf,'Units','Normalized','Position',[0.05 0.1 0.4 0.8]);
pcolor(X,Y,fld); shading interp; axis([-90 90 -6000 0]); cbar_gael3(cc,'jet'); title(title0);

if 0;

%zonal mean temperature:
fld=mean(alldiag.fldTzonmean(:,:,tt),3);
X=LATS*ones(1,length(RC)); Y=ones(length(LATS),1)*RC;
cc=[[-3:1:3] [5:2:15] [18:4:34]]; title0='zonal mean temperature';
figure; set(gcf,'Renderer','zbuffer'); set(gcf,'Units','Normalized','Position',[0.05 0.1 0.4 0.8]);
pcolor(X,Y,fld); shading interp; axis([-90 90 -6000 0]); cbar_gael3(cc,'jet'); title(title0);

%zonal mean salinity:
fld=mean(alldiag.fldSzonmean(:,:,tt),3);
X=LATS*ones(1,length(RC)); Y=ones(length(LATS),1)*RC;
cc=[[33:0.2:34.4] [34.5:0.1:36]]; title0='zonal mean salinity';
figure; set(gcf,'Renderer','zbuffer'); set(gcf,'Units','Normalized','Position',[0.05 0.1 0.4 0.8]);
pcolor(X,Y,fld); shading interp; axis([-90 90 -6000 0]); cbar_gael3(cc,'jet'); title(title0); 

end;


%plot transport time series:
%---------------------------
if 0;

error('since I changed the way alldiag is read, basic_diags_display_transport needs revision')

tt=[1:length(alldiag)]; nt=length(tt); TT=listTimes(tt)*timeStep/86400;

%Bering Strait and Arctic/Atlantic exchanges:
if nt>1; figure; orient tall; end; iiList=[1 8:12]; rrList=[[-1 3];[-3 1];[-6 2];[-3 9];[-9 3];[-0.5 0.5]];
for iii=1:length(iiList); ii=iiList(iii); if nt>1; subplot(3,2,iii); end;
basic_diags_display_transport(alldiag,ii,[SECTIONS_MASKS(ii).name ' (>0 to Arctic)'],RF,listTimes,rrList(iii,:));
end;

%Florida Strait:
if nt>1; figure; orient tall; end; iiList=[3 4 6 7]; rrList=[[0 35];[0 35];[-10 10];[-10 10]];
for iii=1:length(iiList); ii=iiList(iii); if nt>1; subplot(3,2,iii); end;
basic_diags_display_transport(alldiag,ii,[SECTIONS_MASKS(ii).name ' (>0 to Atlantic)'],RF,listTimes,rrList(iii,:));
end;
%Gibraltar special case:
clear gibraltar; gibraltar.fldTRANSPORTS=[];
for jj=1:length(alldiag); gibraltar(jj).fldTRANSPORTS=-min(cumsum(alldiag(jj).fldTRANSPORTS(2,:))); end;
subplot(3,2,5); basic_diags_display_transport(gibraltar,1,'Gibraltar Overturn',RF,listTimes,[0 4]);
if nt>1; subplot(3,2,6); end; basic_diags_display_transport(alldiag,2,'Gibraltar net',RF,listTimes,[0 4]);

%Drake, ACC etc:
if nt>1; figure; orient tall; end; iiList=[13 NaN 20 19 18]; rrList=[[120 200];[NaN NaN];[120 200];[-40 10];[120 200]];
for iii=1:length(iiList); ii=iiList(iii);
if ~isnan(ii); if nt>1; subplot(3,2,iii); end; 
basic_diags_display_transport(alldiag,ii,[SECTIONS_MASKS(ii).name ' (>0 to the West)'],RF,listTimes,rrList(iii,:));
end;
end;
%Indonesian Throughflow special case:
if nt>1; subplot(3,2,6); end;
basic_diags_display_transport(alldiag,[14:17],'Indonesian Throughflow (>0 to the West)',RF,listTimes,[-40 10]);

end;

%plot time series:
%-----------------

tt=[1:length(alldiag.listTimes)]; TT=alldiag.listTimes(tt); nt=length(TT);

kk=1; fld=squeeze(alldiag_anom.fldTzonmean(:,kk,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean T anomaly -- in degC -- at ' num2str(mygrid.RC(kk)) 'm']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]);  colorbar;

kk=1; fld=squeeze(alldiag_anom.fldSzonmean(:,kk,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean S anomaly -- in psu -- at ' num2str(mygrid.RC(kk)) 'm']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]*0.2);  colorbar;

if 0;

fld=squeeze(alldiag.fldMT_H(:,tt))';
x=TT*ones(1,length(alldiag(1).fldMT_H)); y=ones(nt,1)*LATS';
%fld=runmean(fld,12,1); fprintf('applying running mean to mth\n');
figure; pcolor(x,y,fld); shading flat; caxis([-6 6]); colorbar; axis([TT(1) TT(end) -90 90]);
title('Meridional Heat Transport (in pW)'); set(gca,'FontSize',14);
colormap(jet(16)); caxis([-2 2]); colorbar;

fld=squeeze(alldiag.fldMT_FW(:,tt))';
x=TT*ones(1,length(alldiag(1).fldMT_FW)); y=ones(nt,1)*LATS';
%fld=runmean(fld,12,1); fprintf('applying running mean to mtfw\n');
figure; pcolor(x,y,fld); shading flat; caxis([-2 2]); colorbar; axis([TT(1) TT(end) -90 90]);
title('Meridional FW Transport (in ??)'); set(gca,'FontSize',14);
colormap(jet(16)); caxis([-1 1]); colorbar;

end;

fld=squeeze(alldiag_anom.fldSSHzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean SSH anomaly -- in m ']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]*0.05);  colorbar;

fld=squeeze(alldiag.fldSIzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean SI -- in m ']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([0 1]);  colorbar;

fld=squeeze(alldiag.fldMLDzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean MLD -- in m ']);
set(gca,'FontSize',14); cbar_gael3([0:50:250 300 400 500 700 1000 1500 2000 3000],'jet');

if 0;

fld=squeeze(alldiag.fldTZzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean TZ -- in m ']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]*0.15);  colorbar;

fld=squeeze(alldiag.fldTMzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean TM -- in m ']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]*0.05);  colorbar;

fld=squeeze(alldiag.fldTFLzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean TFL -- in m ']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]*200);  colorbar;

fld=squeeze(alldiag.fldSFLzonmean(:,tt))';
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
title(['zonal mean SFL -- in m ']);
set(gca,'FontSize',14); colormap(jet(15)); caxis([-1 1]*2.5e-3);  colorbar;

end;

