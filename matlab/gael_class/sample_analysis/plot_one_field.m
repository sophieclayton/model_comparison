clear all;

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%
choiceV3orV4=input('please select grid by typing ''v4'' \n (next time try ''v3'')\n');

if ~isempty(choiceV3orV4)&isempty(whos('mygrid'));
  gcmfaces_path;
  dir0=[gcmfaces_dir '/sample_input/'];
  dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
  dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
  if strcmp(choiceV3orV4,'v4'); nF=5; else; nF=1; end; 
  global mygrid; mygrid=[]; grid_load(dirGrid,nF); 
end;

%%%%%%%%%%%
%get field:
%%%%%%%%%%%
nameFld='DDtheta'; tt=0; if strcmp(choiceV3orV4,'v4'); kk=30; else; kk=14; end; cc=[-2 8];
fld=rdmds2gcmfaces([dirIn nameFld],tt,nF);
fld=fld(:,:,kk); msk=mygrid.hFacC(:,:,kk); fld(find(msk==0))=NaN;
 
%%%%%%%%%%%%
%plot field:
%%%%%%%%%%%%
figure; set(gcf,'Units','Normalized','Position',[0.1 0.3 0.4 0.6]);
[X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,fld); pcolor(X,Y,FLD); 
if ~isempty(find(X>359)); axis([0 360 -90 90]); else; axis([-180 180 -90 90]); end;
shading flat; caxis(cc); colorbar; xlabel('longitude'); ylabel('latitude');

figure; set(gcf,'Units','Normalized','Position',[0.5 0.3 0.4 0.6]);
FLD=convert2array(fld);
imagescnan(FLD','nancolor',[1 1 1]*0.8); axis xy; caxis(cc); colorbar;

if nF==5;
figure; set(gcf,'Units','Normalized','Position',[0.3 0.1 0.4 0.6]);
subplot(3,3,7); imagescnan(fld{1}','nancolor',[1 1 1]*0.8); axis xy; caxis(cc);
subplot(3,3,8); imagescnan(fld{2}','nancolor',[1 1 1]*0.8); axis xy; caxis(cc); 
subplot(3,3,5); imagescnan(fld{3}','nancolor',[1 1 1]*0.8); axis xy; caxis(cc); 
subplot(3,3,6); imagescnan(fld{4}','nancolor',[1 1 1]*0.8); axis xy; caxis(cc); 
subplot(3,3,3); imagescnan(fld{5}','nancolor',[1 1 1]*0.8); axis xy; caxis(cc); 
end;

