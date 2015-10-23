CR99=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/IntPhyto.1999.data', [360 160 78]);
% rA=permute(rA,[2 1]);

 rAep=readbin('/scratch/jahn/run/ecco2/cube84/d0006/run.13/RAC.data', [3060 510]);
 %rAep=permute(rAep,[2 1]);

clear fpat vars
vars = struct([]);
vars(1).name = 'HFacC';
vars(2).name ='X';
vars(3).name = 'Y';
vars(4).name = 'rA';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

rA=permute(rA,[2 1]);
HFacC=squeeze(HFacC(1,:,:));
HFacC=permute(HFacC,[2 1]);
HFCR=permute(HFacC, [3 2 1]);
HFCR=squeeze(HFCR(:,:,1));
 HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data', [3060 510]);
 load /home/jahn/matlab/cube66lonlat long latg

for tr=22:99;
    tmpCR=CR99(:,:,tr-21);
    tmpCR(squeeze(HFCR(1,:,:))==0)=NaN;
    CRabGrid(:,:,tr-21)=tmpCR;
    clear tmpCR
    
    in=sprintf('/scratch/sclayton/high_res/global.intr.ann/intrTRAC%02d/TRAC%02d.1999.data', tr, tr);
%    in=sprintf('/scratch/sclayton/HR2CRdata/HR2CRptracers/HR2CRptracer%02d.1999.data',tr);
    tmpHR(:,:)=readbin(in,[3060 510]);
    tmpHR(HFCR==0)=NaN;
    HRabGrid(:,:,tr-21)=tmpHR.*rAep;
    clear tmpHR
    tr
end

CRab=sum(sum(CRabGrid,1),2);
 HRab=sum(sum(HRabGrid,1),2);
type=1:1:78;

for i=1:360;
   for j=1:160;
       CRR=squeeze(CRabGrid(i,j,:));
       CRmax=max(max(CRR));
       a=find(CRR==CRmax);
       if isscalar(a), CRdom(i,j)=type(a);
       else CRdom(i,j)=NaN;
       end
   end
    
end
clear i j a

 for i=1:3060;
     for j=1:510;
     HRR=squeeze(HRabGrid(i,j,:));
         HRmax=max(max(HRR));
         a=find(HRR==HRmax);
         if isscalar(a), HRdom(i,j)=type(a);
         else HRdom(i,j)=NaN;
         end
     end
 end
% figure(1);;pcolor(X,Y,CRdom');shading flat;colorbar;title(['CR dominant type']);axis([0 360 -80 80]);
% figure(2);plotcube(long,latg,HRdom,360);shading flat; colorbar;title(['HR dominant type']);grid off;axis([0 360 -80 80]);box on
