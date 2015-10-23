function r = sqrt(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=sqrt(p.f' iF ');']); 
end;


