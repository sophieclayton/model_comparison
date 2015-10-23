clear all


HFCR=readbin('/scratch/sclayton/coarse_rerun/grid/HFacC.data',[360 160]);

T_ave=zeros(360,160);
T_var=zeros(360,160);
T=zeros(360,160);
    
    for day=1:365;
        in=sprintf('/scratch/sclayton/coarse_rerun/extract/Temp/Temp_daily.1999.%04d.data',day);
        T_ave=T_ave + readbin(in,[360,160]);
        
    end
    T_ave=T_ave./365;
    
    
    for day=1:365;
    in=sprintf('/scratch/sclayton/coarse_rerun/extract/Temp/Temp_daily.1999.%04d.data',day);
        T=readbin(in,[360,160]);
    T_var=T_var + (T-T_ave).^2;
    
    clear T
    end
    
    T_var=T_var./365;
    T_var(HFCR==0)=NaN;
    
out='/scratch/sclayton/coarse_rerun/extract/Temp/Tvar.1999.data';
fid=fopen(out,'w','ieee-be');
fwrite(fid,T_var,'float32');
fclose(fid);

% clear monthly

