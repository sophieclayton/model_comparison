function [a]=exch_T_N(b,varargin);

if strcmp(b.gridType,'llc');
   a=exch_T_N_llc(b,varargin{:}); 
elseif strcmp(b.gridType,'cube');
   a=exch_T_N_cube(b,varargin{:});
elseif strcmp(b.gridType,'llpc');
   a=exch_T_N_llpc(b,varargin{:});
elseif strcmp(b.gridType,'ll');
   a=exch_T_N_ll(b,varargin{:});
else;
   error(['exch_T_N not implemented for ' b.gridType '!?']);
end;

