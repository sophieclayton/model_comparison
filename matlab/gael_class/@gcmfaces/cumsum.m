function r = cumsum(p,varargin)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=cumsum(p.f' iF ',varargin{:});']); 
end;


