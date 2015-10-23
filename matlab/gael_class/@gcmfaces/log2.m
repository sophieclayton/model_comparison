function r = log2(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=log2(p.f' iF ');']); 
end;


