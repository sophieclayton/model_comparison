clear all

% grid data for the high resolution model
load /home/jahn/matlab/cube66lonlat long latg
landHR=readbin('/scratch/jahn/output/ecco2/cube84/grid/hFacC.data',[3060 510]);

lHR=find(landHR==0);

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
CR99=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/IntPhyto.1999.data', [360 160 78]);

for tr=22:99;
    type=tr-21;
    CR(:,:)=CR99(:,:,type);
    CR(lCR)=NaN;


in=sprintf('/scratch/sclayton/high_res/global.intr.ann/intrTRAC%02d/TRAC%02d.1999.data', tr, tr);
HR(:,:)=readbin(in,[3060 510 1]);
HR(lHR)=NaN;

figure(1)

if max(max(CR))>max(max(HR)),
    maxphy=max(max(CR));
else maxphy=max(max(HR));
end

subplot(2,1,1);pcolor(X,Y,CR');colorbar;shading flat;title(['CR',num2str(type)])
caxis([0 maxphy])
axis([0 360 -90 90])

subplot(2,1,2);plotcube(long,latg,HR,360);colorbar;shading flat;title(['HR',num2str(type)])
caxis([0 maxphy])
grid off
axis([0 360 -90 90])

outim=sprintf('/scratch/sclayton/FiguresRerun/compareByType/comp%02d.1999.png',type);

print('-f1', '-dpng', '-r300', outim)
close
type
end
