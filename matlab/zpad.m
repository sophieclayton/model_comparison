function padded = zpad(a)
  sz = [size(a) 1 1 1];
  padded = cat(1, cat(2, reshape(a, sz), zeros(sz(1),1,sz(3))), ...
                  zeros(1,sz(2)+1,sz(3)));
end
