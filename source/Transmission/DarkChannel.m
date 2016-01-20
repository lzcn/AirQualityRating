function J_dark = DarkChannel(Image,patch_size)

half_window = floor(patch_size/2);
[row, cloumn, ~] = size(Image);
J_dark = zeros(row,cloumn);
Image = padarray(Image, [half_window half_window], 'symmetric');
for i = 1:row
    for j = 1:cloumn
        patch = Image(i:(i + 2*half_window),j:(j + 2*half_window),:);
        J_dark(i,j) = min(patch(:));
    end
end

