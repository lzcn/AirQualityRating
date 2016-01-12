function normed_satu = LocalSaturation(im)
hsv_im = rgb2hsv(im);
satu_im = hsv_im(:,:,2);
[n, m, ~]=size(satu_im);
normed_satu = zeros(n,m);
satu_max = max(max(satu_im));
satu_min = min(min(satu_im));
for i =1:n
    for j = 1:m
        normed_satu(i,j) = (satu_im(i,j)-satu_min)/(satu_max-satu_min);
    end
end