% script to calculate euphotic zone deepth from daily 1/6^o model output
% Sophie Clayton, June 2011
% sclayton@mit.edu

HFCR=squeeze(HFacC(1,:,:))';
euph=zeros(3060,510);
aveeuph(3060,510);

nz=50;

% set up grid
delz=readbin('
depth=cumsum(delz);

nx=3060; ny=510; nz=50;
nt=365;

depthm(1)=depth(1)/2;
for k=2:nz
    depthm(k)=depthm(k-1)+0.5*delz(k);
end % for k

for it=1:nt;
    fn=sprintf(');
    par=readbin(fn,[3060 510 50]);
    par(HFCR==0)=NaN;

    for i=1:nx, for j=1:ny,
            
            critI = 0.01*par(i,j,1);
            r = find(par(i,j,:) < critI);
            
            if isfinite(r),
                r=r(1);
                I1 = par(i,j,(r-1));
                I2 = par(i,j,(r));
                z1 = depthm(r-1);
                z2 = depthm(r);
                euph(i,j) = z1 + ((critI - I1)*(z2 - z1))/(I2 - I1);
            else
                euph(i,j) = Depth(j,i);
            end
            
            %             clear k
            %             k=find(sigmat(i,j,:,it)>sigmat(i,j,1,it)+0.125);
            %             if (isempty(k)==0),
            %                 mld(i,j,it)=depth(k(1));
            %             else
            %                 mld(i,j,it)=0;
            %             end
        end, end % for i j
   
   euph(HFHR==0)=NaN;
   
%   out=sprintf('/scratch/sclayton/coarse_rerun/extract/PAR/Zeuph.1999.%04d.data',it);
%   fid=fopen(out,'w','ieee-be');
%   fwrite(fid,euph,'float32');
%   fclose(fid);
   it
   aveeuph=aveeuph+euph;
   clear euph
end % for it
aveeuph = aveeuph./nt;

out2='/scratch/sclayton/coarse_rerun/extract/PAR/Zeuph.1999.data';
fid=fopen(out2,'w','ieee-be');
fwrite(fid,aveeuph,'float32');
fclose(fid);
   
% calculate monthly averages
days=[0;31;28;31;30;31;30;31;31;30;31;30;31];
startday=cumsum(days)+1;
endday=cumsum(days(2:end));


% load in data to be averaged
for m=1:12;
    monthly=zeros(360,160);

    for day=startday(m):1:endday(m);
        tmp=euph(:,:,day);
        monthly=monthly+tmp;

    end
    clear tmp
    monthly(:,:,:)=monthly(:,:,:)./days(m+1);


out3=sprintf('/scratch/sclayton/coarse_rerun/extract/PAR/Zeuph.monthly.1999%02d.data',m);
fid=fopen(out3,'w','ieee-be');
fwrite(fid,monthly,'float32');
fclose(fid);
m
clear monthly

end


 


