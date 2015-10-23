dopng=1
dops=1
dopdf=1
dolog=0
datadir = '/scratch/jahn/run/ecco2/cube84/d0006/global.intr.1994-1999/';
traitfile = '/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat'

imx = load('-ascii', [datadir 'imx.tab']);
smx = load('-ascii', [datadir 'smx.tab']);
% sm  = load('-ascii', [datadir 'totalTRAC.tab']);
% sm = sm(22:99);
sm=CRab;
if dolog
smx=smx./1e3; % mol P
sm =sm ./1e3; % mol P
smunit = 'mol P';
else
smx=smx./1e12; % Gmol P
sm =sm ./1e12; % Gmol P
smunit = '10^9 mol P';
end

pl = load('-ascii', traitfile);
whos pl
pl(:,22) = sm;

stretch=1
nx=78
ix=[imx; setdiff(1:nx,imx)']
ytick=1:nx;
ytick(11:end)=11+((11:nx)-11)./stretch;
yf=.5*([0 ytick(1:end)]+[ytick(1:end) ytick(end)*2-ytick(end-1)]);

clf

icol=[16 17 10 18 21 1 3 19 ];
names={'Kpar', 'Kinh', 'KsP', 'T(T)', 'I(PAR)', 'diat', 'size', 'nsrc'};
iT=4;
iPAR=5;
iab=length(names)+1;
icb=iab+1;
mn=[0 0 0 0 0 .5 .5 .5 ];
mx=[1 7 .055 0 0 1.5 1.5 3.5 ];
wd=[3 3 3 3 3 1 1 1 3 .7];
bx=.000
by=.05
bbx=.05
ww=1-2*bbx
totwd=sum(wd);
wd=ww*wd./totwd;
x0=bbx+[0 cumsum(wd(1:end))];

%  cb=axes('Position',[x0(iab)+bx by wd(iab)-2*bx 1-2*by]);
  cb =axes()
  plot(smx)
  xlabel('species');
  ylabel(['abundance   [' smunit ']']);
  if dolog
      set(cb,'yscale', 'log')
      set(cb,'ytick',10.^[-20:2:20]);
      set(cb,'ylim',[10^-5 2*10^11]);
  else
      set(cb,'ylim',[0 80]);
  end
  set(cb,'xlim',[0 78]);

  if dolog
    outname = 'logabundance'
  else
    outname = 'abundance'
  end
  if (dopng)
    %set(gcf,'PaperPosition', [0 0 18 8.5]);
    set(gcf,'PaperPosition', [0 0 18 12]);
    pngname = [outname '.png'];
    print('-dpng', '-r75', pngname);
  end
  if dops
    set(gcf,'PaperPosition', [0 0 6 4]);
    print('-depsc2', [outname '.eps']);
  end
  if dopdf
    set(gcf,'PaperPosition', [0 0 11 8.5]);
    print('-dpdf', [outname '.pdf']);
  end


