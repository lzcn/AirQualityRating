% Estimates the atmospheric light 
% and save the lightest pixel in a matrx AtmosL, the same size of Image 
function AtmosL = AtmosphericLight(Image,J_dark)
[row,cloumn] = size(J_dark); 
Top_Num = ceil(0.001 * row * cloumn ); 
% sort dark channel getting the top 0.1%
[~,Index] = sort(J_dark(:),'descend');
%Lightest Intensity A
A = zeros(1,1,3);
temp = 0;
for i = 1:Top_Num
    % check every point(m,n) in top 0.1%
    x = mod(Index(i)-1,row) + 1; % row
    y = floor((Index(i)-1)/row) + 1; %cloumn
    Intensity = 0.30*Image(x,y,1)+0.59*Image(x,y,2)+0.21*Image(x,y,3);
    if Intensity > temp
        A = Image(x,y,:);
        temp  = Intensity;
    end
end
% Atmospheric Light
AtmosL = zeros(row,cloumn,3);
for i = 1:3
    AtmosL(:,:,i) = AtmosL(:,:,i) + A(:,:,i);
end