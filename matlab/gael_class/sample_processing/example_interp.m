clear all;

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%
choiceV3orV4='v4'

if ~isempty(choiceV3orV4)&isempty(whos('mygrid'));
  gcmfaces_path;
  dir0=[gcmfaces_dir '/sample_input/'];
  dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
  dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
  if strcmp(choiceV3orV4,'v4'); nF=5; else; nF=1; end;
  global mygrid; mygrid=[]; grid_load(dirGrid,nF);
end;

%%%%%%%%%%%%%%%%%%%%%%%
%get sample data: V3 SSH
dirV3=[gcmfaces_dir '/sample_input/SAMPLEv3/'];
etan=rdmds([dirV3 'DDetan'],0); etan(etan==0)=NaN;
dirV3=[gcmfaces_dir '/sample_input/GRIDv3/'];
lon=rdmds([dirV3 'XC']); lat=rdmds([dirV3 'YC']);

%%%%%%%%%%%%%%%%%%%%%%%
%do the interpolation:
x=[lon-360;lon]; y=[lat;lat]; z=[etan;etan];

z_interp=gcmfaces(5);
for ii=1:5;
xi=mygrid.XC{ii}; yi=mygrid.YC{ii};
zi = interp2(x',y',z',xi,yi);
z_interp{ii}=zi;
end;

%%%%%%%%%%%%%%%%%%%%%%%
%illustrate the result:

figure; set(gcf,'Units','Normalized','Position',[0.1 0.3 0.4 0.6]);
x=[lon-360;lon]; y=[lat;lat]; z=[etan;etan];
pcolor(x,y,z); axis([-180 180 -90 90]); shading flat; caxis([-2 1]); colorbar;

figure; set(gcf,'Units','Normalized','Position',[0.5 0.3 0.4 0.6]);
[X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,z_interp);
pcolor(X,Y,FLD); axis([-180 180 -90 90]); shading flat; caxis([-2 1]); colorbar;



