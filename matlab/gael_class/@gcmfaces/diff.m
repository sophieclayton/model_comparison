function r = diff(p,varargin)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=diff(p.f' iF ',varargin{:});']); 
end;


