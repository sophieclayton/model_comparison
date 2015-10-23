function [xx,yy] = m_ll2xy(x,y,varargin)

xx=x; yy=y;

for iFace=1:x.nFaces;
   iF=num2str(iFace); 
   eval(['[tmpx,tmpy]=m_ll2xy(x.f' iF ',y.f' iF ',varargin{:});']);
   eval(['xx.f' iF '=tmpx; yy.f' iF '=tmpy;']); 
end;


