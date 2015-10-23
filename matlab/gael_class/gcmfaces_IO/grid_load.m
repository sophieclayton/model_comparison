function []=grid_load(varargin);

global mygrid;

if isempty(mygrid); 

if nargin==1; dirGrid=varargin{1}; nFaces=5;
elseif nargin==2; dirGrid=varargin{1}; nFaces=varargin{2};
else; dirGrid='/net/altix3700/raid4/gforget/mysetups/ecco_v4/RUNS/GRIDmds_90x50/'; nFaces=5;
end;

mygrid.dirGrid=dirGrid;

list0={'XC','XG','YC','YG','RAC','RAZ','RAW','RAS','DXC','DXG','DYC','DYG',...
       'hFacC','hFacS','hFacW','Depth'};
for iFld=1:length(list0);
   eval(['mygrid.' list0{iFld} '=rdmds2gcmfaces([dirGrid ''' list0{iFld} '*''],[],nFaces);']);
end;

list0={'AngleCS','AngleSN'};
test0=~isempty(dir([dirGrid 'AngleCS*']));
if test0;
  for iFld=1:length(list0);
     eval(['mygrid.' list0{iFld} '=rdmds2gcmfaces([dirGrid ''' list0{iFld} '*''],[],nFaces);']);
  end;
else;
  warning('\n AngleCS/AngleSN not found; set to 1/0 assuming lat/lon grid.\n');
  mygrid.AngleCS=mygrid.XC; mygrid.AngleCS(:)=1; 
  mygrid.AngleSN=mygrid.XC; mygrid.AngleSN(:)=0;
end;

list0={'RC','RF','DRC','DRF'};
for iFld=1:length(list0);
   eval(['mygrid.' list0{iFld} '=squeeze(rdmds([dirGrid ''' list0{iFld} '*'']));']);
end;

mygrid.hFacCsurf=mygrid.hFacC;
for ff=1:mygrid.hFacC.nFaces; mygrid.hFacCsurf{ff}=mygrid.hFacC{ff}(:,:,1); end;

mskC=mygrid.hFacC; mskC(mskC==0)=NaN; mskC(mskC>0)=1; mygrid.mskC=mskC;
mskW=mygrid.hFacW; mskW(mskW==0)=NaN; mskW(mskW>0)=1; mygrid.mskW=mskW;
mskS=mygrid.hFacS; mskS(mskS==0)=NaN; mskS(mskS>0)=1; mygrid.mskS=mskS;

end;

