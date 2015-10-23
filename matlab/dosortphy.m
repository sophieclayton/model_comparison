itc = '1994-1999';
pre = 'intr';
avdir = [ pre 'TRAC/' ];

load cube66 nx ny rac

sm = [];

for itr = 1:99
  trname = sprintf('TRAC%02d', itr)

  p = readbin([avdir pre trname '.' itc '.data'], [nx,ny]);

  sm(itr) = intxy(p, rac);
end

f=fopen('totalTRAC.tab','w');
fprintf(f,'%.16e\n',sm);
fclose(f);

[smx imx] = sort(-sm(22:99)); 
smx = -smx;

f=fopen('imx.tab','w');
fprintf(f,'%d\n',imx);
fclose(f);

f=fopen('smx.tab','w');
fprintf(f,'%.16e\n',smx);
fclose(f);

