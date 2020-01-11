close all;
clear;
clc;
% ��дȫ�ֲ�����
filename='32739.txt'; % ������������ļ����� 
derive=0.05; % �趨��Ծ���,��Χ(0,1)
area_set=0.98; % �趨��Ҫ���������ռ�ٷֱ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% ��ʼ�� %%%%%%%%
M=importdata(filename);
[m,n]=size(M); % mΪ���ݸ���
x=M(:,1);
y=M(:,2);
middle=0;

% ����ȫ��
sectmp=[];k=0;
for i=(1:m)
    if x(i)==0
        middle=i; % middleΪ���������±�
    end
    if abs(y(i)-0.5)<0.5*derive
        k=k+1;
        sectmp(k)=i;
    end
end
% ���Ҹ�ȡһ��������ĵ�sec(1)��sec(2)
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

FWHM=sec(2)-sec(1); % FWHMΪ���ȫ��

% ֱ��yֵ���
area=0; % �����
for j=(1:m)
    area=area+y(j);
end

% �����Ѱ�����1%�ĵ�
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
% ���ұ�Ѱ�����1%�ĵ�
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

%������
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

xlabel("ʱ��/ps");
ylabel("Photon");
legend('��ȡ��IRF�ֲ�',sprintf('x=%.3f',x(sec_re(1))),sprintf('x=%.3f',x(sec_re(2))));
title(sprintf('%.2f%%��IRF�ֲ�',area_set*100));

% ����ʱ����
width=x(sec_re(2))-x(sec_re(1));
display("��������ı�ֵΪ"+num2str(1-area_left-area_right)+"ʱ��ʱ����Ϊ"+num2str(width)+"ps")
display("�������Ϊ"+sec_re(1)+"��"+sec_re(2));

