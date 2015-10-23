function [X,Y,FLD]=convert2pcol_cube(x,y,fld,varargin);

if nargin>3; k3=varargin{1}; else; k3=1; end;
if nargin>4; k4=varargin{2}; else; k4=1; end;

%ASSEMBLE SIDE FACES:
%----------------------
X=[x{1};x{2};sym_g(x{4},7,0); sym_g(x{5},7,0)];
Y=[y{1};y{2};sym_g(y{4},7,0); sym_g(y{5},7,0)];
FLD=[fld{1}(:,:,k3,k4);fld{2}(:,:,k3,k4);sym_g(fld{4}(:,:,k3,k4),7,0);sym_g(fld{5}(:,:,k3,k4),7,0)];

%ADD NORTH FACE:
%---------------
pp=x{3}; 
M1=pp; M1(M1>M1(1,1))=NaN; M1(M1<M1(1,end))=NaN; M1(~isnan(M1))=1;
%M2=pp; M2(M2>M2(end,1))=NaN; M2(M2<M2(1,1))=NaN; M2(~isnan(M2))=1;
M2=pp; M2(pp<0)=NaN; M2(pp>=0)=1;
M3=pp; M3(M3<M3(end,1)&M3>M3(end,end))=NaN; M3(~isnan(M3))=1;
%M4=pp; M4(M4>M4(1,end))=NaN; M4(M4<M4(end,end))=NaN; M4(~isnan(M4))=1;
M4=pp; M4(pp>=0)=NaN; M4(pp<0)=1;

pp=x{3}; Xp=[sym_g(pp.*M1,5,0);pp.*M2;sym_g(pp.*M3,7,0);sym_g(pp.*M4,6,0)]; X=[X Xp];
pp=y{3}; Yp=[sym_g(pp.*M1,5,0);pp.*M2;sym_g(pp.*M3,7,0);sym_g(pp.*M4,6,0)]; Y=[Y Yp];
pp=fld{3}(:,:,k3,k4); FLDp=[sym_g(pp.*M1,5,0);pp.*M2;sym_g(pp.*M3,7,0);sym_g(pp.*M4,6,0)]; FLD=[FLD FLDp];

%ADD SOUTH FACE:
%--------------
pp=x{6};
M1=pp; M1(M1>M1(end,end))=NaN; M1(M1<M1(1,end))=NaN; M1(~isnan(M1))=1;
%M2=pp; M2(M2>M2(end,1))=NaN; M2(M2<M2(end,end))=NaN; M2(~isnan(M2))=1;
M2=pp; M2(pp<0)=NaN; M2(pp>=0)=1;
M3=pp; M3(M3<M3(end,1)&M3>M3(1,1))=NaN; M3(~isnan(M3))=1;
%M4=pp; M4(M4>M4(1,end))=NaN; M4(M4<M4(1,1))=NaN; M4(~isnan(M4))=1;
M4=pp; M4(pp>=0)=NaN; M4(pp<0)=1;

pp=x{6}; Xp=[pp.*M1;sym_g(pp.*M2,5,0);sym_g(pp.*M3,6,0);sym_g(pp.*M4,7,0)]; X=[Xp X];
pp=y{6}; Yp=[pp.*M1;sym_g(pp.*M2,5,0);sym_g(pp.*M3,6,0);sym_g(pp.*M4,7,0)]; Y=[Yp Y];
pp=fld{6}(:,:,k3,k4); FLDp=[pp.*M1;sym_g(pp.*M2,5,0);sym_g(pp.*M3,6,0);sym_g(pp.*M4,7,0)]; FLD=[FLDp FLD];


%FIX DATE CHANGE LINE IN LATLON PART:
%--------------------------------------
%X=circshift(X,[-240 0]); Y=circshift(Y,[-240 0]); FLD=circshift(FLD,[-240 0]);
X=circshift(X,[+765 0]); Y=circshift(Y,[+765 0]); FLD=circshift(FLD,[+765 0]);

