CR99=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/IntPhyto.1999.data', [360 160 78]);

clear fpat vars
 vars = struct([]);
 vars(1).name = 'X';
 vars(2).name = 'Y';
 vars(3).name = 'Z';
 vars(4).name = 'HFacC';
 vars(5).name = 'rA';
 vars(6).name = 'Depth';
 vars(7).name = 'drF';
 vars(8).name = 'dxC';
 vars(9).name = 'dxG';
 vars(10).name = 'dyC';
 vars(11).name = 'dyG';
 fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
 [nt,nf] = mnc_assembly(fpat,vars);
 ncload(['all.00000.nc']);
 ncclose

rA=permute(rA,[2 1]);
HFCR=permute(squeeze(HFacC(1,:,:)),[2 1]);
CR99(CR99<=1e-12)=0;

load /home/jahn/matlab/cube66lonlat long latg
XC=readbin('/scratch/jahn/run/ecco2/cube84/d0006/run.13/XC.data',[3060 510]);
YC=readbin('/scratch/jahn/run/ecco2/cube84/d0006/run.13/YC.data',[3060 510]);

XX=repmat(X,1,160);
YY=repmat(Y,1,360);
YY=YY';

rAep=readbin('/scratch/jahn/run/ecco2/cube84/d0006/run.13/RAC.data', [3060 510]);

HRbiomass=zeros(3060, 510);

CRsouth=find(Y<0);
CRnorth=find(Y>=0);
CRtropics=find(abs(Y)<40);
CRhighlats=find(abs(Y)>=40);

HRsouth=find(YC<0);
HRnorth=find(YC>=0);
HRtropics=find(abs(YC)<40);
HRhighlats=find(abs(YC)>=40);

for tr=22:99;
    CR99(HFCR==0)=NaN;
    
    CRabGrid(:,:,tr-21)=CR99(:,:,tr-21).*rA;%.*HFCR;
    %CRabsouth(:,:,tr-21)=CR99(:,CRsouth,tr-21).*rA(:,CRsouth).*HFCR(:,CRsouth);
    %CRabGrid(:,:,tr-21)=CR99(:,:,tr-21).*rA.*HFCR;
    %CRabGrid(:,:,tr-21)=CR99(:,:,tr-21).*rA.*HFCR;
    %CRabGrid(:,:,tr-21)=CR99(:,:,tr-21).*rA.*HFCR;
    
        
    in=sprintf('/scratch/sclayton/high_res/global.intr.ann/intrTRAC%02d/TRAC%02d.1999.data', tr, tr);
    phyHR(:,:)=readbin(in,[3060 510]);
    phyHR(phyHR<=1e-12)=0;
    HRbiomass(:,:)=HRbiomass(:,:)+phyHR(:,:);
    HRabGrid(:,:,(tr-21))=phyHR.*rAep;
    
end

convert=106*12.0107/1000/1e12;

CRab=squeeze(sum(sum(CRabGrid,1),2)).*convert;
CRbiomass=sum(CRabGrid,3).*convert;
HRab=squeeze(sum(sum(HRabGrid,1),2)).*convert;
HRbiomass=sum(HRabGrid,3).*convert;
CRab(isnan(CRab))=0;
HRab(isnan(HRab))=0;

delAb=HRab-CRab;

[x,i]=sort(HRab);

type=1:1:78;
%figure;
subplot(1,3,1);barh(HRab(i));
axis([0 120 47 79]);
set(gca,'YTick',type,'YTickLabel',num2str(type(i)'));
xlabel('global abundance (Tg C)'); ylabel('Phytoplankton Type');
title('1/6^o model');

subplot(1,3,2);barh(delAb(i));
axis([-10 40 47 79]);
set(gca,'YTick',type,'YTickLabel',num2str(type(i)'));
xlabel('global abundance (Tg C)');
title('\Delta abundance');

subplot(1,3,3);barh(CRab(i));
axis([0 120 47 79]);
set(gca,'YTick',type,'YTickLabel',num2str(type(i)'));
xlabel('global abundance (Tg C)');
title('1^o model');

