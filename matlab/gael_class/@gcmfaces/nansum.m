function r = nannansum(p,varargin)

if nargin==1;
   tmp1=[]; 
   for iFace=1:p.nFaces; 
      iF=num2str(iFace);
      eval(['tmp1=[tmp1;p.f' iF '(:)];']);
   end;
   r=nansum(tmp1);
   return;
end;

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=nansum(p.f' iF ',varargin{:});']); 
end;


