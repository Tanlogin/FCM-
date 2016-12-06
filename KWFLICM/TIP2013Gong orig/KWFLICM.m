clear all%���workspace�е����б���
clc;
I=imread('brain_20_RN20.bmp');%����ͼ���ļ�
% [counts,x]=imhist(I);%�Ҷ�ͳ��
% figure(1);
% imhist(I);
[m,n,h]=size(I);%��ͼ��Ĵ�С
if h~=1
    I=rgb2gray(I);
end
figure(1);
imshow(I);title('ԭͼ��');
% I=imnoise(I,'salt & pepper',0.03);
% I=imnoise(I,'gaussian',0,0.03);
% figure(2);           
% imshow(I);title('����ͼ��'); %��ʾԭ����ͼ��
% imwrite(I,'0.03_gaussian_four.bmp');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c=3;          %�������
e=0.01;
V1=zeros(1,c);     %V1�Ǿɵľ�������
V2=zeros(1,c);     %V2���µľ�������
UU1=zeros(m,n);
UU2=zeros(m,n);
UU3=zeros(m,n);
UU4=zeros(m,n);
U1=cell(m,n);
m1=2;              %ȷ����Ȩָ��m
I1=I;
[U1,V1]=Initialization(I1,c);
count=0;         %ѭ������
flag=1;
w=2.0;
I1=double(I1);     %ת������������
%%%%%%%%%%%%%%%%%%%%%%%%%��ʼ�����%%%%%%%%%%%%%%%%%%%%%%
[C]=calculateC(I1,w);%���ڷ����ֵ��
%%%%%%%%%%%%%%%%%%%%%%%%%%����%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;%tic1 
t1=clock; 
while (flag==1&&count<500)
    tic ;%tic2 
    t2=clock; 
    pause(3*rand) 
    
    [D1]=Distance(V1,c,I1);
    [G1,U1]=calculateG(U1,D1,I1,m1,c,C);%����G����������Ⱦ���c*(m*n��)
    V2=center(U1,c,m1,I1,D1);
    count=count+1;
     for i=1:m
         for j=1:n
             for k=1:c
                 costfunction(count)=U1{i,j}(k,1)^m1*(1-D1{i,j}(k,1))+G1{i,j}(k,1)*U1{i,j}(k,1)^m1;
             end
         end
     end
    fprintf('iter.count = %d, obj. fcn = %f\n',count, costfunction(count));
    if max(abs(V2-V1))<e;%����ֹͣ����
        flag=0;
    else
        V1=V2;
    end
   %disp(sprintf('Iterations = %d',count));
   %����ÿ��ѭ����ʱ�� 
    disp(['etime�����',num2str(count),'��ѭ������ʱ�䣺',num2str(etime(clock,t2))]); 
end
%�������е���ʱ��
disp(['etime����������ʱ�䣺',num2str(etime(clock,t1))]);

vpc=0; vpe=0;

for i=1:m
    for j=1:n
        for k=1:c
            vpc=vpc+U1{i,j}(k,1)^2;
            if U1{i,j}(k,1)>0
                vpe=vpe+log2(U1{i,j}(k,1))*U1{i,j}(k,1);
            end
        end
    end
end
for i=1:m
    for j=1:n
        UU1(i,j)=U1{i,j}(1,1);
    end
end
for i=1:m
    for j=1:n
        UU2(i,j)=U1{i,j}(2,1);
    end
end
for i=1:m
    for j=1:n
        UU3(i,j)=U1{i,j}(3,1);
    end
end
%for i=1:m
 %   for j=1:n
 %      UU4(i,j)=U1{i,j}(4,1);
 %  end
%end
vpc=vpc/(m*n);
vpe=-vpe/(m*n);

fprintf('vpc=%.4f, vpe=%.4f\n',vpc,vpe);

[I2,I3]=defuzzy(U1,I,V2);%ȥģ��������ԭʼͼ����б��

%%%%%%%%%%%%%%%%%%%%%��ʾ�ָ���%%%%%%%%%%%%%%%%%%%%%
figure(3);
I3=uint8(I3);   % ת��Ϊ�޷��������� 8��ʾ8λ����������  ��Χ0~255
imshow(I3);title('�ָ���ͼ��');   %��ʾ�ָ���ͼ��
% imwrite(I3,'result_four.bmp');