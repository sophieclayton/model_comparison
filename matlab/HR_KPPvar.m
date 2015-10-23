clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/KPP/';
outdir='/scratch/sclayton/high_res/KPP/';

load /home/jahn/matlab/cube66lonlat long latg

% set up grid
depth=readbin('/scratch/jahn/run/ecco2/cube84/d0006/grid/RF.data',[51]);
depth=depth(2:end);
depth = depth.*-1;

nz=50;
nx=3060;
ny=510;

depthgrid=zeros(nx,ny,nz);
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);

% load in data to be averaged
for day=1:365;
       
        in=sprintf('%sKPPdiffs.%04d.1999.data',indir,day);
        KPP=readbin(in,[3060 510 50]);
        KPP=log10(KPP);
        
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
                    zKPP(i,j,day)=depthgrid(i,j,r);
            else
                zKPP(i,j,day) = depthgrid(i,j,end);
            end
            
            %             clear k
            %             k=find(sigmat(i,j,:,it)>sigmat(i,j,1,it)+0.125);
            %             if (isempty(k)==0),
            %                 mld(i,j,it)=depth(k(1));
            %             else
            %                 mld(i,j,it)=0;
            %             end
        end, end % for i j
day
end
 
    KPP_ave=nanmean(zKPP,3);
    KPP_var = zeros(3060,510);
    
    for day=1:365;
    KPP_var=KPP_var + (zKPP(:,:,day)-KPP_ave).^2;
    end
    
    KPP_var=sqrt(KPP_var./365);
    KPP_var(HFHR==0)=NaN;
    
out=sprintf('%sKPPvar.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,KPP_var,'float32');
fclose(fid);
m
% clear monthly

