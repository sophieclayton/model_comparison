function s=gcmfaces(varargin);

if nargin==0; fld=5; gridType='llc'; 
elseif nargin==1; fld=varargin{1}; gridType='llc';
elseif nargin==2; fld=varargin{1}; gridType=varargin{2}; 
else; error('wrong gcmfaces definition'); end; 

nFacesMax=6;

if iscell(fld);
   s.nFaces=length(fld);
   s.gridType=gridType;
   for iF=1:s.nFaces;
      eval(['s.f' num2str(iF) '=fld{iF};']);
   end;
   for iF=s.nFaces+1:nFacesMax;   
      eval(['s.f' num2str(iF) '=[];']);
   end;
elseif isreal(fld);
   s.nFaces=fld;
   s.gridType=gridType;
   for iF=1:nFacesMax;
      eval(['s.f' num2str(iF) '=[];']);
   end;
else;
   error('wrong gcmfaces definition');
end;

s = class(s,'gcmfaces');

