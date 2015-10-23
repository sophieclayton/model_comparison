function r = real(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=real(p.f' iF ');']); 
end;


