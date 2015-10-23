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

% work out the indexing for beg/end 1999
% indices start in 1992 to end of 1999

it1=(365*5+366*2)*24;
it2=it1+(365*24);

year=1999;
outpref='CRmld';
%it1=69840;
step=6;
%it2=it1+(11*step);
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
nx=length(long); ny=length(lat); nz=length(depth);
it=1;
nt=365;
nx=360;
ny=160;

depthm(1)=depth(1)/2;
for k=2:nz
    depthm(k)=depthm(k-1)+0.5*delz(k);
end % for k

% calculate density
depthgrid=zeros(360,160,23);
depthgrid(:,:,1)=5;

for k=1:nz
    depthgrid(:,:,k)=depthm(k);
end % for k
latgrid=zeros(360,160,23);
for j=1:ny,
    latgrid(:,j,:)=lat(:,j,:);
end % for j

for i=it1:6:it2;
    it
    insalt=sprintf('/scratch/heimbach/ecco/run_c61/diag_iter73_dir_forw_6hr_all/dir_forw_DDsalt/DDsalt.00000%05d.data',i);
    salt=readbin(insalt,[360 160 23]);
    
    intheta=sprintf('/scratch/heimbach/ecco/run_c61/diag_iter73_dir_forw_6hr_all/dir_forw_DDtheta/DDtheta.00000%05d.data',i);
    theta=readbin(intheta,[360 160 23]);
    
    %    it=it+1;
    %end
    %it=1;
    
    % make land mask
    clear tmp
    tmp=squeeze(salt(:,:,:));
    pmask=zeros(size(tmp));
    clear fi, fi=find(tmp>0); pmask(fi)=1;
    clear filand1; filand1=find(pmask(:,:,1)==0);
    
    % calculate density
    press=sw_pres(depthgrid,latgrid);
    pressref=zeros(360,160,23);
    press0=zeros(360,160,23);
    insitut=sw_temp(salt,theta,press,pressref);
    dens=(sw_dens(salt,insitut,press)).*pmask;
    sigma=(dens-1000).*pmask;
    sigmat=(sw_dens(salt,insitut,press0)-1000).*pmask;
    sigmatheta=(sw_dens(salt,theta,press0)-1000).*pmask;
%     %for it=1:nt,
%     dens(:,:,:,it)=squeeze(dens(:,:,:,it)).*pmask;
%     sigma(:,:,:,it)=squeeze(sigma(:,:,:,it)).*pmask;
%     sigmat(:,:,:,it)=squeeze(sigmat(:,:,:,it)).*pmask;
%     sigmatheta(:,:,:,it)=squeeze(sigmatheta(:,:,:,it)).*pmask;
%     %end
    %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate mld
    %for it=1:12,
    for i=1:nx, for j=1:ny,
            
            critdens = sigmatheta(i,j,1)+0.125;
            r = find(sigmatheta(i,j,:) > critdens);
            
            if isfinite(r),
                r=r(1);
                rho1 = sigmatheta(i,j,(r-1));
                rho2 = sigmatheta(i,j,(r));
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
    it = it+1;
end % for it
avemld = nanmean(mld,3);







