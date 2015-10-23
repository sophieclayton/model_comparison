function r = cos(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=cos(p.f' iF ');']); 
end;


