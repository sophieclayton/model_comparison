function r = isnan(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=isnan(p.f' iF ');']); 
end;


