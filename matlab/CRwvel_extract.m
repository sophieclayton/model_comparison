% script to read in WVEL files and get monthly output

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
outpref1='CR_cube_par/500mExportCR';
outpref2='CR_cube_par/500mExportSiCR';
it1=69840;
step=720;
it2=it1+(11*step);
CRwvel=zeros(360,160);
iit=0;
k=11;
wpom=10;
wbig=0.5;

for i=it1:720:it2;
    in=sprintf('/home/stephd/ECCO/iter177/Dynvars2/DDwvel.00000%05d.data',i);
    tmp=readbin(in,[360 160 23]);
    %     iit=iit+1
    CRwvel(:,:)=CRwvel(:,:)+tmp(:,:,k+1);
    clear tmp
end

CRwvel=-(CRwvel*60*60*24)./length(i);


for tr=1:1:99;
    if tr==16,
        tmp=data(:,:,k,tr).*(CRwvel+wpom);
        export=export+tmp;
        clear tmp
    elseif tr==19;
        tmp=data(:,:,k,tr).*(CRwvel+wpom);
        exportSi= exportSi + tmp;
        clear tmp
    elseif tr>21 && isbig(tr-21)==1,
        tmp=data(:,:,k,tr).*(CRwvel+wbig);
        export=export+tmp;
        clear tmp
    elseif tr>21 && isbig(tr-21)==0,
        tmp=data(:,:,k,tr).*(CRwvel);
        export=export+tmp;
        clear tmp
    else
        tmp=zeros(360,160);
        clear tmp
    end

    if tr>21 && isbig(tr-21)==1 && isdiatom(tr-21)==1,
        tmp=data(:,:,k,tr).*(CRwvel+wbig);
        exportSi= exportSi + tmp*16;
        clear tmp
    end

end




fn=sprintf('%s.%04d.data',outpref1,year);
fid=fopen(fn,'w','ieee-be');
fwrite(fid,export,'float32');
fclose(fid);

fn=sprintf('%s.%04d.data',outpref2,year);
fid=fopen(fn,'w','ieee-be');
fwrite(fid,exportSi,'float32');
fclose(fid);