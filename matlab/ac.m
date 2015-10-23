function handle = ac(ytick, mxbio, cm)
  nalpha=100;
  nmx=length(ytick);
  yv=.5*([0 ytick]+[ytick ytick(end)*2-ytick(end-1)])
  nmx:-1:0
  [xg yg]=meshgrid((0:nalpha+1)./nalpha,yv);     
  [xg cg]=meshgrid((0:nalpha+1)./nalpha,nmx:-1:0);     
  %handle=surf(xg,yg,cg,'EdgeColor','none');axis ij
  cg=repmat(reshape([cm(end:-1:1,:)],[size(cm,1) 1 3]),[1 nalpha+2 1]);
  size(xg)
  size(cg)
  handle=surf(xg,yg,xg.*0,cg,'EdgeColor','none');axis ij
  view(2)
  grid off
  axis([0 mxbio yv(1) yv(end)])
  alpha(xg)
  set(gca,'YAxisLocation','right')
  set(gca,'Alim',[0 1])
end

