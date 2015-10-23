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
%generate delaunay triangulation

XC=convert2array(mygrid.XC);
YC=convert2array(mygrid.YC);

%needed so that we do not loose data
XC(isnan(XC))=270;
YC(isnan(YC))=180;

TRI=delaunay(XC,YC);
nxy = prod(size(XC));
Stri=sparse(TRI(:,[1 1 2 2 3 3]),TRI(:,[2 3 1 3 1 2]),1,nxy,nxy);

%%%%%%%%%%%%%%%%%%%%%%%
%generate random data

nobs=1e6;
lat=(rand(nobs,1)-0.5)*2*90;
lon=(rand(nobs,1)-0.5)*2*180;  xx=find(lon>180);lon(xx)=lon(xx)-360;
obs=(rand(nobs,1)-0.5)*2;

%%%%%%%%%%%%%%%%%%%%%%%%
%bin average random data

OBS=0*XC; NOBS=OBS; 
ik=dsearch(XC,YC,TRI,lon,lat,Stri);
for k=1:length(ik)
	NOBS(ik(k))=NOBS(ik(k))+1;
	OBS(ik(k))=OBS(ik(k))+obs(k);
end  % k=1:length(ik)

in=find(NOBS); OBS(in)=OBS(in)./NOBS(in);
in=find(~NOBS); OBS(in)=NaN; NOBS(in)=NaN;

obsmap=convert2array(OBS,mygrid.XC);	%put in gcmfaces format
obsmapcompact=convert2gcmfaces(obsmap);	%put in gcm input format

whos obs* OBS

figure; set(gcf,'Units','Normalized','Position',[0.1 0.3 0.4 0.6]);
imagescnan(OBS','nancolor',[1 1 1]*0.8); axis xy; caxis([-1 1]/2); colorbar;
figure; set(gcf,'Units','Normalized','Position',[0.5 0.3 0.4 0.6]);
imagescnan(NOBS','nancolor',[1 1 1]*0.8); axis xy; caxis([0 25]); colorbar;

%..... now illustrate the smoothing filter
test=input('illustrate smoothing filter? \n type 1 for yes or 0 for no\n');
if test; example_smooth; end;


