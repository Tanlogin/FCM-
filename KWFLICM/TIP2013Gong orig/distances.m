clear all%清除workspace中的所有变量
clc;%清楚命令窗口的内容
I=imread('syn3G30.bmp');%读入图像文件
dlmwrite('Result.txt',D);