% Script to calculate the meridional flux divergence of nutrients for the output of the 1^o darwin model.
% Both the eddy and mean fluxes are calculated for each grid cell.
% Sophie Clayton, June 2011
% sclayton@mit.edu

clear all


% import the grid data needed
clear fpat vars
vars = struct([]);
vars(1).name = 'X';
vars(2).name = 'Y';
vars(3).name = 'Z';
vars(4).name = 'HFacC';
vars(5).name = 'rAw';
vars(6).name = 'Depth';
vars(7).name = 'drF';
vars(8).name = 'HFacW';
vars(9).name = 'HFacS';
vars(10).name = 'rAs';
vars(11).name = 'rA';
vars(12).name = 'dYG';
vars(13).name = 'dXG';

fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
[nt,nf] = mnc_assembly(fpat,vars);
ncload(['all.00000.nc']);
ncclose
%

HFacC=permute(HFacC,[3 2 1]);
HFacW=permute(HFacW,[3 2 1]);
HFacS=permute(HFacS,[3 2 1]);

rA=permute(rA,[2 1]);rA=repmat(rA,[1 1 23]);
rAw=permute(rAw,[2 1]);rAw=repmat(rAw,[1 1 23]);
rAs=permute(rAs,[2 1]);rAs=repmat(rAs,[1 1 23]);


nx=length(X); ny=length(Y); nz=length(Z);
for k=1:nz;
    volc(:,:,k)=rA(:,:,k).*drF(k).*(HFacC(:,:,k));
end

% import the annual mean velocity fields
uvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/U_annave.1999.data',[360 160 23]);
vvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/V_annave.1999.data',[360 160 23]);
wvel_mean=readbin('/scratch/sclayton/coarse_rerun/extract/W_annave.1999.data',[360 160 23]);

udiv=zeros(360,160,23,78);
vdiv=zeros(360,160,23,78);
wdiv=zeros(360,160,23,78);

for n=1:78
    fid=fopen('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data','r','b');
    phy_mean=fread(fid,360*160*23,'real*4');
    phy_mean=reshape(phy_mean,[360 160 23]);
    
    % calculate the annual mean lateral flux divergence of nutrients
    for i=1:360;
        %    for n=1:78;
        n1=zeros(160,23);
        n2=zeros(160,23);
        n3=zeros(160,23);
        u1=zeros(160,23);
        u2=zeros(160,23);
        
        if i>1, n1=phy_mean(i-1,:,:);
        else n1=phy_mean(1,:,:);
        end
        
        if i<360, n3=phy_mean(i+1,:,:); u2=uvel_mean(i+1,:,:);
        else n3=phy_mean(1,:,:); u2=uvel_mean(1,:,:);
        end
        
        u1=uvel_mean(i,:,:);
        n2=phy_mean(i,:,:);
        
        uflux1(i,:,:)=u1.*((n1+n2)./2).*(HFacW(i,:,:).*rAw(i,:,:));
        uflux2(i,:,:)=u2.*((n2+n3)./2).*(HFacW(i+1,:,:).*rAw(i+1,:,:));
        
        udiv(i,:,:,n)=(uflux2(i,:,:)-uflux1(i,:,:))./volc(i,:,:);
        clear n1 n2 n3
        
    end
    clear n1 n2 n3
    
    for j=1:160;
        %    for n=1:4;
        n1=zeros(360,1,23);
        n2=zeros(360,1,23);
        n3=zeros(360,1,23);
        v1=zeros(360,1,23);
        v2=zeros(360,1,23);
        
        if j>1, n1=phy_mean(:,j-1,:);
        else n1=phy_mean(:,1,:);
        end
        
        if j<160, n3=phy_mean(:,j+1,:);v2=vvel_mean(:,j+1,:);
        else n3=zeros(360,1,23); v2=zeros(360,1,23);
        end
        v1=vvel_mean(:,j,:);
        n2=phy_mean(:,j,:);
        
        vflux1(:,j,:)=v1.*((n1+n2)./2).*(HFacS(:,j,:).*rAs(:,j,:));
        vflux2(:,j,:)=v2.*((n2+n3)./2).*(HFacS(:,j+1,:).*rAs(:,j+1,:));
        
        vdiv(:,j,:,n)=(vflux2(:,j,:)-vflux1(:,j,:))./volc(:,j,:);
        clear n1 n2 n3
        
    end
    
    clear n1 n2 n3
    
    for k=1:23;
        
        n1=zeros(360,160);
        n2=zeros(360,160);
        n3=zeros(360,160);
        w1=zeros(360,160);
        w2=zeros(360,160);
        
        if k>1, n1=phy_mean(:,:,k-1);
        else n1=zeros(360,160);
        end
        w1=wvel_mean(:,:,k);
        
        if k<23, n3=phy_mean(:,:,k+1);w2=wvel_mean(:,:,k+1);
        else n3=phy_mean(:,:,k);w2=0;
        end
        n2=phy_mean(:,:,k);
        
        wflux1(:,:,k)=w1.*((n1+n2)./2).*(rA(:,:,k).*HFacC(:,:,k));
        if k<23,
            wflux2(:,:,k)=w2.*((n2+n3)./2).*(rA(:,:,k+1).*HFacC(:,:,k+1));
        else
            wflux2(:,:,k)=w2.*((n2+n3)./2).*(rA(:,:,k).*HFacC(:,:,k));
        end
        wdiv(:,:,k,n)=(wflux2(:,:,k)-wflux1(:,:,k))./volc(:,:,k);
        
        clear n1 n2 n3
    end
    clear n1 n2 n3 k
