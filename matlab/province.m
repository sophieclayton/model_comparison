% find physical "provinces"
%
start=1; %1=read data, 0=don't

if (start==1), clear all, start=1; end

addpath /home/stephd/Diags_darwin_igsm/seawater_ver3_0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DECISIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dodiags=[4];
iplot=[3]; %1=temp, 2=wvel, 3=horz velocity
iwrite=0;
kn=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (start==1),
 direct='/home/stephd/ECCO/iter177/';

%
% set up grid
 delz=[10.,10.,15.,20.,20.,25.,35.,50.,75., ...
       100.,150.,200.,275.,350.,415.,450.,500., ...
       500.,500.,500.,500.,500.,500.];
 depth=cumsum(delz);
 long=[.5:1:359.5];
 lat=[-79.5:1:79.5];
 nx=length(long); ny=length(lat); nz=length(depth); nt=12;

 depthm(1)=depth(1)/2;
 for k=2:nz
  depthm(k)=depthm(k-1)+0.5*delz(k);
 end % for k
%
 for itype=1:6
  if (itype==1), subdirect='Dynvars2/'; filename='DDtheta.'; iz=nz; end
  if (itype==2), subdirect='Dynvars2/'; filename='DDsalt.'; iz=nz; end
  if (itype==3), subdirect='Dynvars2/'; filename='DDwvel.'; iz=nz; end
  if (itype==4), subdirect='Dynvars2/'; filename='DDuvel.'; iz=nz; end
  if (itype==5), subdirect='Dynvars2/'; filename='DDvvel.'; iz=nz; end
  if (itype==6), subdirect='Forcing2/'; filename='DFOsflux.'; iz=1; end
%
  for it=1:12
    time=69840+(it-1)*720;
    if (time<1000); timestr=['000000',num2str(time)]; end
    if (time>1000); timestr=['00000',num2str(time)]; end
    fid=fopen([direct,subdirect,filename,timestr,'.data'],'r','b');
    clear tmp, tmp=fread(fid,'float32'); fclose(fid);
    if (iz==nz),
          tmp=reshape(tmp,360,160,23); 
    end
    if (iz==1),
          tmp=reshape(tmp,360,160);
    end % if
    if (itype==1), theta(:,:,:,it)=tmp; end
    if (itype==2), salt(:,:,:,it)=tmp; end
    if (itype==3), wvel(:,:,:,it)=tmp; end
    if (itype==4), uvel(:,:,:,it)=tmp; end
    if (itype==5), vvel(:,:,:,it)=tmp; end
    if (itype==6), sflux(:,:,it)=tmp; end
  end % for it
%
 end % for itype
end % if start 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (dodiags~=0),
%
% make land mask
  clear tmp, tmp=squeeze(salt(:,:,:,1));
  pmask=zeros(size(tmp)); 
  clear fi, fi=find(tmp>0); pmask(fi)=1;
  clear filand1; filand1=find(pmask(:,:,1)==0);
  for idiag=dodiags
%%%%
% find temperature range
   if (idiag==1),
    for k=1:nz,
     clear tmp, tmp=squeeze(theta(:,:,k,:));
     maxtemp(:,:,k)=squeeze(max(tmp,[],3));
     mintemp(:,:,k)=squeeze(min(tmp,[],3));
     temprange(:,:,k)=maxtemp(:,:,k)-mintemp(:,:,k); 
    end % for k
   end % if idiag 1
%%%%%
% horizontal transport
   if (idiag==2),
    for it=1:nt
     for k=1:nz,
      clear tmp,
      for i=1:nx-1, for j=1:ny-1,
         uu(i,j)=.5*(uvel(i,j,k,it)+uvel(i+1,j,k,it));
         vv(i,j)=.5*(vvel(i,j,k,it)+vvel(i,j+1,k,it));
      end, end % for i j
      uu(nx,1:ny)=.5*(uvel(nx,:,k,it)+uvel(1,:,k,it));
      vv(1:nx,ny)=0;
      tmp=squeeze(uu.^2+vv.^2); tmp=sqrt(tmp);
%     clear fi, fi=find(squeeze(pmask(:,:,k))==0); tmp(fi)=NaN;
      trans(:,:,k,it)=tmp;
     end % for k
    end % for it
   end % if idiag 2
