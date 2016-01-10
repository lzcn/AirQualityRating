function C = Contrast(im)
if size(im,3)~=1
    im = rgb2gray(im);
end
[m,n] = size(im);
im = double(im);
C = zeros(m,n);
pImage = padarray(im,[2,2],'symmetric');
for i = 1:m
    for j = 1:n
        sumF = 0;
        sumL = 0;
        for ii = i:i+4
            for jj = j:j+4
                sumF = sumF + pImage(ii,jj)^2;
                sumL = sumL + pImage(ii,jj);
            end
        end
        C(i,j) = 25*sumF - sumL^2;
        C(i,j) = (C(i,j)/125)^0.5;
    end
end