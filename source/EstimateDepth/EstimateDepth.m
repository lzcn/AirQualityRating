function [match1,match2] = EstimateDepth(im1,im2)
patchsize = 15;
im1 = double(rgb2gray(im1));
im2 = double(rgb2gray(im2));
im1_col = im2col(im1,[patchsize,patchsize]);
mean_im1 = mean(im1_col);
std_im1 = std(im1_col);
im1_col = (im1_col - repmat(mean_im1,[patchsize*patchsize,1]))./repmat(std_im1,[patchsize*patchsize,1]);
im2_col = im2col(im2,[patchsize,patchsize]);
mean_im2 = mean(im2_col);
std_im2 = std(im2_col);
im2_col = (im2_col - repmat(mean_im2,[patchsize*patchsize,1]))./repmat(std_im2,[patchsize*patchsize,1]);
match1 = zeros(1,length(im1_col));
match2 = zeros(1,length(im2_col));
parfor i = 1:length(im1_col)
    tmp = repmat(im1_col(:,i),[1,length(im2_col)]);
    nssd = sum(((tmp - im2_col).^2),2);
    if min(nssd) < 0.1* max(nssd);
        [~,p] = min(nssd);
        match1(i) = p;
    end
end