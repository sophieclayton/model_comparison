function r = angle(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=angle(p.f' iF ');']); 
end;


