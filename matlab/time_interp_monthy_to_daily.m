% Script to interpolate monthly data into 6 hourly data
% Sophie Clayton (sclayton@mit.edu)
% March 2011


clear all

data=readbin('EGdust.data',[360 160 12]);
% add dec to the beginning of the year and jan to the end of the year
data(:,:,2:13)=data;
data(:,:,1)=data(:,:,13);
data(:,:,14)=data(:,:,2);

% set the time vectors
time_6=31:0.25:31+31+28+31+30+31+30+31+31+30+31+30+31;
% place the monthly data at the mid point of each month
time_data1(1)=0;
time_data1(2:15)=cumsum([31;31;28;31;30;31;30;31;31;30;31;30;31;31]);
time_data2=time_data1(1:14)+(diff(time_data1)./2);

% interpolate the monthly data into 6 hourly data
for i=1:360;
    for j=1:160;
        data_6(i,j,:)=interp1(time_data2,squeeze(squeeze(data(i,j,:))),time_6,'linear');
    end
end

data_6=data_6(:,:,1:365*4);
fid=fopen('EGdust_6hr.data','w','b');
fwrite(fid,data_6,'float32');
fclose(fid);

% redo the same thing for a leap year
% set the time vectors
time_6l=31:0.25:31+31+29+31+30+31+30+31+31+30+31+30+31;
% place the monthly data at the mid point of each month
time_data1l(1)=0;
time_data1l(2:15)=cumsum([31;31;29;31;30;31;30;31;31;30;31;30;31;31]);
time_data2l=time_data1l(1:14)+(diff(time_data1l)./2);

% interpolate the monthly data into 6 hourly data
for i=1:360;
    for j=1:160;
        data_6l(i,j,:)=interp1(time_data2l,squeeze(squeeze(data(i,j,:))),time_6l,'linear');
    end
end

data_6l=data_6l(:,:,1:366*4);
fid=fopen('EGdust_6hrleap.data','w','b');
fwrite(fid,data_6l,'float32');
fclose(fid);

