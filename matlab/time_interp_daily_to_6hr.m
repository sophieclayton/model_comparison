% Script to interpolate monthly data into 6 hourly data
% Sophie Clayton (sclayton@mit.edu)
% March 2011

clear all

for year = 1994:1999;

if year == 1996, yday=366;
else yday=365;
end

for day=1:yday;

in=sprintf('/scratch/sclayton/HR2CR_SIarea/HR2CR_SIarea.%04d.%04d.data',day,year);
data(:,:,day+1)=readbin(in,[360 160]);
end

if year<1999, in3=sprintf('/scratch/sclayton/HR2CR_SIarea/HR2CR_SIarea.0001.%04d.data',year+1);
data(:,:,yday+2)=readbin(in3,[360 160]);
else data(:,:,yday+2)=data(:,:,yday+1);
end
if year>1995, in2=sprintf('/scratch/sclayton/HR2CR_SIarea/HR2CR_SIarea.0365.%04d.data',year-1);
data(:,:,1)=readbin(in2,[360 160]);
else data(:,:,1)=data(:,:,2);
end


% set the time vectors
time_6=0.25:0.25:yday;
% place the daily data at the mid point of each day
time_data=-0.5:1:yday+0.5;

% interpolate the monthly data into 6 hourly data
for i=1:360;
    for j=1:160;
        data_6(i,j,:)=interp1(time_data,squeeze(squeeze(data(i,j,:))),time_6,'linear');
    end
end

data_6=data_6(:,:,1:yday*4);
out=sprintf('/scratch/sclayton/HR2CR_SIarea/6hrly/EG_SIarea_6hr.%04d.data',year);
fid=fopen(out,'w','b');
fwrite(fid,data_6,'float32');
fclose(fid);

year
clear data_6 time_data time_6 data

end


% redo the same thing for a leap year
% set the time vectors

% interpolate the monthly data into 6 hourly data
%for i=1:360;
%    for j=1:160;
%        data_6l(i,j,:)=interp1(time_data2l,squeeze(squeeze(data(i,j,:))),time_6l,'linear');
%    end
%end

%data_6l=data_6l(:,:,1:366*4);
%fid=fopen('EGdust_6hrleap.data','w','b');
%fwrite(fid,data_6l,'float32');
%fclose(fid);

