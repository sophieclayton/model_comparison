% Script to calculate the meridional flux divergence of nutrients for the output of the 1^o darwin model.
% Both the eddy and mean fluxes are calculated for each grid cell.
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all

% import the grid data needed
clear fpat vars
vars = struct([]);
vars(1).name = 'HFacC';
vars(2).name = 'drF';
vars(3).name = 'HFacW';
vars(4).name = 'HFacS';
vars(5).name = 'rA';
vars(6).name = 'dyG';
vars(7).name = 'dxG';

fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose
%

HFacC=permute(HFacC,[3 2 1]);
HFacW=permute(HFacW,[3 2 1]);
HFacS=permute(HFacS,[3 2 1]);

rA=permute(rA,[2 1]);rA=repmat(rA,[1 1 23]);
dyG = permute(dyG,[2 1]); dyG = repmat(dyG,[1 1 23]);
dxG = permute(dxG,[2 1]); dxG = repmat(dxG,[1 1 23]);

zed = find(HFacC~=0);
Aw = (dyG.*HFacW);
Aw = Aw(1:360,:,:);
Aw(zed) = Aw(zed)./(HFacC(zed).*rA(zed));

As = (dxG.*HFacS);
As = As(:,1:160,:);
As(zed) = As(zed)./(HFacC(zed).*rA(zed));

% import the annual mean velocity fields
uvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/U_annave.1999.data',[360 160 23]);
vvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/V_annave.1999.data',[360 160 23]);

uvel_mean = uvel_mean.*Aw;
vvel_mean = vvel_mean.*As;

nx=360; ny=160;

% import the annual mean nutrient fields
nuts_mean=readbin('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data',[360 160 23 78]);

udiv=zeros(360,160,23,78);
vdiv=zeros(360,160,23,78);
wdiv=zeros(360,160,23,78);


% calculate the annual mean lateral flux divergence of nutrients
for i=1:360;
    for n=1:78;
        n1=zeros(160,78);
        n2=zeros(160,78);
        n3=zeros(160,78);
        u1=zeros(160,78);
        u2=zeros(160,78);
        
        if i>1, n1=nuts_mean(i-1,:,:,n);
        else n1=nuts_mean(360,:,:,n);
        end
        
        if i<360, n3=nuts_mean(i+1,:,:,n); u2=uvel_mean(i+1,:,:);
        else n3=nuts_mean(1,:,:,n); u2=uvel_mean(1,:,:);
        end
        
        u1=uvel_mean(i,:,:);
        n2=nuts_mean(i,:,:,n);
        
        udiv(i,:,:,n)=(u2.*((n2+n3)./2))-(u1.*((n1+n2)./2));
    end
    
end
clear u1 u2 n1 n2 n3

for j=1:160;
    for n=1:78;
        n1=zeros(360,1,78);
        n2=zeros(360,1,78);
        n3=zeros(360,1,78);
        v1=zeros(360,1,78);
        v2=zeros(360,1,78);
        
        if j>1, n1=nuts_mean(:,j-1,:,n);
        else n1=nuts_mean(:,1,:,n);
        end
        
        if j<160, n3=nuts_mean(:,j+1,:,n);v2=vvel_mean(:,j+1,:);
        else n3=zeros(360,1,23); v2=zeros(360,1,23);
        end
        v1=vvel_mean(:,j,:);
        n2=nuts_mean(:,j,:,n);
        
        vdiv(:,j,:,n)=(v2.*((n2+n3)./2))-(v1.*((n1+n2)./2));
    end
    
end

clear v1 v2 n1 n2 n3

% write out the divergence terms
fid=fopen('/scratch/sclayton/coarse_rerun2/PHYFlux/UPHYdiv_mean.1999.data','w','ieee-be');
fwrite(fid,udiv,'float32');
fclose(fid);

fid=fopen('/scratch/sclayton/coarse_rerun2/PHYFlux/VPHYdiv_mean.1999.data','w','ieee-be');
fwrite(fid,vdiv,'float32');
fclose(fid);

% calculate the eddy fluxes
% in this case we subtract the annual mean from the daily values to get the anomaly

for t=1:365;
    in=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',t);
    nuts_day=readbin(in,[360 160 23 78]);
    
    inu=sprintf('/scratch/sclayton/coarse_rerun/extract/Udaily/Udaily.1999.%04d.data',t);
    uvel_day=readbin(inu,[360 160 23]);
    uvel_day = uvel_day.*Aw;
    
    inv=sprintf('/scratch/sclayton/coarse_rerun/extract/Vdaily/Vdaily.1999.%04d.data',t);
    vvel_day=readbin(inv,[360 160 23]);
    vvel_day = vvel_day.*As;
    clear in inu inv
    
    nuts_anom=nuts_day-nuts_mean;
    uvel_anom=uvel_day-uvel_mean;
    vvel_anom=vvel_day-vvel_mean;
    
    udiv_anom=zeros(360,160,23,78);
    vdiv_anom=zeros(360,160,23,78);
    
    for i=1:360;
        for n=1:78;
            n1=zeros(160,78);
            n2=zeros(160,78);
            n3=zeros(160,78);
            u1=zeros(160,78);
            u2=zeros(160,78);
            
            if i>1, n1=nuts_anom(i-1,:,:,n);
            else n1=nuts_anom(360,:,:,n);
            end
            
            if i<360, n3=nuts_anom(i+1,:,:,n); u2=uvel_anom(i+1,:,:);
            else n3=nuts_anom(1,:,:,n); u2=uvel_anom(1,:,:);
            end
            
            u1=uvel_anom(i,:,:);
            n2=nuts_anom(i,:,:,n);
            
            udiv_anom(i,:,:,n)=udiv_anom(i,:,:,n)+((u2.*((n2+n3)./2))-(u1.*((n1+n2)./2)));
        end
        
    end
    clear n1 n2 n3
    
    
    for j=1:160;
        for n=1:78;
            n1=zeros(360,1,78);
            n2=zeros(360,1,78);
            n3=zeros(360,1,78);
            v1=zeros(360,1,78);
            v2=zeros(360,1,78);
            
            if j>1, n1=nuts_anom(:,j-1,:,n);
            else n1=nuts_anom(:,1,:,n);
            end
            
            if j<160, n3=nuts_anom(:,j+1,:,n);v2=vvel_anom(:,j+1,:);
            else n3=zeros(360,1,23); v2=zeros(360,1,23);
            end
            v1=vvel_anom(:,j,:);
            n2=nuts_anom(:,j,:,n);
            
            vflux1_anom(:,j,:,n)=v1.*((n1+n2)./2)
            vflux2_anom(:,j,:,n)=v2.*((n2+n3)./2)
            
            vdiv_anom(:,j,:,n)=vdiv_anom(:,j,:,n)+((v2.*((n2+n3)./2))-(v1.*((n1+n2)./2)));
        end
        
    end
    
    t
end

udiv_anom=udiv_anom./365;
vdiv_anom=vdiv_anom./365;

fid=fopen('/scratch/sclayton/coarse_rerun/PHYFlux/UPHYdiv_anom.1999.data','w','ieee-be');
fwrite(fid,udiv_anom,'float32');
fclose(fid);

fid=fopen('/scratch/sclayton/coarse_rerun/PHYFlux/VPHYdiv_anom.1999.data','w','ieee-be');
fwrite(fid,vdiv_anom,'float32');
fclose(fid);



