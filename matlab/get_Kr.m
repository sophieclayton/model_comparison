%clear all

eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']); 
plankton=plankton_ini_char_nohead;

% load in plankton fields
CRphy=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/IntPhyto.1999.data',[360 160 78]);

small=find(plankton(:,3)==0);
big=find(plankton(:,3)==1);

CRsmall=squeeze(nansum(CRphy(:,:,small),3));
CRbig=squeeze(nansum(CRphy(:,:,big),3));

% E2 data
indir='/scratch/sclayton/high_res/global.intr.ann/';

HRphy=zeros(3060,510,78);
for p=1:78;
	in=sprintf('%sintrTRAC%02d/TRAC%02d.1999.data',indir,p+21,p+21);
        tmp=readbin(in,[3060 510]);
        HRphy(:,:,p)=tmp;
        clear tmp
end

HRsmall=squeeze(nansum(HRphy(:,:,small),3));
HRbig=squeeze(nansum(HRphy(:,:,big),3));


% figure;
% subplot(2,1,1);pcolor(X,Y,CRgroup');shading flat;colorbar;title(['CR dominant group']);axis([0 360 -90 90]);
% subplot(2,1,2); plotcube(long,latg,HRgroup,360);shading flat; colorbar;title(['HR dominant group']);grid off;axis([0 360 -90 90]);
