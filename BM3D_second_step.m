function [result] = BM3D_second_step(first_step,noise_img,bs,SW,sl,sigma)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
img_1=padarray(first_step,[SW SW],'both');
img_2=padarray(noise_img,[SW SW],'both');
bpr=SW*2+1; %这个bpr代表一个窗里面有几个block，SW*2+ws-ws+1;
center=bpr*SW+SW+1;
result=zeros(size(first_step));
bilibala=zeros(size(first_step));
for i=SW+1:bs:size(img_1,1)-SW-bs+1
    for j=SW+1:bs:size(img_1,2)-SW-bs+1
        %先从first中得到三维矩阵然后去算系数
        window_1=img_1(i-SW:i+SW+bs-1,j-SW:j+SW+bs-1);
        block_1=double(im2col(window_1,[bs bs],'sliding')); 
        disk_1=zeros(size(block_1,2),1);
        for h=1:size(block_1,2)
            temp=block_1(:,center)-block_1(:,h);
            disk_1(h,1)=norm(temp)^2;
        end
        [~,indcs_1]=sort(disk_1);
        indcs_1=indcs_1(1:sl);
        Z_1=zeros(bs,bs,sl);
        for h=1:sl
            Z_1(:,:,h)= reshape(block_1(:,indcs_1(h)),[bs bs]);
            Z_1(:,:,h)=dct2(Z_1(:,:,h));
        end
         for b =1:bs
            for k=1:bs
                Z_1(b,k,:)=fwht(squeeze(Z_1(b,k,:)));
            end
         end
         
         w=(sum(Z_1,'all'))^2/((sum(Z_1,'all'))^2+sigma*sigma);
         
         %然后去得到noise的三维矩阵
        window_2=img_2(i-SW:i+SW+bs-1,j-SW:j+SW+bs-1);
        block_2=double(im2col(window_2,[bs bs],'sliding')); 
        disk_2=zeros(size(block_2,2),1);
        for h=1:size(block_2,2)
            temp=block_2(:,center)-block_2(:,h);
            disk_2(h,1)=norm(temp)^2;
        end
        [~,indcs_2]=sort(disk_2);
        indcs_2=indcs_2(1:sl);
        Z_2=zeros(bs,bs,sl);
        for h=1:sl
            Z_2(:,:,h)= reshape(block_1(:,indcs_2(h)),[bs bs]);
            Z_2(:,:,h)=dct2(Z_2(:,:,h));
        end
         for b =1:bs
            for k=1:bs
                Z_2(b,k,:)=fwht(squeeze(Z_2(b,k,:)));
            end
         end
         
         Z_2=w*Z_2;
         
         for b =1:bs
            for k=1:bs
                Z_2(b,k,:)=ifwht(squeeze(Z_2(b,k,:)));
            end
         end         
        for h=1:sl
            Z_2(:,:,h)=idct2(Z_2(:,:,h));
        end
        
        W=1/(sigma*sigma*w*w);
        for k =1:sl
            result(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)= result(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)+Z_2(:,:,k)*W;
            bilibala(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)=bilibala(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)+W;
        end
    end
end
result=result./bilibala;        
end

