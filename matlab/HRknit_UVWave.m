% script to make global annual averaged U, V, W fields from tiled cube-sphere ECCO2 model output fields

clear all

ncs = 510;
tnx = 102;
tny = 51;
tnz = 50;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;

%u=zeros(tnx,ntx,nfc,tny,nty,tnz);
%v=zeros(tnx,ntx,nfc,tny,nty,tnz);
%w=zeros(tnx,ntx,nfc,tny,nty,tnz);

day=0;
% for it=184176:72:210384;
% for itile=0:299;
% 
% % read in tiled files
% in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/UVEL/UVEL_day.%010d.%03d.001.data',itile,it,itile+1);
% input=zeros(tnx,tny,tnz);
% input=readbin(in,[tnx tny tnz]);
% input=reshape(input,[tnx,1,1,tny,1,tnz]);
% 
% yt = floor(itile/ntx);
% xt = mod(itile,ntx);
% fc = floor(yt/nty);
% yt = mod(yt,nty);
% 
% u(:,xt+1,fc+1,:,yt+1,:)=input;
% clear input in
% 
% end
% day=day+1
% 
% u=reshape(u,[3060 510 50]);
% u=u(:,:,1:30);
% 
% out=sprintf('/scratch/sclayton/high_res/UVEL/UVEL.%04d.1999.data',day);
% fid=fopen(out,'w','ieee-be');
% fwrite(fid,u,'real*4');
% fclose(fid)
% clear out u
% end

day=0;

%for it=184176:72:210384;
%for itile=0:299;

% read in tiled files
%in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/VVEL/VVEL_day.%010d.%03d.001.data',itile,it,itile+1);
%input=zeros(tnx,tny,tnz);

%input=readbin(in,[tnx tny tnz]);
%input=reshape(input,[tnx,1,1,tny,1,tnz]);

%yt = floor(itile/ntx);
%xt = mod(itile,ntx);
%fc = floor(yt/nty);
%yt = mod(yt,nty);

%v(:,xt+1,fc+1,:,yt+1,:)= input;
%clear input in

%end
%day=day+1
%v=reshape(v,[3060 510 50]);
%v=v(:,:,1:30);

%out=sprintf('/scratch/sclayton/high_res/VVEL/VVEL.%04d.1999.data',day);
%fid=fopen(out,'w','ieee-be');
%fwrite(fid,v,'real*4');
%fclose(fid)
%clear out v
%end

day=0;
for it=184176:72:210384;
for itile=0:299;

% read in tiled files
in=sprintf('/scratch/jahn/output/ecco2/cube84/tiles300.day/1999/res_%04d/WVEL/WVEL_day.%010d.%03d.001.data',itile,it,itile+1);
input=zeros(tnx,tny,tnz);
input=readbin(in,[tnx tny tnz]);
input=reshape(input,[tnx,1,1,tny,1,tnz]);

yt = floor(itile/ntx);
xt = mod(itile,ntx);
fc = floor(yt/nty);
yt = mod(yt,nty);

w(:,xt+1,fc+1,:,yt+1,:)=  input;
clear input in

end
day=day+1
w=reshape(w,[3060 510 50]);
w=w(:,:,1:30);

out=sprintf('/scratch/sclayton/high_res/WVEL/WVEL.%04d.1999.data',day);
fid=fopen(out,'w','ieee-be');
fwrite(fid,w,'real*4');
fclose(fid)
clear out w
end









