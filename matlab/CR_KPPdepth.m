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

nz=23;

HFacC=permute(HFacC,[3 2 1]);

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

depthgrid=zeros(360,160,23);

for k=1:nz
    depthgrid(:,:,k)=depth(k);
end % for k
latgrid=zeros(360,160,23);
for j=1:ny,
    latgrid(:,j,:)=lat(:,j,:);
end % for j

for m=1:12;
    in = sprintf('/scratch/sclayton/coarse_rerun/extract/KPP/log10KPPdiffs_monthly.1999%02d.data',m);
    KPP=readbin(in,[360 160 23]);
    
         for i=1:nx, for j=1:ny,
            
            critKPP = -3;
            r = find(KPP(i,j,2:end) <= critKPP);
                        
            if isfinite(r),
                r=r(1);
%                 rho1 = KPP(i,j,(r-1));
%                 rho2 = KPP(i,j,(r));
%                 z1 = depthm(r-1);
%                 z2 = depthm(r);
%                 zKPP(i,j,m) = z1 + ((critKPP - rho1)*(z2 - z1))/(rho2 - rho1);
                    zKPP(i,j,m)=depthgrid(i,j,r);
            else
                zKPP(i,j,m) = Depth(j,i);
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
ave_zKPP = nanmean(zKPP,3);