end

    % write out the divergence terms
    fid=fopen('/scratch/sclayton/coarse_rerun2/PhyFlux/UPdiv_mean.1999.data','w','ieee-be');
    fwrite(fid,udiv,'float32');
    fclose(fid);
    
    fid=fopen('/scratch/sclayton/coarse_rerun2/PhyFlux/VPdiv_mean.1999.data','w','ieee-be');
    fwrite(fid,vdiv,'float32');
    fclose(fid);
    
    fid=fopen('/scratch/sclayton/coarse_rerun2/PhyFlux/WPdiv_mean.1999.data','w','ieee-be');
    fwrite(fid,wdiv,'float32');
    fclose(fid);
    
    clear udiv vdiv wdiv phy_mean
    
    %%
    % calculate the eddy fluxes
    % in this case we subtract the annual mean from the daily values to get the anomaly
fid=fopen('/scratch/sclayton/coarse_rerun2/extract/Phyto/Phyto.1999.data','r','b');
phy=fread(fid,360*160*23*78,'real*4'); 
phy=reshape(phy,[360 160 23 78]);
fclose(fid);

udiv_anom=zeros(360,160,23,78);
vdiv_anom=zeros(360,160,23,78);
wdiv_anom=zeros(360,160,23,78);


   
    for t=1:365;

        inp=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.1999.%04d.data',t);
        fid2=fopen(inp,'r','b');
              
        inu=sprintf('/scratch/sclayton/coarse_rerun/extract/Udaily/Udaily.1999.%04d.data',t);
        uvel_day=readbin(inu,[360 160 23]);
        inv=sprintf('/scratch/sclayton/coarse_rerun/extract/Vdaily/Vdaily.1999.%04d.data',t);
        vvel_day=readbin(inv,[360 160 23]);
        inw=sprintf('/scratch/sclayton/coarse_rerun/extract/Wdaily/Wdaily.1999.%04d.data',t);
        wvel_day=readbin(inw,[360 160 23]);
        clear in inu inv inw
        
        uvel_anom=uvel_day-uvel_mean;
        vvel_anom=vvel_day-vvel_mean;
        wvel_anom=wvel_day-wvel_mean;
                 
        for n=1:78;
            phy_mean=phy(:,:,:,n);
            
            phy_day=fread(fid2,360*160*23,'real*4');
            phy_day=reshape(phy_day,[360 160 23]);
                                      
            phy_anom=phy_day-phy_mean;
                    
           
            for i=1:360;
        
                n1=zeros(160,23);
                n2=zeros(160,23);
                n3=zeros(160,23);
                u1=zeros(160,23);
                u2=zeros(160,23);
                
                if i>1, n1=phy_anom(i-1,:,:);
                else n1=phy_anom(360,:,:);
                end
                
                if i<360, n3=phy_anom(i+1,:,:); u2=uvel_anom(i+1,:,:);
                else n3=phy_anom(1,:,:); u2=uvel_anom(1,:,:);
                end
                
                u1=uvel_anom(i,:,:);
                n2=phy_anom(i,:,:);
                
                uflux1_anom(i,:,:)=u1.*((n1+n2)./2).*(rAw(i,:,:).*HFacW(i,:,:));
                uflux2_anom(i,:,:)=u2.*((n2+n3)./2).*(rAw(i,:,:).*HFacW(i,:,:));
                
                udiv_anom(i,:,:,n)=udiv_anom(i,:,:,n)+(uflux2_anom(i,:,:)-uflux1_anom(i,:,:))./volc(i,:,:);
                
                
            end
            clear n1 n2 n3
            
            
            for j=1:160;
                
                n1=zeros(360,1,23);
                n2=zeros(360,1,23);
                n3=zeros(360,1,23);
                v1=zeros(360,1,23);
                v2=zeros(360,1,23);
                
                if j>1, n1=phy_anom(:,j-1,:);
                else n1=phy_anom(:,1,:);
                end
                
                if j<160, n3=phy_anom(:,j+1,:);v2=vvel_anom(:,j+1,:);
                else n3=zeros(360,1,23); v2=zeros(360,1,23);
                end
                v1=vvel_anom(:,j,:);
                n2=phy_anom(:,j,:);
                
                vflux1_anom(:,j,:)=v1.*((n1+n2)./2).*(HFacS(:,j,:).*rAs(:,j,:));
                vflux2_anom(:,j,:)=v2.*((n2+n3)./2).*(HFacS(:,j+1,:).*rAs(:,j+1,:));
                
                vdiv_anom(:,j,:,n)=vdiv_anom(:,j,:,n)+(vflux2_anom(:,j,:)-vflux1_anom(:,j,:))./volc(:,j,:);
                
                
            end
            
            for k=1:23;
                
                n1=zeros(360,160);
                n2=zeros(360,160);
                n3=zeros(360,160);
                w1=zeros(360,160);
                w2=zeros(360,160);
                
                if k>1, n1=phy_anom(:,:,k-1);
                else n1=zeros(360,160);
                end
                w1=wvel_anom(:,:,k);
                
                if k<23, n3=phy_anom(:,:,k+1);w2=wvel_anom(:,:,k+1);
                else n3=phy_anom(:,:,k);w2=0;
                end
                n2=phy_anom(:,:,k);
                
                wflux1_anom(:,:,k)=w1.*((n1+n2)./2).*(rA(:,:,k).*HFacC(:,:,k));
                if k<23,
                    wflux2_anom(:,:,k)=w2.*((n2+n3)./2).*(rA(:,:,k+1).*HFacC(:,:,k+1));
                else
                    wflux2_anom(:,:,k)=w2.*((n2+n3)./2).*(rA(:,:,k).*HFacC(:,:,k));
                end
                
                wdiv_anom(:,:,k,n)=wdiv_anom(:,:,k,n)+(wflux2_anom(:,:,k)-wflux1_anom(:,:,k))./volc(:,:,k);
                
                
            end
           n
        end
        t
fclose(fid2);
    end
    
        udiv_anom=udiv_anom./365;
        vdiv_anom=vdiv_anom./365;
        wdiv_anom=wdiv_anom./365;
        
        fid=fopen('/scratch/sclayton/coarse_rerun2/PhyFlux/UPdiv_anom.1999.data','w','ieee-be');
        fwrite(fid,udiv_anom,'float32');
        fclose(fid);
        
        fid=fopen('/scratch/sclayton/coarse_rerun2/PhyFlux/VPdiv_anom.1999.data','w','ieee-be');
        fwrite(fid,vdiv_anom,'float32');
        fclose(fid);
        
        fid=fopen('/scratch/sclayton/coarse_rerun2/PhyFlux/WPdiv_anom.1999.data','w','ieee-be');
        fwrite(fid,wdiv_anom,'float32');
        fclose(fid);
        
        
