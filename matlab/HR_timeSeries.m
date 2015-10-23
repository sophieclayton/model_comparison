% script to calculate monthly averages for all the daily tracers output from the
% darwin model
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all

% set the in/output directories
indir='/scratch/sclayton/high_res/extract/daily/';


% import the HFacC file
HFHR=readbin('/scratch/jahn/run/ecco2/cube84/grid/hFacC.data',[3060 510 50]);
HFHR=squeeze(HFHR(:,:,1));

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
rA=readbin('/scratch/jahn/run/ecco2/cube84/d0006/run.13/RAC.data',[3060 510]);
load /home/jahn/matlab/cube66lonlat long latg
long(511,:,:)=[];
long(:,511,:)=[];
latg(511,:,:)=[];
latg(:,511,:)=[];

x=long;
x=mod(x,360);

% set the grid boxes for each region
atl=find(latg>=Alat1 & latg<=Alat2 & x>=Alon1 & x<=Alon2);
pac=find(latg>=Plat1 & latg<=Plat2 & x>=Plon1 & x<=Plon2);

% pre-assign vectors for the time series 
PA_day=zeros(365,1);
ZA_day=zeros(365,1);
PP_day=zeros(365,1);
ZP_day=zeros(365,1);

% start time stepping
for day=10:307;
    in=sprintf('%sIntTracers.%04d.1999.data',indir,day);
    Pfid=fopen(in,'r','b');
    T=fread(Pfid,3060*510*99,'real*4');
    T=reshape(T,[3060 510 99]);
    P=squeeze(sum(T(:,:,22:99),3));
    fclose(Pfid);

    Z=squeeze(T(:,:,8)+T(:,:,12));
    clear T
    
    PA_day(day)=nanmean(P(atl));%.*rA(atl));
    PP_day(day)=nanmean(P(pac));%.*rA(pac));
    ZA_day(day)=nanmean(Z(atl));%.*rA(atl));
    ZP_day(day)=nanmean(Z(pac));%.*rA(pac));    

day

end
time=1:365;

figure;
subplot(1,2,1);plot(time,PA_day,time,ZA_day);title('Atlantic');
subplot(1,2,2);plot(time,PP_day,time,ZP_day);title('Pacific');
