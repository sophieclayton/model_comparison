function [a]=convert2array(b,varargin);

if isa(b,'gcmfaces'); c=b; else; c=varargin{1}; end;

if strcmp(c.gridType,'llc');
   a=convert2array_llc(b,varargin{:}); 
elseif strcmp(c.gridType,'cube');
   a=convert2array_cube(b,varargin{:});
elseif strcmp(c.gridType,'llpc');
   a=convert2array_llpc(b,varargin{:});
elseif strcmp(c.gridType,'ll');
   a=convert2array_ll(b,varargin{:});
else;
   error(['convert2array not implemented for ' c.gridType '!?']);
end;

