function r = sin(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=sin(p.f' iF ');']); 
end;


