dopng=1
dops=1
dolog=0
datadir = '/scratch/jahn/run/ecco2/cube84/d0006/global.intr.1994-1999/';
traitfile = '/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat'

imx = load('-ascii', [datadir 'imx.tab']);
smx = load('-ascii', [datadir 'smx.tab']);
sm=HRab;
% sm  = load('-ascii', [datadir 'totalTRAC.tab']);
% sm = sm(22:99);
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

grpletters={'P','A','S','L','D'}
grp=pl(:,19)+pl(:,3)+pl(:,1)
% pl(:,23)=grp
% [g,igrp]=sort(grp)
% ix=igrp
% for i=1:78
%  mx(i) = smx(find(imx==i))
% end
% smx=mx(ix)
for i=1:78
  mx(i) = smx(find(imx==i))
end
smx=mx
[g,igrp]=sort(grp-smx'./1000)
ix=igrp
smx=smx(ix)

sz = pl(:,3)
pl(sz==0,17) = pl(sz==0,17)/6

icol=[16 17 10 18 21 1 3 19];
names={'Kpar', 'Kinh (scaled)', 'KsP', 'T(T)', 'I(PAR)', 'diat', 'size', 'nsrc'};
iT=4;
iPAR=5;
iab=length(names)+1;
icb=iab+1;
mn=[0 0.7 0 0 0 .5 .5 .5 .5];
mx=[1 1.3 .055 0 0 1.5 1.5 3.5 1.5 ];
wd=[3 3 3 3 3 1 1 1 3 .7];
bx=.000
by=.05
bbx=.05
ww=1-2*bbx
totwd=sum(wd);
wd=ww*wd./totwd;
x0=bbx+[0 cumsum(wd(1:end))];

nplot=length(icol);

axes('Position', [x0(1)+bx by wd(1)-2*bx 1-2*by])
%mx(1)=max(pl(ix,icol(1)));
axis([mn(1) mx(1) min(yf) max(yf)])
axis ij
set(gca,'ytick',ytick)
set(gca,'yticklabel',ix)
set(gca,'xtick',[0:0.2:0.8]);

for i = 1:nplot
 if i~=iT && i~=iPAR

  ic=icol(i);
  name=char(names(i))
  if mx(i) == 0
    mx(i)=max(pl(ix,ic));
  end

  axes('Position', [x0(i)+bx by wd(i)-2*bx 1-2*by])
  if ic == 19
    igrp = pl(ix,19)+pl(ix,3)+pl(ix,1);
    ind = find(igrp == 1);
    plot(pl(ix(ind),ic),ytick(ind),'g.','MarkerSize',20);
    hold on
    ind = find(igrp == 2);
    plot(pl(ix(ind),ic),ytick(ind),'b.','MarkerSize',20);
    ind = find(igrp == 3);
    plot(pl(ix(ind),ic),ytick(ind),'c.','MarkerSize',20);
    ind = find(igrp == 4);
    plot(pl(ix(ind),ic),ytick(ind),'y.','MarkerSize',20);
    ind = find(igrp == 5);
    plot(pl(ix(ind),ic),ytick(ind),'r.','MarkerSize',20);
    hold off
  else
    plot(pl(ix,ic),ytick,'.');
  end
  axis([mn(i) mx(i) min(yf) max(yf)])
  title(name)
  axis ij
  if i == 0
    set(gca,'ytick',ytick)
    set(gca,'yticklabel',ix)
  else
    set(gca,'yticklabel',[])
    set(gca,'ytick',[.5:5:nx])
    set(gca,'ytick',.5*([0 ytick(5:5:nx)]+ytick(1:5:nx)))
    set(gca,'Ygrid','on');
  end
  if ic == 16
    set(gca,'xtick',[0:0.2:0.8]);
  end
  if ic == 3
    % size
    set(gca,'xtick',[1]);
    set(gca,'xtickl',{'big'});
  end
  if ic == 1
    set(gca,'xtick',[]);
  end

 end
end

i=iPAR;
parmax=mx(end);
parmax=1000;
axes('Position', [x0(i)+bx by wd(i)-2*bx 1-2*by])
kpar=pl(ix,16)/10.;
kinh=pl(ix,17)/1000.;
x=[0:parmax./100:parmax];
[xg,kparg]=meshgrid(x,kpar);
[xg,kinhg]=meshgrid(x,kinh);
y=.5*([0 ytick(1:end-1)]+[ytick(1:end)]);
dy=diff(yf);
[xg,yg]=meshgrid(x,y);
f=(1-exp(-kparg.*xg)).*exp(-kinhg.*xg);
nm=max(f, [] ,2)
fn=f./repmat(nm,[1 length(x)]);
%rgb=ind2rgb(f./repmat(nm,[1 length(x)]),jet(64))
%h=pcolor(x,ytick,rgb); axis ij;shading flat
%h=surf(xg,yg,xg.*0,rgb); axis ij;shading flat
%view(2)
%plot(x,yf(2)-fn(1,:),'k',x,yf(2)+x.*0,'k')
%i=1
fill([x x(end)],yf(1+1)-dy(1)*(.1+.8*[fn(1,:) 0]),'k')
hold on
axis ij
axis([min(x) max(x) 0.5 max(ytick)+0.5/stretch])
set(gca,'yticklabel',[])
for i=2:nx
  %plot(x,yf(i+1)-dy(i)*fn(i,:),'k',x,yf(i+1)+x.*0,'k')
  fill([x x(end)],yf(i+1)-dy(i)*(.1+.8*[fn(i,:) 0]),'k')
end
hold off
title('I');
xlabel('PAR');
%set(gca, 'xtick', [500 1000]);

i=iT;
axes('Position', [x0(i)+bx by wd(i)-2*bx 1-2*by])
Tmax=40;
x=[0:Tmax./100:Tmax];
Topt=pl(ix,18);
e2=pl(ix,3)*.0003+(1-pl(ix,3))*.001;
[xg,yg]=meshgrid(x,y);
[xg,Toptg]=meshgrid(x,Topt);
[xg,e2g]=meshgrid(x,e2);
Tcoeff=1./3;
e1=1.04;
f=min(1,Tcoeff*max(e1.^xg.*exp(-e2g.*(xg-Toptg).^4)-.3, 1e-10));
nm=max(f, [] ,2)
%fn=f./repmat(nm,[1 length(x)]);
fn=f;
bdy=0
fill([x(1) x x(end)],yf(1+1)-dy(1)*(bdy+(1-2*bdy)*[0 fn(1,:) 0]),'k')
hold on
axis ij
axis([min(x) max(x) 0.5 max(ytick)+0.5/stretch])
set(gca,'yticklabel',[])
for i=2:nx
  %plot(x,yf(i+1)-dy(i)*fn(i,:),'k',x,yf(i+1)+x.*0,'k')
  fill([x(1) x x(end)],yf(i+1)-dy(i)*(bdy+(1-2*bdy)*[0 fn(i,:) 0]),'k')
end
hold off
title('T');
xlabel('T');
set(gca, 'xtick', [0:10:30]);


  cb=axes('Position',[x0(iab)+bx by wd(iab)-2*bx 1-2*by]);
  plot(smx, ytick)
  axis ij
  axis([min(smx) max(smx) min(yf) max(yf)])
  %ac(ytick,1,jet(64));
  %set(cb,'ytick',(1+.5*(nmxphy-1)/nmxphy):(nmxphy-1)/(nmxphy):nmxphy);
  set(cb,'ytick',ytick);
  set(cb,'yticklabel',imx);
  set(cb,'yticklabel',[]);
  set(cb,'yaxislocation','right');
  xlabel(cb, smunit);
    set(gca,'yticklabel',[])
    set(gca,'ytick',[.5:5:nx])
    set(gca,'ytick',.5*([0 ytick(5:5:nx)]+ytick(1:5:nx)))
    set(gca,'Ygrid','on');
    set(gca,'Xgrid','off');
  title('abundance');
  if dolog
      set(cb,'xscale', 'log')
      set(cb,'xtick',10.^[0:2:20]);
      set(cb,'xlim',[10^0 2*10^11]);
  end

  load cm
  cm2=[zeros(nx-size(cm,1),3); cm];
  colormap(cm2);
  %colormap(cm2(78-length(imx)+2:end,:));

  cb=axes('Position',[x0(icb)+bx by wd(icb)-2*bx 1-2*by]);
  ac(ytick,1,cm2);
  %set(cb,'ytick',(1+.5*(nmxphy-1)/nmxphy):(nmxphy-1)/(nmxphy):nmxphy);
  set(cb,'xtick',[]);
  set(cb,'ytick',ytick);
  set(cb,'yticklabel',ix);

  if dolog
    outname = 'logplankton'
  else
    outname = 'plankton'
  end
  if (dopng)
    %set(gcf,'PaperPosition', [0 0 18 8.5]);
    %set(gcf,'PaperPosition', [0 0 18 12]);
    set(gcf,'PaperPosition', [0 0 11 14]);
    pngname = [outname '.png'];
    print('-dpng', '-r75', pngname);
  end
  if dops
    set(gcf,'PaperPosition', [0 0 8.5 11]);
    print('-dpsc2', [outname '.ps']);
  end


