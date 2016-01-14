% Get the transimission of an image
% Using Dark channel Prior
% in "Single image Haze Remove Using Dark Channel Prior"
% T : the output of an image's transimission.
% Image: original image
function  Transmission = GetTransmission(Image)

max_image_size = 768;
patch_size = 9;

% scaling image
if max(size(Image)) > max_image_size
    scale = max_image_size / max(size(Image));
    Image = imresize(Image,scale);
end
Image = double(Image) ./ 255;

% Compute DarkChannel
J_dark = DarkChannel(Image,patch_size);
% Estimate Atmospheric Light
A = AtmosphericLight(Image,J_dark);
% Estimate the Transmission
Transmission = 1 - DarkChannel(Image./A,patch_size);