% script to calculate the horizontal flux divergence of nutrients from output from the ECCO2 darwin model run
% Sophie Clayton, July 2011
% sclayton@mit.edu

clear all

% set up the grid stuff
addpath /home/jahn/matlab/gael_class

gcmfaces_init
dirGrid='/scratch/jahn/run/ecco2/cube84/d0006/run.13/';
global mygrid
mygrid = []
grid_load(dirGrid,6);

% calculate the volume and face areas of the grid boxes
volc=0*mygrid.hFacC;
as=0*mygrid.hFacC;
aw=0*mygrid.hFacC;

% load in the annual average u,v, phyto
inua='/scratch/sclayton/high_res/UVEL_1999.data';
ufida=fopen(inua,'r','ieee-be');

inva='/scratch/sclayton/high_res/VVEL_1999.data';
vfida=fopen(inva,'r','ieee-be');

ua=fread(ufida,[3060 510],'real*4');
fclose(ufida);
va=fread(vfida,[3060 510],'real*4');
fclose(vfida);

dVNa=zeros(3060,510,78);
dUNa=zeros(3060,510,78);

for t=1:365;
    
    inpa='/scratch/sclayton/high_res/Phyto/AveSurfPhyto.1999.data';
    pfida=fopen(inpa,'r','ieee-be');
    
    day=t;
    
    inu=sprintf('/scratch/sclayton/high_res/UVEL/UVEL.%04d.1999.data',day);
    ufid=fopen(inu,'r','ieee-be');
    
    inv=sprintf('/scratch/sclayton/high_res/VVEL/VVEL.%04d.1999.data',day);
    vfid=fopen(inv,'r','ieee-be');
    
    inp=sprintf('/scratch/sclayton/high_res/Phyto/DailySurfPhyto.1999.%04d.data',day);
    pfid=fopen(inp,'r','ieee-be');
    
    for k=1;
        
        
        
        for f=1:6;
            volc{f}=mygrid.RAC{f}*mygrid.DRF(k)*mygrid.hFacC{f}(:,:,k);
            as{f}=mygrid.DRF(k).*mygrid.DYG{f}.*mygrid.hFacS{f}(:,:,k);
            aw{f}=mygrid.DRF(k).*mygrid.DXG{f}.*mygrid.hFacW{f}(:,:,k);
        end
        
        
        % load in global fields of the variables
        % U,V
        % [u,v]=HRknit_UVave(it,k);
        
        
        u=fread(ufid,[3060 510],'real*4');
        u=u-ua;
        v=fread(vfid,[3060 510],'real*4');
        v=v-va;
        
        u=convert2gcmfaces(u,6);
        %u=u(:,:,1:30);
        v=convert2gcmfaces(v,6);
        %v=v(:,:,1:30);
        
        for n=1:78;
            
            Na=fread(pfida,[3060 510],'real*4');
            
            N=fread(pfid,[3060 510],'real*4');
            N=N-Na;
            
            % interpolate the nutrients onto the same grid as U,V
            
            N=convert2gcmfaces(N,6,'cube');
            
            N=N.*mygrid.mskC(:,:,1);
            N=exch_T_N(N);
            
            for f=1:6;
                Nu{f}=0.5.*(N{f}(1:end-2,2:end-1,:)+N{f}(2:end-1,2:end-1,:));
                Nv{f}=0.5.*(N{f}(2:end-1,1:end-2,:)+N{f}(2:end-1,2:end-1,:));
            end
            
            Nu=gcmfaces(Nu);
            Nv=gcmfaces(Nv);
            % calculate the fluxes
            UN=u.*Nu.*aw(:,:,1);
            VN=v.*Nv.*as(:,:,1);
            
            [UN,VN]=exch_UV(UN,VN);
            for f=1:6;
                divUN{f}(:,:)=(UN{f}(1:end-1,:)-UN{f}(2:end,:))./volc{f}(:,:);
                divVN{f}(:,:)=(VN{f}(:,1:end-1)-VN{f}(:,2:end))./volc{f}(:,:);
            end
            
            % convert back to matlab format
            divUN=gcmfaces(divUN);
            dUN(1:510,:)=divUN{1};
            dUN(511:1020,:)=divUN{2};
            dUN(1021:1530,:)=divUN{3};
            dUN(1531:2040,:)=divUN{4};
            dUN(2041:2550,:)=divUN{5};
            dUN(2551:3060,:)=divUN{6};
            dUNa(:,:,n)=dUNa(:,:,n)+dUN;
            
            clear divUN dUN
            
            divVN=gcmfaces(divVN);
            dVN(1:510,:)=divVN{1};
            dVN(511:1020,:)=divVN{2};
            dVN(1021:1530,:)=divVN{3};
            dVN(1531:2040,:)=divVN{4};
            dVN(2041:2550,:)=divVN{5};
            dVN(2551:3060,:)=divVN{6};
            dVNa(:,:,n)=dVNa(:,:,n)+dVN;
            
            clear divVN dVN
            
            
            if n==78, fclose(pfid); fclose(pfida); end
            
            clear Nu Nv UN VN dUN dVN
        end %n
        
        if k==1, fclose(ufid); fclose(vfid); end
        
    end %k
   
end %t

% write out the flux divergence of the tracer
out='/scratch/sclayton/high_res/horz_flux/ANOMdivUNtop.1999.data';
fidout=fopen(out,'w','b');
fwrite(fidout,dUNa,'real*4');
fclose(fidout);

out='/scratch/sclayton/high_res/horz_flux/ANOMdivVNtop.1999.data';
fidout=fopen(out,'w','b');
fwrite(fidout,dVNa,'real*4');
fclose(fidout);






