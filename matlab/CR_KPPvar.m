clear all

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
HFCR=HFacC(:,:,1);

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

it1=(365*5+366*2)*24;
it2=it1+(365*24);
it =1;

% load in data to be averaged
for i=it1:6:it2;
    
    inKPP=sprintf('/scratch/heimbach/ecco/run_c61/diag_iter73_dir_forw_6hr_all/dir_forw_DKPPdiffs/DKPPdiffs.00000%05d.data',i);
    KPP=readbin(inKPP,[360 160 23]);
    KPP = log10(KPP); 
        
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
                    zKPP(i,j,it)=depthgrid(i,j,r);
            else
                zKPP(i,j,it) = depthgrid(i,j,end);
            end
            
            %             clear k
            %             k=find(sigmat(i,j,:,it)>sigmat(i,j,1,it)+0.125);
            %             if (isempty(k)==0),
            %                 mld(i,j,it)=depth(k(1));
            %             else
            %                 mld(i,j,it)=0;
            %             end
        end, end % for i j
it
    it = it+1;
    
end
 
    KPP_ave=nanmean(zKPP,3);
    KPP_var = zeros(nx,ny);
    
    for day=1:length(i);
    KPP_var=KPP_var + (zKPP(:,:,day)-KPP_ave).^2;
    end
    
    KPP_var=sqrt(KPP_var./length(i));
    KPP_var(HFCR==0)=NaN;
    
out='/scratch/sclayton/coarse_rerun/extract/KPP/KPPvar.1999.data';
fid=fopen(out,'w','ieee-be');
fwrite(fid,KPP_var,'float32');
fclose(fid);

% clear monthly

