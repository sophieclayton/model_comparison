function r = squeeze(p)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=squeeze(p.f' iF ');']); 
end;


