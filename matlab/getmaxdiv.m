function out = getmaxdiv(field,zmax)

[nz ny nx]=size(field);
out=NaN(nx,ny);

for x=1:nx;
for y=1:ny;
out(x,y)=max(field(1:zmax,y,x));
end
end

end

