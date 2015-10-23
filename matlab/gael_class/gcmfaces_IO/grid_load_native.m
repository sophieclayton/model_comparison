function []=mitgcmmygrid_read(dirGrid,gridType,varargin);
%read the mygrid from the input (not mds) mygrid file
%this routine is an adaptation of 
%/net/ross/raid2/gforget/mygrids/gael_code_v2/faces2mitgcm/mitgcmmygrid_read.m
%examples of dirGrid:
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/cube_FM/cube_96/';
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/llcRegLatLon/llc_96/';
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/llpcRegLatLon/llpc_96/';
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/llcMoreTrop/eccollc_96/';
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/llcRegLatLon/llc_540/';
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/cube_FM/cube_32/';
%dirGrid='/net/weddell/raid3/gforget/mygrids/mygridCompleted/cs32_tutorial_held_suarez_cs/';

if nargin==3; useNativeFormat=varargin{1}; else; useNativeFormat=0; end;

if useNativeFormat==1;
global MM Nfaces;
global dyG dxG dxF dyF dxC dyC dyU dxV rA rAw rAs rAz xC yC xG yG xS yS xW yW;
else;
global mygrid;
end;

files=dir([dirGrid '*bin']);
tmp1=[]; 
for ii=1:length(files); 
    if isempty(strfind(files(ii).name,'FM')); tmp1=[tmp1;ii]; end; 
end;
files=files(tmp1);


list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};
list_fields={'xC','yC','dxF','dyF','rA','xG','yG','dxV','dyU','rAz',...
    'dxC','dyC','rAw','rAs','dxG','dyG'};
list_x={'xC','xC','xC','xC','xC','xG','xG','xG','xG','xG',...
    'xW','xS','xW','xS','xS','xW'};
list_y={'yC','yC','yC','yC','yC','yG','yG','yG','yG','yG',...
    'yW','yS','yW','yS','yS','yW'};
list_ni={'ni','ni','ni','ni','ni','ni+1','ni+1','ni+1','ni+1','ni+1',...
    'ni+1','ni','ni+1','ni','ni','ni+1'};
list_nj={'nj','nj','nj','nj','nj','nj+1','nj+1','nj+1','nj+1','nj+1',...
    'nj','nj+1','nj','nj+1','nj+1','nj'};

Nfaces=length(files);

for iFile=1:Nfaces;
    tmp1=files(iFile).name;
    if strfind(dirGrid,'cs32_tutorial_held_suarez_cs');
        ni=32; nj=32;
    else;
        tmp2=strfind(tmp1,'_');
        ni=str2num(tmp1(tmp2(2)+1:tmp2(3)-1));
        nj=str2num(tmp1(tmp2(3)+1:end-4));
    end;
    if iFile==1; MM=ni; end;
    fid=fopen([dirGrid files(iFile).name],'r','b');
    for iFld=1:length(list_fields);
        eval(['nni=' list_ni{iFld} ';']);
        eval(['nnj=' list_nj{iFld} ';']);
        tmp1=fread(fid,[ni+1 nj+1],'float64');
        if useNativeFormat;
           eval([list_fields{iFld} '{' num2str(iFile) '}.vals=tmp1(1:nni,1:nnj);']);
           eval([list_fields{iFld} '{' num2str(iFile) '}.x=''' list_x{iFld} ''';']);
        else;
           if iFile==1; eval(['mygrid.' list_fields2{iFld} '=gcmfaces(Nfaces,''' gridType  ''');']); end;
           eval(['mygrid.' list_fields2{iFld} '{iFile}=tmp1(1:ni,1:nj);']);
        end;
    end;
    fclose(fid);
    if useNativeFormat;
       xS{iFile}.vals=(xG{iFile}.vals(2:end,:)+xG{iFile}.vals(1:end-1,:))/2;
       yS{iFile}.vals=(yG{iFile}.vals(2:end,:)+yG{iFile}.vals(1:end-1,:))/2;
       xW{iFile}.vals=(xG{iFile}.vals(:,2:end)+xG{iFile}.vals(:,1:end-1))/2;
       yW{iFile}.vals=(yG{iFile}.vals(:,2:end)+yG{iFile}.vals(:,1:end-1))/2;
   end;
end;
