function q = q_cpbd(im)
% compute the local alpha and the metric q_alpha
[N, M ,~] = size(im);
% seperate the image to patches with size of 16*16
row_n = floor(N/64);
col_m = floor(M/64);
q = zeros(row_n*col_m,1);
idx = 1;
for i = 1:row_n
    for j = 1:col_m
        row = 64*(i-1)+1:64*i;
        col = 64*(j-1)+1:64*j;
        im_patch = im(row,col,:);
        q(idx) = CPBD_compute(im_patch);
        idx = idx + 1;
    end
end