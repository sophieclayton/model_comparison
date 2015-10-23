
global gcmfaces_skipplottest; %externally set key that will bypass the interactive plotting test
if isempty(gcmfaces_skipplottest); gcmfaces_skipplottest=0; end;

global gcmfaces_verbose; %to print notes to screen
if isempty(gcmfaces_verbose); gcmfaces_verbose=1; end;


global gcmfaces_dir; gcmfaces_dir=[pwd '/'];

fid=fopen([gcmfaces_dir 'gcmfaces_path.m'],'wt');
fprintf(fid,['global gcmfaces_dir; gcmfaces_dir=''' gcmfaces_dir ''';\n']);
fprintf(fid,['addpath ' gcmfaces_dir ';\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_IO/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_convert/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_exch/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_maps/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_misc/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_calc/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_smooth/;\n']);
%fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_specs/;\n']);
%fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_legacy/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'gcmfaces_devel/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'sample_analysis/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'sample_processing/;\n']);
fprintf(fid,['addpath ' gcmfaces_dir 'ecco_v4/;\n']);
fclose(fid);

if gcmfaces_verbose;
fprintf('\n\n\n***********message from gcmfaces_init.m************ \n');
fprintf(' gcmfaces_path.m was created that, when executed, \n');
fprintf(' adds the gcmfaces directories to your path  \n\n\n');
fprintf(' ultimately you may want to copy it in your startup.m \n');
end;

gcmfaces_path;

test0=dir('sample_input'); if isempty(test0); fprintf('no sample input data found\n'); return; end;

fprintf('\n\n basic gcmfaces test: started... \n');
  gcmfaces_path;
  global mygrid; mygrid=[]; grid_load([gcmfaces_dir '/sample_input/GRIDv4/'],5);
  nameFld='DDetan'; tt=[53:78]*336; cc=[0 0.10];
  fld=rdmds2gcmfaces([gcmfaces_dir '/sample_input/SAMPLEv4/' nameFld],tt,5);
  fld=std(fld,[],3); msk=mygrid.hFacC(:,:,1); fld(find(msk==0))=NaN;
fprintf(' basic gcmfaces test: completed. \n\n');

if ~gcmfaces_skipplottest;

if gcmfaces_verbose;
fprintf('\n\n\n***********message from gcmfaces_init.m************\n ');
fprintf(' starting 1st example routine: plot_one_field ... \n');
end;

plot_one_field;

if gcmfaces_verbose;
fprintf('\n\n\n***********message from gcmfaces_init.m************\n ');
fprintf(' starting 2nd example routine: plot_std_field ... \n');
end;

plot_std_field;

end;

if gcmfaces_verbose;
fprintf('\n\n\n***********message from gcmfaces_init.m************\n ');
fprintf(' --- initialization of gcmfaces completed correctly \n');
fprintf(' --- you are all set and may now use the gcmfaces package \n');
fprintf(' --- eventually, to avoid running gcmfaces_init over again \n');
fprintf(' --- you may want to copy the gcmfaces_path.m code to your startup.m \n\n\n');
end;

