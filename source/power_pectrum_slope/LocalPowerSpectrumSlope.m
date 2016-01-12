% LocalPowerSpectrumSlope -- To measure the spectrum property for blur
%
%   Paras: 
%   @im        : Input grayscale image.
%   @patchsize : Parameter controlling local patch size.
%
%   The Code is created based on the method described in the following paper 
%   [1] "Discriminative Blur Detection Features", Jianping Shi, Li Xu, Jiaya Jia,
%       IEEE Conference on Computer Vision and Pattern Recognition, 2014. 
%   The code and the algorithm are for non-comercial use only.
%  
%   Author: Jianping Shi (jpshi@cse.cuhk.edu.hk)
%   Date  : 03/27/2014
%   Version : 1.0 
%   Copyright 2014, The Chinese University of Hong Kong.

function q = LocalPowerSpectrumSlope(im, patchsize)
if size(im,3) ==3
    im = rgb2gray(im);
end
im = im2double(im);
[im_height, im_width] = size(im);
% global pss 
[lf_g,lC_g] = GenerateF(size(im,1)/2,size(im,2)/2);
lC_log_g = log(lC_g);
lC_log_new_g = unique(round(lC_log_g / 0.2)*0.2);
lsf_g = GenerateSf(im,lf_g,lC_g,size(im,1)/2,size(im,2)/2);
lsf_new_g = rearrange(lC_log_g, lC_log_new_g, lsf_g);
lsf_new_g = log(lsf_new_g(1:end-1));
idx = ~(isnan(lsf_new_g) + isinf(lsf_new_g));   
alf_local_g = sum(lsf_new_g(idx))/numel(lsf_new_g(idx));
% local pss
offset = (patchsize - 1)/2;
[lf, lC] = GenerateF(offset, offset);
lC_log = log(lC);
lC_log_new = unique(round(lC_log / 0.2)*0.2);

im_col = im2col(im, [patchsize, patchsize]);
im_col = bsxfun(@rdivide, im_col, sum(im_col));
q = zeros(1, size(im_col,2));
parfor i = 1:size(im_col,2)
    lsf = GenerateSf(reshape(im_col(:,i), [patchsize, patchsize]), lf, lC, offset, offset);
    lsf_new = rearrange(lC_log, lC_log_new, lsf);
    lsf_new = log(lsf_new(1:end-1));
    idx = ~(isnan(lsf_new) + isinf(lsf_new));   
    alf_local = sum(lsf_new(idx))/numel(lsf_new(idx));
    q(i) = alf_local;
end
q = reshape(q, [im_height-patchsize+1, im_width-patchsize+1]);
q = padarray(q, [offset, offset], 'replicate');
q = (q - alf_local_g)/alf_local_g;


function [f, C] = GenerateF(height, width)
kheight = 1:height;
kwidth = 1:width;
[u,v] = meshgrid(kwidth, kheight);
[~, f]=cart2pol(u,v);
f = round(f);
C = unique(f);

% Power Spectrum Slope
function sf=GenerateSf(im, f, C, half_height, half_width)
[height,width] = size(im);
s = abs(fft2(im, height, width));
s = s(1:half_height,1:half_width).^2/half_height/half_width;
sf = calculateSf(s, C, f);


function data = rearrange(C, C_new, f)
data = zeros(size(C_new));
idx = 0;
for i = 1:length(f)
    if(C(i) >= C_new(idx+1))
        idx = idx+1;
    end
    data(idx) = data(idx)+f(i);
end