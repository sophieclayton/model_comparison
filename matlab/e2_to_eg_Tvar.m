% Regrid the cube78 ECCO2 ETAN time series to 1 hourly ETAN time
% series on the ECCO-Godae v3 mesh - using bin averaging in space and time.

rmwfile='/scratch/jahn/run/ecco2/cube84/grid/e2_to_eg/hrmp_e2_cs510_to_eg_v3_noland.nc';

hFacCfile = '/scratch/jahn/run/ecco2/cube84/grid/hFacC.data';


% ECCO-Godae maskfile and number of vertical levels (needed to read mask).
%outhFacCfile='hFacC_eg.data';
outhFacCfile='/scratch/stephd/DARWIN12/run89d/Year10_month/grid.*.nc';
nzout=23;
outfpref=['HR2CR_MLD_av'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load weights information
nc=netcdf(rmwfile,'r');
tmp=nc('num_links'); nlinks=tmp(:);
tmp=nc('src_grid_size'); ndin=tmp(:);
ndxout=nc{'dst_grid_dims'}(1);
ndyout=nc{'dst_grid_dims'}(2);
rmp_wgts=nc{'remap_matrix'}(:,:);
rmp_src_i=nc{'src_address'}(:);
rmp_dst_i=nc{'dst_address'}(:);
close(nc);

hFacC = readbin(hFacCfile, (ndin));

% Load output mesh hFacC data
%fid=fopen(outhFacCfile,'r','ieee-be');
%outhfacc=fread(fid,ndxout*ndyout*nzout,'float32');
%fclose(fid);
%outhfacc=reshape(outhfacc,[ndxout ndyout nzout]);
tmp=rdmnc(outhFacCfile, 'HFacC');
outhfacc=tmp.HFacC;
clear tmp
dstmask1=outhfacc(:,:,1);
dstmask1(find(dstmask1~=0))=1;
%dstmask1=ones([ndxout ndyout]);

% Create the weights matrix
rm_mat=sparse(rmp_dst_i(:),rmp_src_i(:),rmp_wgts(:,1),ndxout*ndyout,ndin);

% Loop over fields, time average and then regrid. 

        phiall=HRmld_av;
        fooall=zeros(360,160);
        %for g=1:4;
        % phi=phiall(:,g);
        phi=phiall;
        phi(phi==0)=1e-30;
        phi(hFacC==0)=0;
        phi=reshape(phi,[510 6 510 1]);
        phi=squeeze(phi(:,:,:,1));
        phi=permute(phi,[1 3 2]);
        % Create a field with 1 over water and 0 over land
        phi_one=phi(:).*0;
        phi_one(find(phi(:)~=0))=1;
        
        % Bin average the src field to the dst mesh
        foo=rm_mat*phi(:);
        foo=full(foo);
        foo=reshape(foo,[ndxout ndyout]);
        % Bin average the land-sea mask field to the dst mesh
        foo_one=rm_mat*phi_one;
        foo_one=full(foo_one);
        foo_one=reshape(foo_one,[ndxout ndyout]);
        a=foo_one(find(foo_one~=0));
        foo_one(find(foo_one~=0))=1./a;
        % Zap points for which less than 1/alpha of the cell
        % is wet.
        alpha=20;
        foo_one(find(foo_one>alpha))=0.;
        foo=foo.*foo_one;
        foo=foo.*dstmask1;
        foo(dstmask1==0)=0.;
        fooall(:,:)=foo;
        fooall(isnan(fooall))==0;
        %end
        % Write out the field
        fn=sprintf('/scratch/sclayton/HR2CRdata/%s.1999.data',outfpref);
        fid=fopen(fn,'w','ieee-be');
        fwrite(fid,fooall,'float32');
        fclose(fid);
    clear phiall fooall   
