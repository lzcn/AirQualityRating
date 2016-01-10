% funtion to get the featch of q_alpha
function q = q_alpha(im)
% compute the global alpha
alpha_global = PowerSpectrumSlope(im);
[row, col ,~] = size(im);
rr = floor(row/16);
cc = floor(col/16);
idx=1;
q = zeros(rr*cc,1);
for i =1:rr
    for j = 1:cc
        rown = (16*(i-1)+1):16*i;
        coln = (16*(j-1)+1):16*j;
        im_patch = im(rown,coln,:);
        alpha_g = PowerSpectrumSlope(im_patch);
        q(idx) = (alpha_g - alpha_global)/(alpha_global);
        idx =idx+1;
    end
end
% patch size = 17;
% half_patch = 8;
% pImage = padarray(im,[half_patch,half_patch],'symmetric');
% % compute the local alpha and the metric q_alpha
% [row, col ,~] = size(im);
% q = zeros(row,col);
% for i = 1:row
%     for j = 1:col
%         row_n = i + 2*half_patch;
%         col_n = j + 2*half_patch;
%         im_patch = pImage(i:row_n,j:col_n,:);
%         alpha_g = PowerSpectrumSlope(im_patch);
%         q(i,j) = (alpha_g - alpha_global)/(alpha_global);
%     end
% end
