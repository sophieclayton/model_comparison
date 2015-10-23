clear all

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

for k=1:nz
    depthgrid(:,:,k)=depth(k);
end % for k

for m=1:12;
    in = sprintf('/scratch/sclayton/high_res/KPP/KPP.monthly.1999%02d.data',m);
    KPP=readbin(in,[3060 510 50]);
    
    
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
                zKPP(i,j,m) = depthgrid(i,j,end);
            end
            
            %             clear k
            %             k=find(sigmat(i,j,:,it)>sigmat(i,j,1,it)+0.125);
            %             if (isempty(k)==0),
            %                 mld(i,j,it)=depth(k(1));
            %             else
            %                 mld(i,j,it)=0;
            %             end
        end, end % for i j
  m  
end % for it
ave_zKPP = nanmean(zKPP,3);

[HR2CRzKPP]=e2_to_eg_func(zKPP,12);

month=['JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC'];
figure;

for m=1:12;
    kpp=squeeze(zKPP(:,:,m));
    kpp(HFHR==0)=NaN;
        
    subplot(4,3,m);
    plotcube(long,latg,kpp,360);grid off;box on;
    shading flat
    axis([0 360 -80 80]);
    title(month(m,:));
    colorbar;
    caxis([0 300])
        
end





