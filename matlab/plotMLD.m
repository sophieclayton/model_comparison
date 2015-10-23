% simple script to plot MLDs for each month on one figure
clf

months=['JAN';'FEB'; 'MAR'; 'APR'; 'MAY'; 'JUN'; 'JUL'; 'AUG'; 'SEP'; 'OCT'; 'NOV'; 'DEC'];

for m=1:12;
    figure(1)
    
    subplot(4,3,m);
    mld=CRmld(:,:,m);
    mld(HFCR==0)=NaN;
    pcolor(X,Y,mld);shading flat;
    axis([0 360 -80 80]);
    title(months(m,:));
    caxis([0 300]); colorbar
    clear mld
%     colormap(special)
%     hold on
%     contour(X,Y,HFCR',[0.5],'k')
%     hold off
end

for m=1:12;
    figure(2)
    mld=HR2CRmld(:,:,m);
    mld(HFCR==0)=NaN;
    subplot(4,3,m);
    pcolor(X,Y,mld);shading flat;
    axis([0 360 -80 80]);
    title(months(m,:));
    caxis([0 300]); colorbar
    clear mld
%     colormap(special)
%     hold on
%     contour(X,Y,HFCR',[0.5],'k')
%     hold off
end
   
for m=1:12;
    figure(3)
    mld=HR2CRmld(:,:,m)-CRmld(:,:,m);
    mld(HFCR==0)=NaN;
    subplot(4,3,m);
    pcolor(X,Y,mld);shading flat;
    axis([0 360 -80 80]);
    title(months(m,:));
    caxis([-100 100]); colorbar
    clear mld
     colormap(special)
     hold on
     contour(X,Y,HFCR,'k')
     hold off
end


 
