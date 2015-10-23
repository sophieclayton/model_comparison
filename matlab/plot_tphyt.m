%run extract_field for phytoplankton

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']); 
plankton=plankton_ini_char_nohead;

 filand1=find(HFacC(1,:,:)==0);
 cax1=-1; cax2=1;
 figure
 for i=1:78
   if (plankton(i,1)==1), fstr='D'; end  % diatom
   if (plankton(i,1)==0 & plankton(i,3)==1); fstr='L'; end % other big
   if (plankton(i,3)==0 & plankton(i,19)==3); fstr='S'; end % other small
   if (plankton(i,3)==0 & plankton(i,19)<3);  fstr='P'; end
   tmp=squeeze(infield(:,:,i));
   tmp(filand1)=NaN;
   numwinx = 8; numwiny = 10;
   xwide = 0.125; yhigh = 0.095;
   xleft = mod(i-1,numwinx)*xwide;
   ybottom  = 1.0 - (((i-mod(i-1,numwinx))/numwinx)+1)*yhigh;
   h=axes('position',[(xleft+0.005) (ybottom) (xwide-0.01) (yhigh-0.01)]);
   colormap default; cmap=colormap;
   colormap(cmap([8 25:2:58],:));
   pcolor(X,Y,squeeze(tmp)'); caxis([cax1 cax2]); shading flat;hold on;contourf(X,Y,squeeze(HFacC(:,:,1)'),0.5,'k')

   set(gca,'fontweight','light'); set(gca,'fontsize',2);
   set(h,'xticklabel',[]); set(h,'yticklabel',[]);
   text(50,50,[num2str(i),' ',fstr]);
 end % for
