% script to interpolate between the ocmip fields and Bill Dewar's coarsest North Pacific domain
% June 2012
% Sophie Clayton, sclayton@ mit.edu

clear all

% load in all the grid data for ocmip
X=
Y=
Z=
OCHF=redbin('

% load in data to be interpolated
V=

% load in all the grid data for North Pac
XI=readbin('~/sclayton/hires_kuroshio/XC.data',[]);
YI=readbin('~/sclayton/hires_kuroshio/YC.data',[]);
ZI=readbin('~/sclayton/hires_kuroshio/RF.data',[]);
z=length(ZI);
ZI=repmat(ZI,[]);
NPHF=readbin('readbin('~/sclayton/hires_kuroshio/hFacC.data',[]);


% 3-D interpolation
VI = interp3(X,Y,Z,V,XI,YI,ZI,'nearest');


% check for empty grid points in interpolated data
tt=find(HFNP==1 & isnan(VI));






