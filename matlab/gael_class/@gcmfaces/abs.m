function r = abs(p)

r=p;
for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=abs(p.f' iF ');']); 
end;


