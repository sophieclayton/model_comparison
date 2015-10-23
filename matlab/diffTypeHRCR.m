clear all

year=1999;
outfpref='high_res/typeInter2CR/HR2CR.type'

% grid data for the coarse resolution model
vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
%  vars(3).name = 'Z';
vars(3).name = 'HFacC';
%  vars(5).name = 'rA';
%  vars(6).name = 'Depth';
%  vars(7).name = 'drF';
%  vars(8).name = 'dxC';
%  vars(9).name = 'dxG';
%  vars(10).name = 'dyC';
%  vars(11).name = 'dyG';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

HFacC=permute(HFacC,[3 2 1]);
lCR=find(HFacC(:,:,1)==0);

% load the abundances for the CR model
CR99=readbin('coarse_res/global.intr.phy/intr.phy.1999.data', [360 160 78]);


for type=1:78;
    in=sprintf('%s.%02d.%04d.data',outfpref,type,year);
    HR(:,:)=readbin(in,[360 160 1]);
    if HR<0 HR=0; end
    CR(:,:)=CR99(:,:,type);
    if CR<0 CR=0; end
    
    diff=HR-CR;
    diff(lCR)=NaN;
    infield(:,:,type)=diff;
    
    
    
    %     subplot(13,6,type); pcolor(X,Y,diff(:,:,type)');shading flat;colorbar;
    %     axis equal off
    %     hold on
    %     type
    
    
    %    tmp=squeeze(diff(:,:,type));
    %    numwinx = 8; numwiny = 10;
    %    xwide = 0.125; yhigh = 0.095;
    %    xleft = mod(i-1,numwinx)*xwide;
    %    ybottom  = 1.0 - (((i-mod(i-1,numwinx))/numwinx)+1)*yhigh;
    %    h=axes('position',[(xleft+0.005) (ybottom) (xwide-0.01) (yhigh-0.01)]);
    %    colormap default; cmap=colormap;
    %    colormap(cmap([8 25:2:58],:));
    %    pcolor(X,Y,squeeze(tmp)); caxis([cax1 cax2]); shading flat;
    %    set(gca,'fontweight','light'); set(gca,'fontsize',2);
    %    set(h,'xticklabel',[]); set(h,'yticklabel',[]);
    %    text(50,50,[num2str(i),' ',fstr]);
    %  hold off
    
end
plot_tphyt