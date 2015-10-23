clear all
i=1
infile=['kr.diff'];
for year=1994:1999;
  fn=sprintf('%s.%04d.bin',infile,year);
  tmp=readbin(fn,[160 360 2]);
  kr_d(:,:,:,i)=tmp;
  i=i+1;
end


