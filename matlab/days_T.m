clear all

year=1999;
mon=10;
day=1;

T = zeros([102,51,50]);
T_days = zeros([102,51,50,31]);

iit = 1;
  it0 = date2it(sprintf('%04d%02d%02d000000', year, mon, day)) + 72;
  it1 = date2it(sprintf('%04d%02d%02d000000', year, mon+1, day));

for it=it0:72:it1
  fname = sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/%04d/res_0155/T/T_day.%010d.156.001.data', year, it);
  T = readbin(fname, [102,51,50]);
  T_days(:,:,:,:,iit) = T(:,:,:,:);

  iit = iit + 1;
end

save T_days.mat -v7.3
