% script to calculate the diversity of the top 200m of the water column
% from the output of the high resolution and coarse resolution model
% output.

% for the coarse resolution data
kmax=10;
CRdata=readbin('/scratch/sclayton/coarse_rerun/extract/Phyto/Phyto.1999.data',[360 160 23 78]);
CRint=readbin('/scratch/sclayton/coarse_rerun/extract/Phyto/IntPhyto.1999.data',[360 160]);
CRint=sum(CRint,3);

rf=[0;-10; -20; -35; -55; -75; -100; -135; -185; -260; -360; -510; -710; -985; -1335; -1750; -2200; -2700; -3200; -3700; -4200; -4700; -5200; -5700];
divCR=zeros(360,160,kmax);
div4CR=zeros(360,160);

for i=1:360;
    for j=1:160;
        for k=1:kmax;
            for l=1:78;
                if (CRdata(i,j,k,l) > 200*10^-12)
                    divCR(i,j,k)=divCR(i,j,k)+1;
                end
            end

        end
        mm=find(max(divCR(i,j,k)));
        if isfinite(mm)
            div4CR(i,j)=divCR(i,j,mm);
        else div4CR(i,j)=NaN;
        end
    end
end


