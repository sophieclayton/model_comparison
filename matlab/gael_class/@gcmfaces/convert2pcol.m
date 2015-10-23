function [X,Y,FLD]=convert2pcol(varargin);

c=varargin{1};

if strcmp(c.gridType,'llc');
   [X,Y,FLD]=convert2pcol_llc(varargin{:}); 
elseif strcmp(c.gridType,'cube');
   [X,Y,FLD]=convert2pcol_cube(varargin{:});
elseif strcmp(c.gridType,'llpc');
   [X,Y,FLD]=convert2pcol_llpc(varargin{:});
elseif strcmp(c.gridType,'ll');
   [X,Y,FLD]=convert2pcol_ll(varargin{:});
else;
   error(['convert2pcol not implemented for ' c.gridType '!?']);
end;

