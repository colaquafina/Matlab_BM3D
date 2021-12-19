% first define the parameters 先定义参数
bs=8; %block size
sw=12; %searching window, the 12 means the distance between the edges of the window and the size.
%       这里的12的意思是在block外面补一个长为12的圈。所以总的searching window就是32*32.
sigma=0.25;%this is the std of the gaussian noise.这是加的高斯噪音的标准差。
ht=2.7;  %the threshold value of the first step.第一步的硬阈值
sl=64;
lambda2=1;%the λ2D in the paper

% import the image 
org_img = (imread('lena.jpg'));
org_img=rgb2gray(org_img);
org_img=org_img(400:799,400:799);
noise_img=imnoise(org_img,'gaussian',0,sigma*sigma);
figure(1)
colormap(gray);
imagesc(noise_img);axis('equal');axis('image')

figure(2)
colormap(gray);
first_step=BM3D_first_step(noise_img,bs,sw,ht,sl,sigma);
imagesc(first_step(1:end-7,1:end-7));axis('equal');axis('image')



bs_2=8;
sw_2=12;
sl_2=64;
second_step=BM3D_second_step(first_step,noise_img,bs_2,sw_2,sl_2,sigma);
figure(3)
colormap(gray)
imagesc(second_step);axis('equal');axis('image')

first_step=uint8(first_step);
second_step=uint8(second_step);

psnr(noise_img,org_img)
psnr(first_step(1:end,1:end),org_img(1:end,1:end))
psnr(second_step(1:end,1:end),org_img(1:end,1:end))






