function [fldUm,fldVm]=m_map_gcmfaces_uvrotate(fldUe,fldVn);  

global mygrid;
x=mygrid.XC; y=mygrid.YC; u=fldUe; v=fldVn;
x(find(x>180))=x(find(x>180))-360;

%compute direction:
eps=1e-3;
[xp,yp]=m_ll2xy(x+eps*u,y+eps*v.*cos(y*pi/180),'clip','point');
[x,y]=m_ll2xy(x,y,'clip','point');
complexVec=(xp-x)+i*(yp-y);
%scale amplitude
complexVec=complexVec./abs(complexVec).*abs(u+i*v);
%go back to reals:
fldUm=real(complexVec); fldUm(isnan(complexVec))=NaN;
fldVm=imag(complexVec); fldVm(isnan(complexVec))=NaN;

