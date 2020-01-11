close all;
clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ܣ�����IRF������ĳ��������µ�ʱ����
% ���ߣ����
% ���룺�����ļ�
% �����report.md
% ���������ʲ����ı������ͣ�
%   1. ѡ��ľ��ȳ�����ʵ�����ݾ��ȱ�������Ҫ�������������
%   2. ѡ���yֵ�򾫶Ȳ����ʣ�����������û������
% ��дȫ�ֲ�����
filename='32739.txt'; % ������������ļ����� 
derive=0.05; % �趨��Ծ���,��Χ(0,1)
area_set=0.7; % �趨��Ҫ���������ռ�ٷֱ�
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

% �½��ļ��м��ļ�
status = mkdir(sprintf('%s-%.2f%%',filename,area_set*100));
cd(sprintf('%s-%.2f%%',filename,area_set*100));
fp=fopen('����������.md','w','n','UTF-8');
% д��������Ϣ
fprintf(fp,'# %s_IRF����_%.2f%%�������\n\n',filename,area_set*100);
fprintf(fp,'## ԭʼ���ݷֲ�\n\n![](Unprocessed.png)\n\n');
fprintf(fp,'- ���ļ�����%d������\n\n',m);
fprintf(fp,'- ���(0,1)Ϊ��%d������\n\n',middle);
fprintf(fp,'- ���ȫ��FWHMΪ%.3fps\n\n',FWHM);

set(figure(1),'visible','off');
% figure(1)
plot(x, y);
xlabel("ʱ��/ps");
ylabel("Photon");
title("IRF�ֲ�");
print(1,'-dpng','Unprocessed.png')% ����Ϊpng��ʽ

% ֱ��yֵ���
area=0;
for j=(1:m)
    area=area+y(j);
end

% ������ֵ���֣���ѡ��
%area=trapz(x,y);


%%%%%%%% ����仯���� %%%%%%%%
fprintf(fp,'## ����ԭʼ�������\n\n');
% �ɵ�������
precise=0.001;
begin=0;
finish=1;

fprintf(fp,'�Բ���**%.4f**����yֵ����ʼֵ**%.4f**������ֵ**%.4f**����һ�����Ӧ�����ռ�ٷֱȡ�\n\n',precise,begin,finish);
fprintf(fp,'- ÿ��$y=y_0$ֱ����IRF�ֲ����߽���������\n\n- ͼ�к�����Ϊ���������ռ�����֮�ȣ�������Ϊ�������ʱ����\n\n');
fprintf(fp,'- ��ȻyֵԽС���������ʱ����Խ�󣬶�Ӧ�����Խ��\n\n');

r=0;%�±�
area_dis=[];
x_dis=[];
area_prec=Inf;

for ytmp=(begin:precise:finish)
    % �ҵ���Ӧytmpֵ��ȵ����� 
    sectmp=[];
    k=0;% �±�
    i=1;
    while(i<=m)
        if abs(y(i)-ytmp) < ytmp*derive        
            k=k+1;
            sectmp(k)=i;
        end
        i=i+1;
    end

    % ����������ֱ��continue  
    if k<2
        continue
    elseif sectmp(1)>middle
       continue
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

    % ֱ��yֵ���
    areatmp=0;
    for i=(sec(1):sec(2))
        areatmp=areatmp+y(i);
    end 
    r=r+1;
    area_dis(r)=areatmp/area;
    x_dis(r)=x(sec(2))-x(sec(1));
    
    % �ж��Ƿ�����ӽ��趨����ٷֱȵ�ytmp�����洢�����Ϣ
    if abs(area_dis(r)-area_set) < area_prec
        area_prec = abs(area_dis(r)-area_set);
        area_re = area_dis(r); % ��Ӧ�����ռ�ٷֱ�
        sec_re=[]; % ����ʱ���ȶ�Ӧ������
        sec_re(1)=sec(1);
        sec_re(2)=sec(2);
        y_re=ytmp; % ����ʱ���ȶ�Ӧ��yֵ
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
xlabel('�����ռ�ٷֱ�');
ylabel('ʱ����/ps');
legend('ʱ����������ı仯����',sprintf('x=%.4f',area_set));
title('ʱ����������ı仯');
print(2,'-dpng','Distribution.png');

fprintf(fp,'![](Distribution.png)');
fprintf(fp,'������**б��Խ��**��˵���������ռ�ٷֱȴ���ʱ���ȱ仯̫�죬**�����ܳ���ʵ�龫��**��\n\n');
fprintf(fp,'> �޸ĳ����е� `precise`��`begin`��`finish` �ֱ���Զ��岽������ʼֵ������ֵ��\n\n');

%%%%%%%% �趨һ������yֵ %%%%%%%%
%{
ytmp=0.033;
sectmp=[];
k=0;% �±�
i=1;
while(i<=m)
    if abs(y(i)-ytmp) < ytmp*derive       
        k=k+1;
        sectmp(k)=i;
    end
    i=i+1;
end

% ���������ʲ����ı���
error=0;
if k<2
    display(sprintf('ѡ��ľ��ȹ�С��������ʵ�����ݾ��ȣ�����Ҫ������ݽ�%d��',k));
    error=1;
elseif sectmp(1)>middle
    display('ѡ���yֵ�򾫶Ȳ����ʣ�����������û������')
    error=2;
end
if error >0
    fprintf(fp,"> **���������ʲ�����������**\n�������ͣ�%d",error);
    cd('..');
    return;
end

% ȡ���������������
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

% ֱ��yֵ���
areatmp=0;
for j=(sec(1):sec(2))
    areatmp=areatmp+y(j);
end
area_re=areatmp/area;
%}

%%%%%%%% ��ͼ�����趨����������ֵ %%%%%%%%
fprintf(fp,'## ����%.2f%%�����Ӧʱ����\n\n',area_set*100);
fprintf(fp,'������ͼ���ж����������ٷֱ�����Ƿ��Ѿ������������ȣ�\n\n�����Ӧ��б�ʽ�ƽ���������������ʱ��������С��\n\n');

figure(3)
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
y_1=[];
for i=(sec_re(1):sec_re(2))
    y_1(i)=y_re;
end
plot(x_1(1:sec_re(1)),y(1:sec_re(1)));
plot(x_2(sec_re(2):m),y(sec_re(2):m));
plot(x(sec_re(1):sec_re(2)),y_1(sec_re(1):sec_re(2)));
xlabel("ʱ��/ps");
ylabel("Photon");
legend('��ȡ��IRF�ֲ�',sprintf('x=%.3f',x(sec_re(1))),sprintf('x=%.3f',x(sec_re(2))),sprintf('y=%f',y_re));
title(sprintf('%.2f%%��IRF�ֲ�',area_set*100));
print(3,'-dpng','Result.png');
fprintf(fp,'![](result.png)\n\n');

fprintf(fp,"ȡ������y=%.4f��������ֱ�Ϊ\n\n",y_re);
fprintf(fp,"- ��%d������ `(%.3f,%.6f)`\n\n",sec_re(1),x(sec_re(1)),y(sec_re(1)));
fprintf(fp,"- ��%d������ `(%.3f,%.6f)`\n\n",sec_re(1),x(sec_re(2)),y(sec_re(2)));

% ����ʱ����
width=x(sec_re(2))-x(sec_re(1));
display("��������ı�ֵΪ"+num2str(area_re)+"ʱ��ʱ����Ϊ"+num2str(width)+"ps")
fprintf(fp,"**���ۣ���������ı�ֵ%.3f%%ʱ��ʱ����Ϊ%.3fps��**\n\n",area_re*100,width);
fclose(fp);
cd('..');


