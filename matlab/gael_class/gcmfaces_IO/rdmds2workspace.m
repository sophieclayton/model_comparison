function []=rdmds2workspace(fileName,varargin);

data=rdmds2gcmfaces(fileName,varargin{:});

tmp1=dir([fileName '*.meta']); tmp1=tmp1(1).name;
tmp2=strfind(fileName,'/'); tmp2=tmp2(end);
tmp1=[fileName(1:tmp2) tmp1]; fid=fopen(tmp1);
while 1;
  tline = fgetl(fid);
  if ~ischar(tline), break, end
  if isempty(whos('tmp3')); tmp3=tline; else; tmp3=[tmp3 ' ' tline]; end;
end
fclose(fid);

tmp1=who;%list current workspace variables
eval(tmp3);%add meta variables to workspace
tmp3=who;%also list meta variables
for ii=1:length(tmp3);%store in structure (meta)
  if sum(strcmp(tmp1,tmp3(ii)))==0;
    eval(['meta.' tmp3{ii} '=' tmp3{ii} ';']);
  end;
end;

%export the various fields to caller workspace:
assignin('caller','meta',meta);

%export the various fields to caller workspace:
for ii=1:meta.nFlds;
  if meta.nDims==3; 
    assignin('caller',deblank(meta.fldList{ii}),squeeze(data(:,:,:,ii,:)));
  else; 
    assignin('caller',deblank(meta.fldList{ii}),squeeze(data(:,:,ii,:)));
  end;
end;
 