%%%%%
% calculate density
   if (idiag==4),  
    depthgrid=zeros(size(theta));
    depthgrid(:,:,1,:)=5;
    for k=1:nz
      depthgrid(:,:,k,:)=depthm(k);
    end % for k
    latgrid=zeros(size(theta));
    for j=1:ny,
      latgrid(:,j,:,:)=lat(:,j,:,:);
    end % for j
    press=sw_pres(depthgrid,latgrid);
    pressref=zeros(size(theta));
    press0=zeros(size(theta));
    insitut=sw_temp(salt,theta,press,pressref);
    dens=sw_dens(salt,insitut,press);
    sigma=dens-1000;
    sigmat=sw_dens(salt,insitut,press0)-1000;
    sigmatheta=sw_dens(salt,theta,press0)-1000;
    for it=1:nt,
      dens(:,:,:,it)=squeeze(dens(:,:,:,it)).*pmask;
      sigma(:,:,:,it)=squeeze(sigma(:,:,:,it)).*pmask;
      sigmat(:,:,:,it)=squeeze(sigmat(:,:,:,it)).*pmask;
      sigmatheta(:,:,:,it)=squeeze(sigmatheta(:,:,:,it)).*pmask;
    end
   end % of idiag 3
%%%%
% calcualte mld
   if (idiag==4),
     for it=1:12,
      for i=1:nx, for j=1:ny,
       clear k
       k=find(sigmatheta(i,j,:,it)>sigmatheta(i,j,1,it)+0.125);
       if (isempty(k)==0),
          mld(i,j,it)=depth(k(1));
       else
          mld(i,j,it)=0;
       end
      end, end % for i j
     end % for it
     maxmld=max((mld),[],3);
     minmld=min((mld),[],3);
     mldrange=maxmld-minmld;
   end % of idiag 4
  end % for dodiag
