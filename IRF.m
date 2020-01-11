close all;
clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 功能：计算IRF数据在某个面积比下的时间宽度
% 作者：毕瑜
% 输入：数据文件
% 输出：report.md
% 参数不合适产生的报错类型：
%   1. 选择的精度超过了实验数据精度报错，符合要求的数据量不足
%   2. 选择的y值或精度不合适，导致零点左侧没有数据
% 填写全局参数：
filename='32739.txt'; % 待导入的数据文件名称 
derive=0.05; % 设定相对精度,范围(0,1)
area_set=0.7; % 设定需要求解的面积所占百分比
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

% 新建文件夹及文件
status = mkdir(sprintf('%s-%.2f%%',filename,area_set*100));
cd(sprintf('%s-%.2f%%',filename,area_set*100));
fp=fopen('计算结果分析.md','w','n','UTF-8');
% 写入数据信息
fprintf(fp,'# %s_IRF数据_%.2f%%结果分析\n\n',filename,area_set*100);
fprintf(fp,'## 原始数据分布\n\n![](Unprocessed.png)\n\n');
fprintf(fp,'- 该文件共有%d组数据\n\n',m);
fprintf(fp,'- 零点(0,1)为第%d组数据\n\n',middle);
fprintf(fp,'- 半高全宽FWHM为%.3fps\n\n',FWHM);

set(figure(1),'visible','off');
% figure(1)
plot(x, y);
xlabel("时间/ps");
ylabel("Photon");
title("IRF分布");
print(1,'-dpng','Unprocessed.png')% 保存为png格式

% 直接y值相加
area=0;
for j=(1:m)
    area=area+y(j);
end

% 梯形数值积分（可选）
%area=trapz(x,y);


%%%%%%%% 面积变化过程 %%%%%%%%
fprintf(fp,'## 分析原始数据误差\n\n');
% 可调整参数
precise=0.001;
begin=0;
finish=1;

fprintf(fp,'以步长**%.4f**，将y值从起始值**%.4f**到结束值**%.4f**遍历一遍求对应面积所占百分比。\n\n',precise,begin,finish);
fprintf(fp,'- 每条$y=y_0$直线与IRF分布曲线将有两交点\n\n- 图中横坐标为这两点面积占总面积之比，纵坐标为这两点的时间宽度\n\n');
fprintf(fp,'- 显然y值越小，两交点的时间宽度越大，对应的面积越大。\n\n');

r=0;%下标
area_dis=[];
x_dis=[];
area_prec=Inf;

for ytmp=(begin:precise:finish)
    % 找到对应ytmp值相等的两点 
    sectmp=[];
    k=0;% 下标
    i=1;
    while(i<=m)
        if abs(y(i)-ytmp) < ytmp*derive        
            k=k+1;
            sectmp(k)=i;
        end
        i=i+1;
    end

    % 参数不合适直接continue  
    if k<2
        continue
    elseif sectmp(1)>middle
       continue
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

    % 直接y值相加
    areatmp=0;
    for i=(sec(1):sec(2))
        areatmp=areatmp+y(i);
    end 
    r=r+1;
    area_dis(r)=areatmp/area;
    x_dis(r)=x(sec(2))-x(sec(1));
    
    % 判断是否是最接近设定面积百分比的ytmp，并存储相关信息
    if abs(area_dis(r)-area_set) < area_prec
        area_prec = abs(area_dis(r)-area_set);
        area_re = area_dis(r); % 对应面积所占百分比
        sec_re=[]; % 所求时间宽度对应的两点
        sec_re(1)=sec(1);
        sec_re(2)=sec(2);
        y_re=ytmp; % 所求时间宽度对应的y值
    end
end
figure(2)
plot(area_dis,x_dis);
hold on;
x_1=[];
for i=(1:r)
    x_1(i)=area_set;
end
plot(x_1,x_dis);
xlabel('面积所占百分比');
ylabel('时间宽度/ps');
legend('时间宽度随面积的变化曲线',sprintf('x=%.4f',area_set));
title('时间宽度随面积的变化');
print(2,'-dpng','Distribution.png');

fprintf(fp,'![](Distribution.png)');
fprintf(fp,'该曲线**斜率越大**，说明该面积所占百分比处，时间宽度变化太快，**误差可能超出实验精度**。\n\n');
fprintf(fp,'> 修改程序中的 `precise`，`begin`，`finish` 分别可自定义步长、起始值、结束值。\n\n');

%%%%%%%% 设定一个具体y值 %%%%%%%%
%{
ytmp=0.033;
sectmp=[];
k=0;% 下标
i=1;
while(i<=m)
    if abs(y(i)-ytmp) < ytmp*derive       
        k=k+1;
        sectmp(k)=i;
    end
    i=i+1;
end

% 参数不合适产生的报错
error=0;
if k<2
    display(sprintf('选择的精度过小，超过了实验数据精度，符合要求的数据仅%d组',k));
    error=1;
elseif sectmp(1)>middle
    display('选择的y值或精度不合适，导致零点左侧没有数据')
    error=2;
end
if error >0
    fprintf(fp,"> **参数不合适产生报错！！！**\n报错类型：%d",error);
    cd('..');
    return;
end

% 取左右最靠近零点的两点
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

% 直接y值相加
areatmp=0;
for j=(sec(1):sec(2))
    areatmp=areatmp+y(j);
end
area_re=areatmp/area;
%}

%%%%%%%% 画图：离设定面积比最近的值 %%%%%%%%
fprintf(fp,'## 计算%.2f%%面积对应时间宽度\n\n',area_set*100);
fprintf(fp,'根据上图，判断所求的面积百分比误差是否已经超过测量精度；\n\n如果对应的斜率较平缓，则以下求出的时间宽度误差较小。\n\n');

figure(3)
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
y_1=[];
for i=(sec_re(1):sec_re(2))
    y_1(i)=y_re;
end
plot(x_1(1:sec_re(1)),y(1:sec_re(1)));
plot(x_2(sec_re(2):m),y(sec_re(2):m));
plot(x(sec_re(1):sec_re(2)),y_1(sec_re(1):sec_re(2)));
xlabel("时间/ps");
ylabel("Photon");
legend('截取的IRF分布',sprintf('x=%.3f',x(sec_re(1))),sprintf('x=%.3f',x(sec_re(2))),sprintf('y=%f',y_re));
title(sprintf('%.2f%%的IRF分布',area_set*100));
print(3,'-dpng','Result.png');
fprintf(fp,'![](result.png)\n\n');

fprintf(fp,"取曲线上y=%.4f处的两点分别为\n\n",y_re);
fprintf(fp,"- 第%d组数据 `(%.3f,%.6f)`\n\n",sec_re(1),x(sec_re(1)),y(sec_re(1)));
fprintf(fp,"- 第%d组数据 `(%.3f,%.6f)`\n\n",sec_re(1),x(sec_re(2)),y(sec_re(2)));

% 计算时间宽度
width=x(sec_re(2))-x(sec_re(1));
display("与总面积的比值为"+num2str(area_re)+"时，时间宽度为"+num2str(width)+"ps")
fprintf(fp,"**结论：与总面积的比值%.3f%%时，时间宽度为%.3fps。**\n\n",area_re*100,width);
fclose(fp);
cd('..');


