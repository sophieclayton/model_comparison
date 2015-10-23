function r = find(p,varargin)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=find(p.f' iF ',varargin{:});']); 
end;


