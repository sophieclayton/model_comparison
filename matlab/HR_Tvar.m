clear all

% set the in/output directories

outdir='/scratch/sclayton/high_res/SST/';

load /home/jahn/matlab/cube66lonlat long latg

nx=3060;
ny=510;

HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510]);

% load in data to be averaged
for day=1:365;
       
        in=sprintf('%sTdiffs.%04d.1999.data',indir,day);
        T=readbin(in,[3060 510 50]);
        T=log10(T);
        
        for i=1:nx, for j=1:ny,
            
            critT = -3;
            r = find(T(i,j,2:end) <= critT);
                        
            if isfinite(r),
                r=r(1);
%                 rho1 = T(i,j,(r-1));
%                 rho2 = T(i,j,(r));
%                 z1 = depthm(r-1);
%                 z2 = depthm(r);
%                 zT(i,j,m) = z1 + ((critT - rho1)*(z2 - z1))/(rho2 - rho1);
                    zT(i,j,day)=depthgrid(i,j,r);
            else
                zT(i,j,day) = depthgrid(i,j,end);
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
 
    T_ave=nanmean(zT,3);
    T_var = zeros(3060,510);
    
    for day=1:365;
    T_var=T_var + (zT(:,:,day)-T_ave).^2;
    end
    
    T_var=(T_var./365);
    T_var(HFHR==0)=NaN;
    
out=sprintf('%sTvar.1999.data',outdir);
fid=fopen(out,'w','ieee-be');
fwrite(fid,T_var,'float32');
fclose(fid);
m
% clear monthly

