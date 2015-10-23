function [alldiag,alldiag_anom]=alldiag_load(dirIn,suffIn,timeStep);

%get list of files
listFiles=dir([dirIn '/diags_' suffIn '*.mat']);
%get time steps and sort listFiles 
listSteps=[]; for tt=1:length(listFiles); listSteps=[listSteps;str2num(listFiles(tt).name(13:end-4))]; end;
[listSteps,ii]=sort(listSteps);
listFiles=listFiles(ii);
%compute actual times
nTimes=length(listSteps);
listTimes=listSteps*timeStep/86400;
%initialize alldiag
alldiag=open([dirIn listFiles(1).name]);
listDiags=fieldnames(alldiag);
%loop and concatenate
for tt=2:length(listSteps);
   tmpdiag=open([dirIn listFiles(tt).name]);
   for ii=1:length(listDiags);
     %get data: 
     eval(['tmp1=tmpdiag.' listDiags{ii} '; tmp2=alldiag.' listDiags{ii} ';']); 
     %determine the time dimension:
     if strcmp(class(tmp1),'gcmfaces'); nDim=size(tmp1{1}); else; nDim=size(tmp1); end; 
     if ~isempty(find(nDim==0)); nDim=0;
     elseif nDim(end)==1; nDim=length(nDim)-1;
     else; nDim=length(nDim);
     end;
     %concatenate along the time dimension:
     if nDim>0; tmp2=cat(nDim+1,tmp2,tmp1); eval(['alldiag.' listDiags{ii} '=tmp2;']); end;
   end;
end;
%clean empty diags up
for ii=1:length(listDiags);
  eval(['tmp1=isempty(alldiag.' listDiags{ii} ');']);
  if tmp1; alldiag=rmfield(alldiag,listDiags{ii}); end;
end;
%complement alldiag
listDiags=fieldnames(alldiag);
alldiag.listSteps=listSteps;
alldiag.listTimes=listTimes;
alldiag.listDiags=listDiags;
%subtract monthly climatology:
alldiag_anom=alldiag;
mm=mod([1:length(listSteps)],12); mm(mm==0)=12;
for ii=1:length(listDiags);
  tmp1=getfield(alldiag,listDiags{ii}); 
  if strcmp(class(tmp1),'gcmfaces'); nDim=size(tmp1{1}); else; nDim=size(tmp1); end;
  nDim=length(nDim); tt=''; for jj=1:nDim-1; tt=[tt ':,']; end;
  eval(['tmp2=tmp1(' tt '1:12);']);
  for jj=1:12; 
    JJ=find(mm==jj); eval(['tmp2(' tt 'jj)=mean(tmp1(' tt 'JJ),nDim);']);
  end;
  eval(['tmp1=tmp1-tmp2(' tt 'mm);']);
  eval(['alldiag_anom.' listDiags{ii} '=tmp1;']);
end;


