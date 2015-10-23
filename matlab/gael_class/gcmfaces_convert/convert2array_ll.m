function [FLD]=convert2array_ll(fld,varargin);

if isa(fld,'gcmfaces'); do_gcmfaces2array=1; else; do_gcmfaces2array=0; end;

if do_gcmfaces2array;
   FLD=fld.f1;
else;
   FLD=NaN*varargin{1};
   FLD.f1=fld;
end;


