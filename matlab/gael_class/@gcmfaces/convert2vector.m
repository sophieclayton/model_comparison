function [a]=convert2array(b,varargin);

if isa(b,'gcmfaces'); do_gcmfaces2vector=1; else; do_gcmfaces2vector=0; end;

if do_gcmfaces2vector;
  bb=convert2array(b);
  a=bb(:);
else;
  c=varargin{1};
  bb=convert2array(c);
  if length(bb(:))~=length(b(:)); error('wrong size of inputs'); end;
  b=reshape(b,size(bb)); 
  a=convert2array(b,c);
end;



