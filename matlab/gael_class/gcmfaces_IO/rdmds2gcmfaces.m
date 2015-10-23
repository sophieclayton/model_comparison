function [fldOut]=rdmds2gcmfaces(fileName,varargin);

if nargin>=3&~isempty(varargin{1}); 
	v0=rdmds(fileName,varargin{1:end-1}); 	nFaces=varargin{end};
elseif nargin>=3&isempty(varargin{1}); 
	v0=rdmds(fileName,varargin{2:end-1});   nFaces=varargin{end};
elseif nargin==2~isempty(varargin{1}); 
	v0=rdmds(fileName,varargin{1}); 	nFaces=5;
else; 	
	v0=rdmds(fileName); 			nFaces=5; 
end;
 
fldOut=convert2gcmfaces(v0,nFaces);

