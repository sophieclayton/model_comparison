function [v1]=convert2gcmfaces(v0,varargin);

global fileFormat;
if isempty(fileFormat);
 global gcmfaces_verbose;
 if gcmfaces_verbose;
   fprintf('\nconvert2gcmfaces.m init: there are several supported file conventions. \n');
   fprintf('  By default gcmfaces assumes MITgcm type binary formats as follows: \n')
   fprintf('  (1 face) straight global format; (4 or 5 faces) compact global format\n');
   fprintf('  (6 faces) cube format with one face after the other. \n');
   fprintf('  If this is inadequate, you can change the format below.\n\n');
 end;
 if nargin==1; nFaces=5; else; nFaces=varargin{1}; end;
 if nFaces==1; 		fileFormat='straight'; 
 elseif nFaces==6; 	fileFormat='cube';
 else;       		fileFormat='compact';
 end;
end;

aa=whos('v0'); doGcm2Faces=strcmp(aa.class,'double');

if doGcm2Faces;

  if nargin==1; nFaces=5; else; nFaces=varargin{1}; end;

  [n1,n2,n3,n4]=size(v0);

  if strcmp(fileFormat,'straight');
    v1={v0};
  elseif strcmp(fileFormat,'cube');
    for ii=1:6; v1{ii}=v0(n2*(ii-1)+[1:n2],:,:,:); end;
  elseif strcmp(fileFormat,'compact');

    nn=size(v0,1); 
    pp=size(v0,2)/nn;
    mm=(pp+4-nFaces)/4*nn; 

    v00=reshape(v0,[nn*nn*pp n3*n4]);
    i0=1; i1=nn*mm; v1{1}=reshape(v00(i0:i1,:),[nn mm n3 n4]);
    i0=i1+1; i1=i1+nn*mm; v1{2}=reshape(v00(i0:i1,:),[nn mm n3 n4]);
    i0=i1+1; i1=i1+nn*nn; v1{3}=reshape(v00(i0:i1,:),[nn nn n3 n4]);
    i0=i1+1; i1=i1+nn*mm; v1{4}=reshape(v00(i0:i1,:),[mm nn n3 n4]);
    i0=i1+1; i1=i1+nn*mm; v1{5}=reshape(v00(i0:i1,:),[mm nn n3 n4]);
    if nFaces==6;
       i0=i1+1; i1=i1+nn*nn; v1{6}=reshape(v00(i0:i1,:),[nn nn n3 n4]);
    end;

  end;

  if nFaces==1; gridType='ll'; elseif nFaces==5; gridType='llc'; elseif nFaces==6; gridType='cube'; end;
  v1=gcmfaces(v1,gridType);

else;

  nFaces=get(v0,'nFaces');

  [n1,n2,n3,n4]=size(v0{1});

  if strcmp(fileFormat,'straight');
    v1=v0{1};
  elseif strcmp(fileFormat,'cube');
    v1=zeros(n2*6,n2,n3,n4);
    for ii=1:6; v1([1:n2]+(ii-1)*n2,:,:,:)=v0{ii}; end;
  elseif strcmp(fileFormat,'compact');

    v0_faces=v0; clear v0; 
    for iFace=1:nFaces; eval(['v0{iFace}=get(v0_faces,''f' num2str(iFace) ''');']); end; 

    nn=size(v0{1},1); mm=size(v0{1},2); 
    pp=mm/nn*4+nFaces-4;

    n3=size(v0{1},3); n4=size(v0{1},4);
    v1=NaN*zeros(nn,nn*pp,n3,n4);

    v11=NaN*zeros(nn*nn*pp,n3*n4);
  
   i0=1; i1=nn*mm; tmp1=reshape(v0{1},[nn*mm n3*n4]); v11(i0:i1,:)=tmp1(:,:);
   i0=i1+1; i1=i1+nn*mm; tmp1=reshape(v0{2},[nn*mm n3*n4]); v11(i0:i1,:)=tmp1(:,:);
   i0=i1+1; i1=i1+nn*nn; tmp1=reshape(v0{3},[nn*nn n3*n4]); v11(i0:i1,:)=tmp1(:,:);
   i0=i1+1; i1=i1+nn*mm; tmp1=reshape(v0{4},[mm*nn n3*n4]); v11(i0:i1,:)=tmp1(:,:);
   i0=i1+1; i1=i1+nn*mm; tmp1=reshape(v0{5},[mm*nn n3*n4]); v11(i0:i1,:)=tmp1(:,:);
   if nFaces==6; 
      i0=i1+1; i1=i1+nn*nn; tmp1=reshape(v0{6},[nn*nn n3*n4]); v11(i0:i1,:)=tmp1(:,:);
   end;

   v1=reshape(v11,[nn nn*pp n3 n4]);

  end;
 
end;


