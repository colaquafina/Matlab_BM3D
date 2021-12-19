function [result] = BM3D_first_step(input_img,bs,SW,ht,sl,sigma)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
img=padarray(input_img,[SW SW],'both');
bpr=SW*2+1; %这个bpr代表一个窗里面有几个block，SW*2+ws-ws+1;
center=bpr*SW+SW+1;
result=zeros(size(input_img));
bilibala=zeros(size(input_img));
%改了一点坐标
for i=SW+1:bs:size(img,1)-SW-bs+1
    for j=SW+1:bs:size(img,2)-SW-bs+1
        window=img(i-SW:i+SW+bs-1,j-SW:j+SW+bs-1);
        block=double(im2col(window,[bs bs],'sliding')); 
        disk=zeros(size(block,2),1);
        for h=1:size(block,2)
            temp=block(:,center)-block(:,h);
            disk(h,1)=norm(temp)^2;
        end
        [~,indcs]=sort(disk);
        indcs=indcs(1:sl);
        Z=zeros(bs,bs,sl);
 
        for h=1:sl
            Z(:,:,h)= reshape(block(:,indcs(h)),[bs bs]);
            Z(:,:,h)=dct2(Z(:,:,h));
        end 
        for b =1:bs
            for k=1:bs 
                Z(b,k,:)=fwht(squeeze(Z(b,k,:)),sl);
            end
        end
        Z=wthresh(Z,'h',ht);
        wZ=zeros(sl,1);
        for b=1:sl
            tem=0;
            for k=1:bs
                for h=1:bs
                    if(Z(k,h,b)~=0)
                        tem=tem+1;
                    end
                end
            end
            if(tem>=1)
                wZ(b,1)=1/(tem*tem*sigma*sigma);
            else
                wZ(b,1)=1;
            end
        end
        
        for b =1:bs
            for k=1:bs
                Z(b,k,:)=ifwht(squeeze(Z(b,k,:)),sl);
            end
        end
        for h=1:sl
            Z(:,:,h)=idct2(Z(:,:,h));
        end
        
        for k =1:sl
            result(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)= result(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)+Z(:,:,k)*wZ(k,1)*sigma*sigma;
            bilibala(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)=bilibala(i-SW:i-SW+bs-1,j-SW:j-SW+bs-1)+wZ(k,1)*sigma*sigma;
        end
    end
end

result=result./bilibala;

end

