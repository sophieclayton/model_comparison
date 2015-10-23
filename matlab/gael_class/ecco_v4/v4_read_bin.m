function [fld]=v4_read_bin(fileName,varargin);
%usage: fld=v4_read_bin(fileName);         reads 1st 3D field
%usage: fld=v4_read_bin(fileName,trec);    reads 3D field no trec   
%usage: fld=v4_read_bin(fileName,trec,k);  reads level k of 3D field no trec
%usage: fld=v4_read_bin(fileName,trec,0);  reads 2D field no trec 

global mygrid;

n1=90; n2=1170; n3=50; nF=5;
recl2D=n1*n2*4; recl3D=n1*n2*n3*4; myprec='float32';
%recl2D=n1*n2*8; recl3D=n1*n2*n3*8; myprec='float64'

if nargin>1; tt=varargin{1}; else; tt=1; end;
if nargin>2; kk=varargin{2}; else; kk=[]; end;

fid=fopen(fileName,'r','b');
if ~isempty(kk);
  if kk==0;%meaning the field is only two dimensional
      status=fseek(fid,(tt-1)*recl2D,'bof');
      fld=reshape(fread(fid,n1*n2,myprec),[n1 n2]);
  else;
      status=fseek(fid,(tt-1)*recl3D+(kk-1)*recl2D,'bof');
      fld=reshape(fread(fid,n1*n2,myprec),[n1 n2]);
  end;
else;
  status=fseek(fid,(tt-1)*recl3D,'bof');
  fld=reshape(fread(fid,n1*n2*n3,myprec),[n1 n2 n3]);
end;
fclose(fid);

fld=convert2gcmfaces(fld,nF);

