clear;
clc;

% Load an example image 
I = double(imread('man.jpg')) / 255;
G = I;

k = 3; %  k*k patch
iter = 5;

SuperpixelNum = floor((size(I,1)*size(I,2)/256));
eps = 0.2 ^ 2;

Q = SuperixelGuidedFilter(I, G, k, iter, SuperpixelNum, eps);

figure;
set(gcf, 'Name', 'Guided Filtering combining Superpixels and Patch Shift Result');
 
subplot(1,2,1); imshow(I);
title('Input Image'); 

subplot(1,2,2); imshow(Q);
title('Result of Superpixel and Patch Shift Guided Filtering');