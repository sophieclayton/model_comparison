% script to calculate export at 500m for the ECCO3 darwin model output
% Sophie Clayton, updated Aug 2011
% scalyton@mit.edu

clear all

% load in phytoplankton attributes
eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']);
plankton=plankton_ini_char_nohead;
isdiatom=zeros(78,1);
isbig=zeros(78,1);
export=zeros(360,160);
exportSi=zeros(360,160);

for i=1:78
    if (plankton(i,1)==1),
        isdiatom(i)=1; %diatom
    else isdiatom(i)=0;
    end

    if (plankton(i,3)==1),
        isbig(i)=1;
    else isbig(i)=0;
    end

end

year=1999;

outpref1='/scratch/sclayton/coarse_rerun2/extract/500mExportCR_gCm2day';
outpref2='/scratch/sclayton/coarse_rerun2/extract/500mExportSiCR';

iit=0;
k=11;
wpom=10;
wbig=0.5;

% step through the daily data
for i=1:365;
    in=sprintf('/scratch/sclayton/coarse_rerun/extract/Wdaily/Wdaily.%04d.%04d.data',year,i);
    CRwvel=readbin(in,[360 160 23]);
    %     iit=iit+1
    CRwvel=-(squeeze(CRwvel(:,:,k+1)))*60*60*24;

% load in the phytoplankton data
	inp=sprintf('/scratch/sclayton/coarse_rerun2/extract/Phyto/PhytoDaily.%04d.%04d.data',year,i);
	data=readbin(inp,[360,160,23,78]);

	for tr=1:78;

	    if isbig(tr)==1;
	        tmp=data(:,:,k,tr).*(CRwvel+wbig);
	        export=export+tmp;
	        clear tmp
	    else isbig(tr)==0;
	        tmp=data(:,:,k,tr).*(CRwvel);
	        export=export+tmp;
	        clear tmp
	    end

	    if isbig(tr)==1 && isdiatom(tr)==1;
	        tmp=data(:,:,k,tr).*(CRwvel+wbig);
	        exportSi= exportSi + tmp*16;
	        clear tmp
	    end
end %tr

% load in the POP and PON data
inn = sprintf('/scratch/sclayton/coarse_rerun2/extract/NutsZoo/NutsZoo.%04d.%04d.data',year,i);
tmpn = readbin(inn,[360,160,23,21]);
nut(:,:,:,1)=tmpn(:,:,:,16);
nut(:,:,:,2)=tmpn(:,:,:,19);
clear tmpn inn

        tmp=nut(:,:,k,1).*(CRwvel+wpom);
        export=export+tmp;
        clear tmp
    
        tmp=nut(:,:,k,2).*(CRwvel+wpom);
        exportSi= exportSi + tmp;
        clear tmp
i
end %i

export = export./365.*106./1000.*12.01; % outputs export in g C/m2/day
%exportSi = exportSi./365; % outputs export in mmol Si/m2/day


fn=sprintf('%s.%04d.data',outpref1,year);
fid=fopen(fn,'w','ieee-be');
fwrite(fid,export,'float32');
fclose(fid);

% fn=sprintf('%s.%04d.data',outpref2,year);
% fid=fopen(fn,'w','ieee-be');
% fwrite(fid,exportSi,'float32');
% fclose(fid);
