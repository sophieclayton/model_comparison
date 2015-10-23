eval(['load ','/scratch/jahn/run/ecco2/cube84/d0006/output/plankton_ini_char_nohead.dat']); 
plankton=plankton_ini_char_nohead;
% % 
% % load CRHRdom
% % 
% clear fpat vars
% vars = struct([]);
% vars(1).name ='X';
% vars(2).name = 'Y';
% fpat=['/home/stephd/Diags_darwin_fesource/GRID/grid.t%03d.nc'];
% [nt,nf] = mnc_assembly(fpat,vars);
% ncload(['all.00000.nc']);
% ncclose
% 
% load /home/jahn/matlab/cube66lonlat long latg


for i=1:78
   if (plankton(i,1)==1), type(i)=4; end  % diatom
   if (plankton(i,1)==0 & plankton(i,3)==1); type(i)=3; end % other big
   if (plankton(i,3)==0 & plankton(i,19)==3); type(i)=2; end % other small
   if (plankton(i,3)==0 & plankton(i,19)<3);  type(i)=1; end
   
end

  for i=1:360;
     for j=1:160;
         tmp=CRdom(i,j);
            if isnan(tmp), CRgroup(i,j)=NaN;
         else CRgroup(i,j)=type(tmp);
            end
         
%     clear tmp  
%     tmp=HR2CRdom(i,j);
%            if isnan(tmp), HR2CRgroup(i,j)=NaN;
%         else HR2CRgroup(i,j)=type(tmp);
%         end
     end
 end
clear i j

for i=1:3060;
   for j=1:510;
   tmp=HRdom(i,j);
       if isnan(tmp), HRgroup(i,j)=NaN;
       else HRgroup(i,j)=type(tmp);
       end
   clear tmp   
   end
end

% figure;
% subplot(2,1,1);pcolor(X,Y,CRgroup');shading flat;colorbar;title(['CR dominant group']);axis([0 360 -90 90]);
% subplot(2,1,2); plotcube(long,latg,HRgroup,360);shading flat; colorbar;title(['HR dominant group']);grid off;axis([0 360 -90 90]);