end % if dodiags


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (iplot==1),
 figure(5), 
 cmap1=[10:8:60];
 colormap default; cmap=colormap; colormap(cmap(cmap1,:));
 clear tmp, tmp=squeeze(temprange(:,:,kn));
 clear fi, fi=find(tmp==0); tmp(fi)=NaN;
 pcolor(long,lat,tmp'); caxis([0 15]); shading flat, colorbar
 title(['ECCO177 temperature (level ',num2str(kn),') annual range']);
 figure(1),
 for it=1:12,
   subplot(4,3,it),
   cmap1=[10:8:60];
   colormap default; cmap=colormap; colormap(cmap(cmap1,:));
   clear tmp, tmp=squeeze(theta(:,:,kn,it))';
   clear fi, fi=find(tmp==0); tmp(fi)=NaN;
   pcolor(long,lat,tmp); caxis([-2 30]); shading flat, colorbar
   hold on, contour(long,lat,squeeze(temprange(:,:,kn))',[0:5:20],'k-');
 end % for it
end % for iplot
%%%%%%%%%%%%%
if (iplot==2),
 figure(2),
 load colorgam.mat
 for it=1:12,
   subplot(4,3,it),
   cmap1=[8:2:42 55 58:2:92];
   cmap=colorgam; colormap(cmap(cmap1,:));
   clear tmp, tmp=squeeze(wvel(:,:,kn,it))';
   clear fi, fi=find(tmp==0); tmp(fi)=NaN;
   pcolor(long,lat,tmp); caxis([-1e-5 1e-5]); shading flat, colorbar
   hold on, contour(long,lat,tmp,[-1e10 0 1e10],'k-');
   title(['wvel, month ',num2str(it)])
 end % for it
 figure(8)
 cmap=colorgam; colormap(cmap(cmap1,:));
 clear tmp, tmp=squeeze(mean(wvel(:,:,kn,:),4))';
 clear fi, fi=find(tmp==0); tmp(fi)=NaN;
 pcolor(long,lat,tmp); caxis([-1e-5 1e-5]); shading flat, colorbar
 hold on, contour(long,lat,tmp,[-1e10 0 1e10],'k-');
 title(['ECCO177: annual mean wvel at ',num2str(depth(kn-1)),'m']);
end % for iplot
%%%%%%%%%%%%%
if (iplot==3),
 figure(3),
 for it=1:12,
   subplot(4,3,it),
   cmap1=[10:2:60];
   colormap default; cmap=colormap; colormap(cmap(cmap1,:));
   clear tmp, tmp=squeeze(trans(:,:,kn,it))';
   clear fi, fi=find(tmp==0); tmp(fi)=NaN;
   pcolor(long,lat,tmp); caxis([0 .5]); shading flat, colorbar
   hold on, contour(long,lat,tmp,[0 .05 .1 .2],'k-');
 end % for it
 figure(13)
 clear tmp, tmp=squeeze(mean(trans(:,:,kn,:),4))';
 clear fi, fi=find(tmp==0); tmp(fi)=NaN;
 pcolor(long,lat,tmp); caxis([0 .5]); shading flat, colorbar
 hold on, contour(long,lat,tmp,[0 .05 .1 .2],'k-');
 title(['ECCO177: annual mean horz speed at ',num2str(depth(kn)),'m']);
end % for iplot
%%%%%%%%%%%%%
if (iplot==4),
 figure(4),
 load colorgam.mat
 for it=1:12,
   subplot(4,3,it),
   cmap1=[8:2:42 55 58:2:92];
   cmap=colorgam; colormap(cmap(cmap1,:));
   clear tmp, tmp=squeeze(wvel(:,:,kn,it))';
   clear fi, fi=find(tmp==0); tmp(fi)=NaN;
   pcolor(tmp); caxis([-1e-5 1e-5]); shading flat, colorbar
   clear tmp, tmp=squeeze(trans(:,:,kn,it))';
   clear fi, fi=find(tmp==0); tmp(fi)=NaN;
   hold on, contour(tmp,[0 .05],'k-');
 end % for it
end % for iplot
%%%%%%%%%%%%%%%%%%%%
if (iplot==6),
  figure(9)
  for it=1:12,
   subplot(4,3,it),
   cmap1=[10:2:60];
   colormap default; cmap=colormap; colormap(cmap(cmap1,:));
   clear tmp, tmp=squeeze(mld(:,:,it));
   clear fi, fi=find(squeeze(theta(:,:,1,it)==0));
   tmp(fi)=NaN;
   pcolor(tmp'); caxis([0 200]); shading flat, colorbar
  end % for it
  figure(10),
  clear fi, fi=find(squeeze(theta(:,:,1,it)==0));
  subplot(2,2,1), clear tmp, tmp=maxmld; tmp(fi)=NaN;
          pcolor(long,lat,tmp'), caxis([0 300]); shading flat, colorbar
  title('ECCO177: Max MLD')
  subplot(2,2,2), clear tmp, tmp=minmld; tmp(fi)=NaN;
           pcolor(long,lat,tmp'), caxis([0 100]); shading flat, colorbar
  title('ECCO177: Min MLD')
  subplot(2,2,3), clear tmp, tmp=mldrange; tmp(fi)=NaN;
           pcolor(long,lat,tmp'), caxis([0 200]); shading flat, colorbar
  title('ECCO177: MLD annual range')
end % if
%
if (iplot==7)
  figure(15)
  clear fi, fi=find(squeeze(theta(:,:,1,it)==0));
  clear tmp, tmp=maxmld; tmp(fi)=NaN;
          pcolor(long,lat,tmp'), caxis([0 300]); shading flat, colorbar
  hold on
  clear tmp, tmp=squeeze(mean(wvel(:,:,5,:),4)); tmp(fi)=NaN;
  contour(long,lat,tmp',[-1e10 0 1e10],'k-');
end % if

%
if (iplot==8)
  figure(16)
  clear fi, fi=find(squeeze(theta(:,:,1,it)==0));
  clear tmp, tmp=minmld; tmp(fi)=NaN;
          pcolor(long,lat,tmp'), caxis([0 200]); shading flat, colorbar
  hold on
  clear tmp, tmp=squeeze((temprange(:,:,1))); tmp(fi)=NaN;
  contour(long,lat,tmp',[0:2:16],'k-');
end % if

%%%%%%%%%%%%%%
%% save
if (iwrite==1),
 fid=fopen('ecco177_mld.data','w','b');
 for it=1:12,
   clear tmp, tmp=squeeze(mld(:,:,it));
   fwrite(fid,tmp,'float32');
 end % for it
 fclose(fid);
 
 fid=fopen('ecco177_trans.data','w','b');
 for it=1:12,
   clear tmp, tmp=squeeze(trans(:,:,:,it));
   fwrite(fid,tmp,'float32');
 end % for it
 fclose(fid);

 fid=fopen('ecco177_temp.data','w','b');
 for it=1:12,
   clear tmp, tmp=squeeze(theta(:,:,:,it));
   fwrite(fid,tmp,'float32');
 end % for it
 fclose(fid);

 fid=fopen('ecco177_wvel.data','w','b');
 for it=1:12,
   clear tmp, tmp=squeeze(wvel(:,:,:,it));
   fwrite(fid,tmp,'float32');
 end % for it
 fclose(fid);

end % for iwrite

