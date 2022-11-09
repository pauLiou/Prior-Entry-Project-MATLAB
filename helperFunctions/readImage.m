function img = readImage(filePath, color)
%Return image matrix with alpha channel

if (color == 1)
    filePath = [filePath '_white'];
end

[img, ~, alpha] = imread(filePath,'png');
img = cat(3, img, alpha);

end