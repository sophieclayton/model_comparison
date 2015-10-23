% plot monthly fields from daily output from the darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
vars(3).name = 'drF';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

XX=repmat(X,1,160);
YY=(repmat(Y,1,360))';

HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);

% define input fields

month=['JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC'];
figure;

for m=1:12;
    monthly=squeeze(diffKPP(:,:,m));
    monthly(HFCR==0)=NaN;
    subplot(4,3,m);
    pcolor(XX,YY,monthly);
    shading flat;
    title(month(m,:));
    colorbar;colormap(special)
    caxis([-25 25]);
    axis([0 360 -80 80])
    box on
    hold on
    contour(XX,YY,HFCR,'k')
    
end
