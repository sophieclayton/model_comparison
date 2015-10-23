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
nameFld='DDetan'; tt=[53:78]*336; cc=[0 0.10];
fld=rdmds2gcmfaces([dirIn nameFld],tt,nF);
fld=std(fld,[],3); msk=mygrid.hFacC(:,:,1); fld(find(msk==0))=NaN;
 
%%%%%%%%%%%%
%plot field:
%%%%%%%%%%%%
figure; set(gcf,'Units','Normalized','Position',[0.1 0.3 0.4 0.6]);
[X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,fld); 
pcolor(X,Y,FLD); axis([-180 180 -90 90]); shading flat; caxis(cc); colorbar; 


