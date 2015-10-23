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

HFCR=squeeze(HFacC(1,:,:))';
euph=zeros(360,160);

nz=23;

% set up grid
delz=[10.,10.,15.,20.,20.,25.,35.,50.,75., ...
    100.,150.,200.,275.,350.,415.,450.,500., ...
    500.,500.,500.,500.,500.,500.];
depth=cumsum(delz);
long=[.5:1:359.5];
lat=[-79.5:1:79.5];
nx=length(long); ny=length(lat); nz=length(depth);

nt=365;
% nt=1 % to test 
nx=360;
ny=160;

% light attenuation coefficients
ko=4e-2;
kp=4e-2*16;

depthm(1)=depth(1)/2;
for k=2:nz
    depthm(k)=depthm(k-1)+0.5*delz(k);
end % for k

% load in the surface PAR values and make daily averages
surfpar6=readbin('/scratch/sclayton/rerun_forcing/PAR99.data',[360 160 365*4]);

for it=1:nt;
    nt6a=(nt-1)*4+1;
    nt6b=nt*4;

    fn=sprintf('/scratch/sclayton/coarse_rerun/extract/PAR/PAR.1999.%04d.data',it);
    par=readbin(fn,[360 160 23]);
    fnp=sprintf('/scratch/sclayton/coarse_rerun/extract/Phyto/Phyto.1999.%04d.data',it);
    
    phy=readbin(fnp,[360 160 23 78]);
    phy=nansum(phy,4);

    surfpar=zeros(360,160);
    surfpar=nanmean(surfpar6(:,:,nt6a:nt6b),3);
    surfpar=surfpar.*(1000000/60/60/24);
    surfpar(HFCR==0)=NaN;

    for i=1:nx, for j=1:ny,
            
            critI = 0.01*surfpar(i,j);
           
            if isfinite(critI),
               r = find(par(i,j,:) < critI);
            
               if isfinite(r) & r>1,
                r=r(1);
                phyz=nanmean(phy(i,j,r-1:r));
                I1 = par(i,j,(r-1));
                z1 = depthm(r-1);
                atten=-(ko+kp.*phyz);
                dz=(1./atten).*log(critI./I1);
                
                euph(i,j,it) = z1 + dz;
               else
                euph(i,j,it) = 0;
               end
               
            else
            euph(i,j,it)=NaN;
            end
            %             
        end, end % for i j
   tmp=euph(:,:,it);
   tmp(HFCR==0)=NaN;
   euph(:,:,it)=tmp;
   clear tmp

   out=sprintf('/scratch/sclayton/coarse_rerun/extract/PAR/Zeuph.1999.%04d.data',it);
   fid=fopen(out,'w','ieee-be');
   fwrite(fid,euph(:,:,it),'float32');
   fclose(fid);
   it
end % for it
aveeuph = nanmean(euph,3);
out2='/scratch/sclayton/coarse_rerun/extract/PAR/Zeuph.1999.data';
fid=fopen(out2,'w','ieee-be');
fwrite(fid,aveeuph,'float32');
fclose(fid);
   
% calculate monthly averages
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));


% load in data to be averaged
for m=1:12;
    monthly=zeros(360,160);

    for day=startday(m):1:endday(m);
        tmp=euph(:,:,day);
        monthly=monthly+tmp;

    end
    clear tmp
    monthly(:,:,:)=monthly(:,:,:)./days(m+1);


out3=sprintf('/scratch/sclayton/coarse_rerun/extract/PAR/Zeuph.monthly.1999%02d.data',m);
fid=fopen(out3,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);
m
clear monthly

end


 


