addpath /home/stephd/Diags_darwin_igsm/seawater_ver3_0

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

year=1999;
outpref='CRmld';
it1=69840;
step=720;
it2=it1+(11*step);
sst=zeros(360,160);
iit=0;
nz=23;

% set up grid
delz=[10.,10.,15.,20.,20.,25.,35.,50.,75., ...
    100.,150.,200.,275.,350.,415.,450.,500., ...
    500.,500.,500.,500.,500.,500.];
depth=cumsum(delz);
long=[.5:1:359.5];
lat=[-79.5:1:79.5];
nx=length(long); ny=length(lat); nz=length(depth); nt=12;
it=1;
nt=12;
nx=360;
ny=160;

for i=it1:720:it2;
    insalt=sprintf('/home/stephd/ECCO/iter177/Dynvars2/DDsalt.00000%05d.data',i);
    salt(:,:,:,it)=readbin(insalt,[360 160 23]);

    intheta=sprintf('/home/stephd/ECCO/iter177/Dynvars2/DDtheta.00000%05d.data',i);
    theta(:,:,:,it)=readbin(intheta,[360 160 23]);

    it=it+1;
end
it=1;

depthm(1)=depth(1)/2;
for k=2:nz
    depthm(k)=depthm(k-1)+0.5*delz(k);
end % for k
% make land mask
clear tmp, tmp=squeeze(salt(:,:,:,1));
pmask=zeros(size(tmp));
clear fi, fi=find(tmp>0); pmask(fi)=1;
clear filand1; filand1=find(pmask(:,:,1)==0);
%%%%%
% calculate density
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
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate mld
for it=1:12,
    for i=1:nx, for j=1:ny,

            critdens = sigmatheta(i,j,1,it)+0.125;
            r = find(sigmatheta(i,j,:,it) > critdens);
           
            if isfinite(r),
                r=r(1);
                rho1 = sigmatheta(i,j,(r-1),it);
                rho2 = sigmatheta(i,j,(r),it);
                z1 = depthm(r-1);
                z2 = depthm(r);
                mld(i,j,it) = z1 + ((critdens - rho1)*(z2 - z1))/(rho2 - rho1);
            else 
                mld(i,j) = Depth(j,i);
            end

                %             clear k
                %             k=find(sigmat(i,j,:,it)>sigmat(i,j,1,it)+0.125);
                %             if (isempty(k)==0),
                %                 mld(i,j,it)=depth(k(1));
                %             else
                %                 mld(i,j,it)=0;
                %             end
            end, end % for i j
    end % for it
    avemld = nanmean(mld,3);
    maxmld=max((mld),[],3);
    minmld=min((mld),[],3);
    mldrange=maxmld-minmld;



