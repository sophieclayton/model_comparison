% script to interpolate between the ecco-godae fields and Bill Dewar's coarsest North Pacific domain
% June 2012
% Sophie Clayton, sclayton@mit.edu

clear all

% load in all the grid data for ecco godae
X=readbin('/scratch/sclayton/coarse_rerun/grid/XC.data',[360 160]);
Y=readbin('/scratch/sclayton/coarse_rerun/grid/YC.data',[360 160]);

xx=zeros(360,160,23);
yy=zeros(360,160,23);

for i=1:23;
    xx(:,:,i)=X;
    yy(:,:,i)=Y;
end
X=xx;
Y=yy;
Z=readbin('/scratch/sclayton/coarse_rerun/grid/RC.data',[23]);
Z=(permute(repmat(Z,[1 360 160]),[2 3 1]));

EGHF=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160 23]);

% load in data to be interpolated
% for nutrients
% V=readbin('/scratch/sclayton/coarse_rerun2/extract/NutsZoo/NutsZoo.1999.data',[360 160 23 21]);
% V=squeeze(V(:,:,:,21));
% V(EGHF==0)=NaN;

% for phytoplankton
V=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
% separate into big and small groups
eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']); 
plankton=plankton_ini_char_nohead;


% small
s=find(plankton(:,3)==0);
Vs=nansum(V(:,:,:,s),4);
% big
b=find(plankton(:,3)==1);
Vb=nansum(V(:,:,:,b),4);
clear V

V=Vb;


%V=sum(V,4);

% fill in land with tracer values
hole=V;
for it=1:3;
for k=1:23;
    
        [fi,fj]=find(isnan(hole(:,:,k))); % points that need to be filled in
        
        a=fi-1;a(a<1)=1;
        b=fi+1;b(b>360)=360;
        c=fj-1;c(c<1)=1;
        d=fj+1;d(d>160)=160;
                     
        for i=1:length(fi);
            tmp=V(a(i):b(i),c(i):d(i),k);
            tmp=tmp(:);
            if isfinite(nanmean(tmp)), hole(fi(i),fj(i),k)=nanmean(tmp);
            end
        end %if
        clear a b c d
    end %k
    V=hole;
end % it

clear hole

% load in all the grid data for North Pac
XI=readbin('/home/sclayton/hires_kuroshio/XC.data',[540 360]);
YI=readbin('/home/sclayton/hires_kuroshio/YC.data',[540 360]);
% reference longitude 
Xref=115;

XI= XI+Xref;

xx=zeros(540,360,32);
yy=zeros(540,360,32);

for i=1:32;
    xx(:,:,i)=XI;
    yy(:,:,i)=YI;
end
XI=xx;
YI=yy;

clear xx yy

ZI=readbin('/home/sclayton/hires_kuroshio/RF.data',[33]);
ZI=(ZI(1:end-1)+ZI(2:end))./2;
ZI=(permute(repmat(ZI,[1 540 360]),[2 3 1]));

NPHF=readbin('/home/sclayton/hires_kuroshio/hFacC.data',[540 360 32]);



% 3-D interpolation
VI = interp3(squeeze(Y(1,:,1)),squeeze(X(:,1,1)),squeeze(Z(1,1,:)),V,squeeze(YI(1,:,1)),squeeze(XI(:,1,1)),squeeze(ZI(1,1,:)),'linear');
VI(NPHF==0)=NaN;
clear X Y Z EGHF V

hole=VI;

% check for empty grid points in interpolated data


aa=0;
dd=5;

while(isfinite(find(NPHF>0 & isnan(hole)))),
for k=1:32;
    
        [fi,fj]=find(NPHF(:,:,k)>0 & isnan(hole(:,:,k))); % points that need to be filled in
        
        a=fi-1;a(a<1)=1;
        b=fi+1;b(b>540)=540;
        c=fj-1;c(c<1)=1;
        d=fj+1;d(d>360)=360;
                     
        for i=1:length(fi);
            tmp=VI(a(i):b(i),c(i):d(i),k);
            tmp=tmp(:);
            if isfinite(nanmean(tmp)), hole(fi(i),fj(i),k)=nanmean(tmp);
            end %if
        end %i
        clear a b c d tmp
        VI=hole;
    end %k
    dd=aa;
    clear aa
    aa=length(find(NPHF>0 & isnan(hole)));  
if aa==dd, break, end
end %while


aa=0;
dd=1;

while(isfinite(find(NPHF>0 & isnan(hole)))),
    for i=1:540;
        for j=1:360;
            ff=find(isnan(hole(i,j,:)) & NPHF(i,j,:)>0);
            if isfinite(VI(i,j,ff-1)),
                hole(i,j,ff)=VI(i,j,ff-1);
            end % if
            VI=hole;
            
        end  % j
    end % i
    dd=aa;
    clear aa
    aa=length(find(NPHF>0 & isnan(VI)));
    if aa==dd, break, end
end

VI=hole;
clear hole
VI(VI<0)=0;

figure;pcolor(XI(:,:,1),YI(:,:,1),VI(:,:,1));shading flat
figure;pcolor(squeeze(XI(:,end,:)),squeeze(ZI(:,end,:)),squeeze(VI(:,end,:)));shading flat

%write out the new field

outa='/home/sclayton/MITgcm/verif_twospecies_NPac/input/input_darwin/Phy01_NPac_IC.data';
fid=fopen(outa,'w','ieee-be');
fwrite(fid,VI,'float32');
fclose(fid);



