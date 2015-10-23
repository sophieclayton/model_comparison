function [varargout]=gcmfaces_bindata(varargin);

warning('off','MATLAB:dsearch:DeprecatedFunction');

global mygrid mytri;

if nargin==0;
%generate delaunay triangulation:
XC=convert2array(mygrid.XC);
YC=convert2array(mygrid.YC);
%needed so that we do not loose data
XC(isnan(XC))=270;
YC(isnan(YC))=180;
%
TRI=delaunay(XC,YC); nxy = prod(size(XC));
Stri=sparse(TRI(:,[1 1 2 2 3 3]),TRI(:,[2 3 1 3 1 2]),1,nxy,nxy);
%
mytri.XC=XC; mytri.YC=YC; mytri.TRI=TRI; mytri.Stri=Stri;
%usage: ik=dsearch(mytri.XC,mytri.YC,mytri.TRI,lon,lat,mytri.Stri);
%	where lon and lat are vector of position

elseif nargin==2;
%compute grid point vector associated with lon/lat vectors
lon=varargin{1}; lat=varargin{2};
ik=dsearch(mytri.XC,mytri.YC,mytri.TRI,lon,lat,mytri.Stri);
if nargout==1; 
  varargout={ik};
elseif nargout==2;
  jj=ceil(ik/size(mytri.XC,1));
  ii=ik-(jj-1)*size(mytri.XC,1);
  varargout={ii}; varargout(2)={jj};
else;
  error('wrong output choice');
end;
elseif nargin==3;
%do the bin average (if nargout==1) or the bin sum+count (if nargout==2)
lon=varargin{1}; lat=varargin{2}; obs=varargin{3};
ii=find(~isnan(obs)); lon=lon(ii); lat=lat(ii); obs=obs(ii);
ik=dsearch(mytri.XC,mytri.YC,mytri.TRI,lon,lat,mytri.Stri);

OBS=0*mytri.XC; NOBS=OBS;
for k=1:length(ik)
        NOBS(ik(k))=NOBS(ik(k))+1;
        OBS(ik(k))=OBS(ik(k))+obs(k);
end  % k=1:length(ik)

if nargout==1;%output bin average
  in=find(NOBS); OBS(in)=OBS(in)./NOBS(in);
  in=find(~NOBS); OBS(in)=NaN; NOBS(in)=NaN;
  varargout={convert2array(OBS,mygrid.XC)};
elseif nargout==2;%output bin sum+count
  OBS=convert2array(OBS,mygrid.XC);
  NOBS=convert2array(NOBS,mygrid.XC);
  varargout={OBS}; varargout(2)={NOBS};
else;
  error('wrong output choice');
end;

else;
error('wrong input choice');
end;

warning('on','MATLAB:dsearch:DeprecatedFunction');



