function r = tan(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=tan(p.f' iF ');']); 
end;


