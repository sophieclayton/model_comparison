function res = intrSoph(field, hFacC)

% %   rmin is optional
% if nargin < 3, rmin = -Inf;
% end
rf=[0;-10; -20; -35; -55; -75; -100; -135; -185; -260; -360; -510; -710; -985; -1335; -1750; -2200; -2700; -3200; -3700; -4200; -4700; -5200; -5700];
hFacC=permute(hFacC,[3 2 1]);
field=permute(field,[3 2 1]);
drf =(-diff(rf,1,1));
drf=repmat(drf, [1 160 360]);

size(drf)
drlop = hFacC .* drf;
kmax=23;
%  weight = max(0, min(drlop, repmat(rf(1:end-1), [nx ny 1]) - rmin));


% weight = max(0, min(drlop, permute(repmat(rf(1:end-1), [1 nx ny]), [2 3 1]) - rmin));



res = sum(drlop(1:kmax,:,:) .* field(1:kmax,:,:), 1);
res = squeeze(res);
res(hFacC(1,:,:)==0)=NaN;
res=permute(res,[2 1]);


% outpref='CRPP';
% year=1999;
% fn=sprintf('%s.%04d.data',outpref,year);
% fid=fopen(fn,'w','ieee-be');
% fwrite(fid,res,'float32');
% fclose(fid);
end