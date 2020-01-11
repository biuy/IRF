close all;
clear;
clc;
% 填写全局参数：
filename='32739.txt'; % 待导入的数据文件名称 
derive=0.05; % 设定相对精度,范围(0,1)
area_set=0.98; % 设定需要求解的面积所占百分比
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% 初始化 %%%%%%%%
M=importdata(filename);
[m,n]=size(M); % m为数据个数
x=M(:,1);
y=M(:,2);
middle=0;

% 求半高全宽
sectmp=[];k=0;
for i=(1:m)
    if x(i)==0
        middle=i; % middle为零点的数组下标
    end
    if abs(y(i)-0.5)<0.5*derive
        k=k+1;
        sectmp(k)=i;
    end
end
% 左右各取一个最靠近零点的点sec(1)和sec(2)
sec=[0,0];
for i=(1:k)
    if sectmp(i)<middle
        if sec(1)<sectmp(i)
            sec(1)=sectmp(i);
        end
    else
        if sec(2)<sectmp(i)
            sec(2)=sectmp(i);
        end
    end
end

FWHM=sec(2)-sec(1); % FWHM为半高全宽

% 直接y值相加
area=0; % 总面积
for j=(1:m)
    area=area+y(j);
end

% 从左边寻找面积1%的点
sec_re=[];
for i=(1:middle)
    areatmp=0;
    for j=(1:i)
        areatmp=areatmp+y(j);
    end
    if abs(areatmp/area-(1-area_set)/2) < areatmp/area*derive
        sec_re(1)=i;
        area_left=areatmp/area;
        break;
    end
end
% 从右边寻找面积1%的点
for i=(m:-1:middle)
    areatmp=0;
    for j=(m:-1:i)
        areatmp=areatmp+y(j);
    end
    if abs(areatmp/area-(1-area_set)/2) < areatmp/area*derive
        sec_re(2)=i;
        area_right=areatmp/area;
        break;
    end
end

figure(1)
plot(x(sec_re(1):sec_re(2)),y(sec_re(1):sec_re(2)));
hold on;

%辅助线
x_1=[];
for i=(1:sec_re(1))
    x_1(i)=x(sec_re(1));
end
x_2=[];
for i=(sec_re(2):m)
    x_2(i)=x(sec_re(2));
end

plot(x_1(1:sec_re(1)),y(1:sec_re(1)));
plot(x_2(sec_re(2):m),y(sec_re(2):m));

xlabel("时间/ps");
ylabel("Photon");
legend('截取的IRF分布',sprintf('x=%.3f',x(sec_re(1))),sprintf('x=%.3f',x(sec_re(2))));
title(sprintf('%.2f%%的IRF分布',area_set*100));

% 计算时间宽度
width=x(sec_re(2))-x(sec_re(1));
display("与总面积的比值为"+num2str(1-area_left-area_right)+"时，时间宽度为"+num2str(width)+"ps")
display("数据序号为"+sec_re(1)+"和"+sec_re(2));

