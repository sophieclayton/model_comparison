% Script for pulling out the different functional groups from the darwin model output data.
% Sophie Clayton (2009) sclayton@mit.edu

% clear all
% indir=['global.intr.phy'];
% infile=['intr.phy'];
% run extract_field for phytoplankton
trait=load('/scratch/sclayton/coarse_res/run89k_iav/plankton_ini_char_nohead.dat');

% for year=1999:1999;
% fn=sprintf('CR.tracers.1999.data');
% tmp=readbin(fn,[99 160 360]);
% phy = tmp(22:99,:,:);
% phy = permute(phy,[3 2 1]);
phy = readbin('/scratch/sclayton/coarse_rerun/extract/Phyto/IntPhyto.1999.data',[360 160 78]);
clear tmp
z=find(phy<=0);
phy(z)=0;

% set the conditions for each of the groups from the traits outlined in the plankton file

s=find(trait(:,3)==0);
small=phy(:,:,s);
% [3] large stuff - r adapted species
l=find(trait(:,3)==1);
large=phy(:,:,l);

tbiomass=sum(phy,3);

per_small(:,:)=((sum(small,3))./tbiomass(:,:));
per_large(:,:)=((sum(large,3))./tbiomass(:,:));

int_grp(:,:,1)=permute(per_small(:,:),[2 1]);
int_grp(:,:,2)=permute(per_large(:,:),[2 1]);


% %Write out the data as a binary file for reading in later if necessary
% %files are output as [160 360]
% outfile=['intr.grp'];
% outdir=['global.intr.grp'];
% fp=sprintf('%s/%s.%04d.bin',outdir,outfile,year);
% fid=fopen(fp,'w','b');
% fwrite(fid,int_grp,'float32');
% fclose(fid);
% 
% outfile2=['intr.kr'];
% outdir2=['kr.cr'];
% fp2=sprintf('%s/%s.%04d.bin',outdir2,outfile2,year);
% fid=fopen(fp2,'w','b');
% fwrite(fid,int_kr,'float32');
% fclose(fid);

% end

%figure
%subplot(2,2,1),imagesc(int_grp(:,:,1))
%subplot(2,2,2),imagesc(int_grp(:,:,2))
%subplot(2,2,3),imagesc(int_grp(:,:,3))
%subplot(2,2,4),imagesc(int_grp(:,:,4))

