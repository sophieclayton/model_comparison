function r = cut_T_N(p,varargin)

r=p;

if nargin==1; N=1; else; N=varargin{1}; end;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=p.f' iF '(1+N:end-N,1+N:end-N,:,:);']); 
end;


