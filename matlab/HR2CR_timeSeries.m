% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all

% set the in/output directories
indir='/scratch/sclayton/HR2CRdata/daily/HR2CR_daily_Int270m.';


% import the HFacC file
HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160 23]);
HFCR=squeeze(HFCR(:,:,1));

% define the area of interest
% North Atlantic
Alat1=45;
Alat2=60;
Alon1=300;
Alon2=350;
% North Pacific
Plat1=40;
Plat2=55;
Plon1=145;
Plon2=200;

% load in the lat/lon fields
vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
vars(3).name = 'rA';
fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose

rA=rA';
XX=repmat(X,1,160);
YY=(repmat(Y,1,360))';

% set the grid boxes for each region
atl=find(YY>=Alat1 & YY<=Alat2 & XX>=Alon1 & XX<=Alon2);
pac=find(YY>=Plat1 & YY<=Plat2 & XX>=Plon1 & XX<=Plon2);

% pre-assign vectors for the time series 
PA_day=zeros(365,1);
ZA_day=zeros(365,1);
PP_day=zeros(365,1);
ZP_day=zeros(365,1);

% load in data to be averaged
for day=1:307;
    in=sprintf('%s%04d.1999.data',indir,day);
    Pfid=fopen(in,'r','b');
    TR=fread(Pfid,360*160*99,'real*4');
    TR=reshape(TR,[360 160 99]);
    P=squeeze(nansum(TR(:,:,22:99),3));
    P(HFCR==0)=NaN;
    fclose(Pfid);

    Z=squeeze(TR(:,:,8)+TR(:,:,12));
    Z(HFCR==0)=NaN;

    PA_day(day)=nansum(P(atl).*rA(atl));
    PP_day(day)=nansum(P(pac).*rA(pac));
    ZA_day(day)=nansum(Z(atl).*rA(atl));
    ZP_day(day)=nansum(Z(pac).*rA(pac));    

day

end
time=1:365;

figure;
subplot(1,2,1);plot(time,PA_day,time,ZA_day);title('Atlantic');
subplot(1,2,2);plot(time,PP_day,time,ZP_day);title('Pacific');

