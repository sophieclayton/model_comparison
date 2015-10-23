function r = exp(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=exp(p.f' iF ');']); 
end;


