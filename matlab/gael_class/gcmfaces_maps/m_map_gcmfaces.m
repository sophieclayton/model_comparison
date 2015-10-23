function []=m_map_gcmfaces(fld,varargin);

global mygrid;

if nargin>1; choicePlot=varargin{1}; else; choicePlot=0; end;
if nargin>2; cc=varargin{2}; else; cc=[]; end;
if nargin>3; doPlotCoast=varargin{3}; else; doPlotCoast=1; end;

if choicePlot==-1;
%%m_proj('Miller Cylindrical','lat',[-90 90]);
%%m_proj('Equidistant cylindrical','lat',[-90 90]);
m_proj('mollweide','lon',[-180 180],'lat',[-80 80]);
%m_proj('mollweide','lon',[-50 50],'lat',[20 60]);
[xx,yy,z]=convert2pcol(mygrid.XC,mygrid.YC,fld);
[x,y]=m_ll2xy(xx,yy);

pcolor(x,y,z); shading flat; if ~isempty(cc); caxis(cc); end; colorbar;
if doPlotCoast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end; m_grid;
end;%if choicePlot==0|choicePlot==1; 

if choicePlot==0; subplot(2,1,1); end;
if choicePlot==0|choicePlot==1; 
m_proj('Mercator','lat',[-70 70]);
[xx,yy,z]=convert2pcol(mygrid.XC,mygrid.YC,fld);
[x,y]=m_ll2xy(xx,yy);

pcolor(x,y,z); shading flat; if ~isempty(cc); caxis(cc); end; colorbar;
if doPlotCoast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end; m_grid;
end;%if choicePlot==0|choicePlot==1; 

if choicePlot==0; subplot(2,2,3); end;
if choicePlot==0|choicePlot==2; 
m_proj('Stereographic','lon',0,'lat',90,'rad',40);
xx=convert2arctic(mygrid.XC);
yy=convert2arctic(mygrid.YC);
z=convert2arctic(fld);
[x,y]=m_ll2xy(xx,yy);

pcolor(x,y,z); shading flat; if ~isempty(cc); caxis(cc); end; colorbar;
if doPlotCoast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end; m_grid;
end;%if choicePlot==0|choicePlot==1; 

if choicePlot==0; subplot(2,2,4); end;
if choicePlot==0|choicePlot==3; 
m_proj('Stereographic','lon',0,'lat',-90,'rad',40);
xx=convert2southern(mygrid.XC);
yy=convert2southern(mygrid.YC);
z=convert2southern(fld);
[x,y]=m_ll2xy(xx,yy);

pcolor(x,y,z); shading flat; if ~isempty(cc); caxis(cc); end; colorbar;
if doPlotCoast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end; m_grid;
end;%if choicePlot==0|choicePlot==1; 



