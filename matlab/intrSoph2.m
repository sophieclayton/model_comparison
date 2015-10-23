function res = intrSoph2(infield, drF,Depth, HFacC)

tmp=zeros(160,360); 
dep=0;

for n=1:78

clear field1 
%field=squeeze(infield(:,:,:,:));

kn1=1;
kn2=23;

for k=kn1:kn2, tmp=tmp+squeeze(infield(n,k,:,:)).*squeeze(HFacC(k,:,:))*drF(k); 
    dep=dep+drF(k);
end % for k

dd=dep*ones(160,360);
clear fi, fi=find(Depth<dd); dd(fi)=Depth(fi);
clear fi, fi=find(dd==0); dd(fi)=1;
% res=tmp./dd;
res(n,:,:)=tmp;
end