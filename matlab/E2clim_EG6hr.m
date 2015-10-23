% Script to interpolate a monthly climatology on the ECCO2 grid to a 6
% hourly climatology on the ECCO-Godae grid. Sophie Clayton
% (sclayton@mit.edu) 22nd September 2010
%


clear all

% read in the original data
data=readbin('/scratch/sclayton/high_res/E2dust_clim.bin',[3060 510 12]);

% interpolate the data onto the ECCO-Godae grid
e2_to_eg_sophie

zero=find(dataout==0);


clear data
dataint(:,:,2:13)=dataout;
dataint(:,:,1)=dataint(:,:,13);
clear dataout

% interpolate the monthly data to 6 hourly data
newtime=0.25:0.25:365';
oldtime=[-31/2;31/2 ;(31)+28/2; (31+28)+31/2; (31+28+31)+30/2; (31+28+31+30)+31/2; (31+28+31+30+31)+30/2; (31+28+31+30+31+30)+31/2; (31+28+31+30+31+30+31)+31/2; (31+28+31+30+31+30+31+31)+30/2; (31+28+31+30+31+30+31+31+30)+31/2; (31+28+31+30+31+30+31+31+30+31)+30/2; (31+28+31+30+31+30+31+31+30+31+30)+31/2];
for x=1:360;
    for y=1:160;
        data6(x,y,:)=interp1(oldtime, squeeze(dataint(x,y,:)),newtime);
    end
end

