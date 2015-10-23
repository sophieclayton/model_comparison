function r = zeros(p,varargin)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['[n1,n2]=size(p.f' iF '(:,:,1));']);
   eval(['r.f' iF '=zeros(n1,n2,varargin{:});']); 
end;


