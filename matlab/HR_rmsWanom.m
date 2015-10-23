% Script to calculate the meridional flux divergence of nutrients for the output of the 1^o darwin model.
% Both the eddy and mean fluxes are calculated for each grid cell.
% Sophie Clayton, June 2011
% sclayton@mit.edu

% clear all

HFacC=permute(HFacC,[3 2 1]);

% import the annual mean velocity fields
HRwvel_mean=readbin('/scratch/sclayton/high_res/WVEL_1999.data',[3060 510 50]);
HRwvel_anom=zeros(3060,510,50);

ncs = 510;
tnx = 102;
tny = 51;
tnz = 50;
ntx = ncs/tnx;
nty = ncs/tny;
nfc = 6;


day=0;
for it=184176:72:210384;
    w=zeros(tnx,ntx,nfc,tny,nty,tnz);
    
    for itile=0:299;
        
        % read in tiled files
        in=sprintf('/scratch/jahn/ecco2/cube84/tiles/L50/res_%04d/WVEL/WVEL_day.%010d.%03d.001.data',itile,it,itile+1);
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
    
    
    HRwvel_anom=HRwvel_anom+(w-HRwvel_mean).^2;
    clear w
end

HRwvel_anom=sqrt(HRwvel_anom./365);

