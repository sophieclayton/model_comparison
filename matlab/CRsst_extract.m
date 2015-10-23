% script to read in THETA files and get annual average

year=1999;
outpref='CRsst';
it1=69840;
step=720;
it2=it1+(11*step);
sst=zeros(360,160);
iit=0;

for i=it1:720:it2;
    in=sprintf('/home/stephd/ECCO/iter177/Dynvars2/DDtheta.00000%05d.data',i);
    tmp=readbin(in,[360 160]);
    sst=sst+tmp;
    iit=iit+1
end
CRsst=sst./12;

fn=sprintf('%s.%04d.data',outfpref,year);
fid=fopen(fn,'w','ieee-be');
fwrite(fid,CRsst,'float32');
fclose(fid);