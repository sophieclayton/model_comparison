% script to calculate the difference in the proportion of k and r adapted species between the coarse resolution and eddy permitting model runs, with the eddy permitting run output interpolated to the coarse grid

indircr=['coarse_res'];
indirhr=['high_res'];
subdircr=['kr.cr'];
subdirhr=['kr.hr'];
infilehr=['kr_hr'];
infilecr=['intr.kr'];

for year=1994:1999;
fcr=sprintf('%s/%s/%s.%04d.bin',indircr,subdircr,infilecr,year);
kr_coarse=readbin(fcr,[160 360 2]);

fhr=sprintf('%s/%s/%s.%04d.data',indirhr,subdirhr,infilehr,year);
kr_high=readbin(fhr,[360 160 2]);
kr_high=permute(kr_high,[2 1 3]);

diff_k(:,:)=kr_high(:,:,1)-kr_coarse(:,:,1);
diff_r(:,:)=kr_high(:,:,2)-kr_coarse(:,:,2);

out_diff(:,:,1)=diff_k;
out_diff(:,:,2)=diff_r;

% write the data out to a bin file, [160 360 2], with the k and the r difference
outfile=['kr.diff'];
fo=sprintf('%s.%04d.bin',outfile,year);
fid=fopen(fo,'w','b');
fwrite(fid,out_diff,'float32');
fclose(fid);

end
