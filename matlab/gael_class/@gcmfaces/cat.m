function r = cat(nDim,p,q)

r=p;

for iFace=1:r.nFaces;
   iF=num2str(iFace); 
   eval(['r.f' iF '=cat(nDim,p.f' iF ',q.f' iF ');']); 
end;


