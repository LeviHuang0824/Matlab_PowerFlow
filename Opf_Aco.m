clear all; 
close all;
clc; 
tic;
%演算法參數設定
Ant_Quantity = 70;                   %螞蟻個數
NC_max = 500;                        %最大迭代次數
Rho = 0.1;                       %費洛蒙衰減參數
P0 = 0.1;                              %轉移常數
step = 0.1;                          %局部搜索步長

%懲罰係數
PgPF=1000;
QgPF=1000;
VlPF=10000000;
SgPF=1000;

% Busdata
basemva = 100;  accuracy = 0.001; accel = 1.8; maxiter = 200;

%        IEEE 30-BUS TEST SYSTEM (American Electric Power)
%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MrW   Mva  Qmin  Qmax    +Qc/-Ql
busdata=[1   1    1.06    0.0     0.0   0.0    0.2 -16.1 -20 200       0
         2   2    1.043   0.0   21.70  12.7   40.0  50.0 -20 100       0
         3   0    1.021   0.0     2.4   1.2    0.0   0.0   0   0       0
         4   0    1.012   0.0     7.6   1.6    0.0   0.0   0   0       0
         5   2    1.01    0.0    94.2  19.0    0.0  37.0 -15  80       0
         6   0    1.01    0.0     0.0   0.0    0.0   0.0   0   0       0
         7   0    1.002   0.0    22.8  10.9    0.0   0.0   0   0       0
         8   2    1.01    0.0    30.0  30.0    0.0  37.3 -15  60       0
         9   0    1.051   0.0     0.0   0.0    0.0   0.0   0   0       0
        10   0    1.045   0.0     5.8   2.0    0.0   0.0   0   0       0
        11   2    1.082   0.0     0.0   0.0    0.0  16.2 -10  50       0
        12   0    1.057   0       11.2  7.5    0     0     0   0       0 
        13   2    1.071   0        0    0.0    0    10.6 -15  60       0
        14   0    1.042   0       6.2   1.6    0     0     0   0       0
        15   0    1.038   0       8.2   2.5    0     0     0   0       0
        16   0    1.045   0       3.5   1.8    0     0     0   0       0
        17   0    1.04    0       9.0   5.8    0     0     0   0       0
        18   0    1.028   0       3.2   0.9    0     0     0   0       0
        19   0    1.026   0       9.5   3.4    0     0     0   0       0
        20   0    1.030   0       2.2   0.7    0     0     0   0       0
        21   0    1.033   0      17.5  11.2    0     0     0   0       0
        22   0    1.033   0       0     0.0    0     0     0   0       0
        23   0    1.027   0       3.2   1.6    0     0     0   0       0
        24   0    1.021   0       8.7   6.7    0     0     0   0       0
        25   0    1.017   0       0     0.0    0     0     0   0       0
        26   0    1       0       3.5   2.3    0     0     0   0       0
        27   0    1.023   0       0     0.0    0     0     0   0       0
        28   0    1.007   0       0     0.0    0     0     0   0       0
        29   0    1.003   0       2.4   0.9    0     0     0   0       0
        30   0    0.992   0      10.6   1.9    0     0     0   0       0];

    
% Line data

%                                              Line code
%         Bus bus   R      X        1/2 B      = 1 for lines 
%         nl  nr  p.u.     p.u.     p.u.       > 1 or < 1 tr. tap at bus nl
linedata=[1   2   0.0192   0.0575   0.0528     0
          1   3   0.0452   0.1652   0.0408     0
          2   4   0.0570   0.1737   0.0368     0
          3   4   0.0132   0.0379   0.0084     0
          2   5   0.0472   0.1983   0.0418     0
          2   6   0.0581   0.1763   0.0374     0
          4   6   0.0119   0.0414   0.009      0
          5   7   0.0460   0.1160   0.0204     0
          6   7   0.0267   0.0820   0.017      0
          6   8   0.0120   0.0420   0.009      0
          6   9   0.0      0.2080   0.0        0.978
          6  10   0        0.5560   0          0.969
          9  11   0        0.2080   0          0
          9  10   0        0.1100   0          0
          4  12   0        0.2560   0          0.932
         12  13   0        0.1400   0          0
         12  14   0.1231   0.2559   0          0
         12  15   0.0662   0.1304   0          0
         12  16   0.0945   0.1987   0          0
         14  15   0.2210   0.1997   0          0
         16  17   0.0524   0.1923   0          0
         15  18   0.1073   0.2185   0          0
         18  19   0.0639   0.1292   0          0
         19  20   0.0340   0.0680   0          0
         10  20   0.0936   0.2090   0          0
         10  17   0.0324   0.0845   0          0
         10  21   0.0348   0.0749   0          0
         10  22   0.0727   0.1499   0          0
         21  22   0.0116   0.0236   0          0
         15  23   0.1000   0.2020   0          0
         22  24   0.1150   0.1790   0          0
         23  24   0.1320   0.2700   0          0
         24  25   0.1885   0.3292   0          0
         25  26   0.2544   0.3800   0          0
         25  27   0.1093   0.2087   0          0
         28  27   0        0.3960   0          0.968
         27  29   0.2198   0.4153   0          0
         27  30   0.3202   0.6027   0          0
         29  30   0.2399   0.4533   0          0
          8  28   0.0636   0.2000   0.0428     0
          6  28   0.0169   0.0599   0.013      0];   

% 產生螞蟻初始位置
% load("Initial_control_variables.mat");
for num=1:Ant_Quantity
    
control_variables(num,1)=20+rand*(80-20); %pg2   
control_variables(num,2)=15+rand*(50-15); %pg5
control_variables(num,3)=10+rand*(35-10); %pg8
control_variables(num,4)=10+rand*(30-10); %pg11
control_variables(num,5)=12+rand*(40-12); %pg13
control_variables(num,6)=0.95+rand*(1.1-0.95); %Vg1
control_variables(num,7)=0.95+rand*(1.1-0.95); %Vg2
control_variables(num,8)=0.95+rand*(1.1-0.95); %Vg5
control_variables(num,9)=0.95+rand*(1.1-0.95); %Vg8
control_variables(num,10)=0.95+rand*(1.1-0.95); %Vg11
control_variables(num,11)=0.95+rand*(1.1-0.95); %Vg13
control_variables(num,12)=0.9+round(16*rand)*0.0125; %T6-9
control_variables(num,13)=0.9+round(16*rand)*0.0125; %T6-10
control_variables(num,14)=0.9+round(16*rand)*0.0125; %T4-12
control_variables(num,15)=0.9+round(16*rand)*0.0125; %T28-27
control_variables(num,16)=0+round(rand*(5-0)); %Q10
control_variables(num,17)=0+round(rand*(5-0)); %Q24

end



%更新初始 計算電力潮流
for num=1:Ant_Quantity

busdata(2,7)=control_variables(num,1);% PG 更新控制變數
busdata(5,7)=control_variables(num,2);
busdata(8,7)=control_variables(num,3);
busdata(11,7)=control_variables(num,4);
busdata(13,7)=control_variables(num,5);

busdata(1,3)=control_variables(num,6); %VG 更新控制變數
busdata(2,3)=control_variables(num,7);
busdata(5,3)=control_variables(num,8);
busdata(8,3)=control_variables(num,9);
busdata(11,3)=control_variables(num,10);
busdata(13,3)=control_variables(num,11);

busdata(10,11)=control_variables(num,16); %QC 更新控制變數
busdata(24,11)=control_variables(num,17);

      
linedata(11,6)=control_variables(num,12);% T 更新控制變數 
linedata(12,6)=control_variables(num,13);
linedata(15,6)=control_variables(num,14);
linedata(36,6)=control_variables(num,15);
      
      
lfybus                          % form the bus admittance matrix
lfnewton              % Load flow solution by Gauss-Seidel method
lineflow          % Computes and displays the line flow and losses

PGG(num,:)=Pgg(1,:);
QGG(num,:)=Qg(1,:);
VGG(num,:)=Vm(1,:);
SGG(num,:)=Snk_abs(1,:);
Ini_PL_all(num,:)=PL_all(1,:);
PGT(num,:)=Pgt(1,:);
PDT(num,:)=Pdt(1,:);
end

VGG(:,[1 2 5 8 11 13])=[];               %去除Vg控制變數的項
clear_PGG=PGG;
clear_PGG=PGG(:,[1]);                       % PG1
clear_QGG=QGG;
clear_QGG=QGG(:,[1 2 5 8 11 13]);                %Qg(1,2,5,8,11,13)
state_variables=[clear_PGG clear_QGG VGG SGG];          %得到狀態變數

%目標函數
for loop=1:Ant_Quantity  
    
    %總發電成本
Fa2(loop,1)=0.00375*PGG(loop,1)^2 + 2*PGG(loop,1);
Fa2(loop,2)=0.0175*PGG(loop,2)^2 + 1.75*PGG(loop,2);
Fa2(loop,3)=0.0625*PGG(loop,3)^2 + 1*PGG(loop,3);
Fa2(loop,4)=0.00834*PGG(loop,4)^2 + 3.25*PGG(loop,4);
Fa2(loop,5)=0.025*PGG(loop,5)^2 + 3*PGG(loop,5);
Fa2(loop,6)=0.025*PGG(loop,6)^2 + 3*PGG(loop,6);
FaALL2(loop,1)=Fa2(loop,1)+Fa2(loop,2)+Fa2(loop,3)+Fa2(loop,4)+Fa2(loop,5)+Fa2(loop,6);

    %總實功率損失
   FaALL3(loop,1)=Ini_PL_all(num,:);
   Fa3(loop,1)=PGT(loop,1) - PDT(loop,1);
   FaALL3(loop,1)=Fa3(loop,1);

  %廢氣排放量
Fa1(loop,1)=0.04091-0.05554*PGG(loop,1)/100+0.06490*(PGG(loop,1)/100)^2+0.000200*exp(2.857*PGG(loop,1)/100);
Fa1(loop,2)=0.02543-0.06407*PGG(loop,2)/100+0.05638*(PGG(loop,2)/100)^2+0.000500*exp(3.333*PGG(loop,2)/100); 
Fa1(loop,3)=0.04258-0.05094*PGG(loop,3)/100+0.06250*(PGG(loop,3)/100)^2+0.000001*exp(8.000*PGG(loop,3)/100);
Fa1(loop,4)=0.05326-0.03550*PGG(loop,4)/100+0.00834*(PGG(loop,4)/100)^2+0.002000*exp(2.000*PGG(loop,4)/100);
Fa1(loop,5)=0.04258-0.05094*PGG(loop,5)/100+-0.975*(PGG(loop,5)/100)^2+0.000001*exp(8.000*PGG(loop,5)/100); 
Fa1(loop,6)=0.06131-0.05555*PGG(loop,6)/100+0.02500*(PGG(loop,6)/100)^2+0.000010*exp(6.667*PGG(loop,6)/100);
FaALL1(loop,1)=Fa1(loop,1)+Fa1(loop,2)+Fa1(loop,3)+Fa1(loop,4)+Fa1(loop,5)+Fa1(loop,6);


end

%計算懲罰項
for loop=1:Ant_Quantity  
if PGG(loop,1) < 50   %Pg1懲罰項限制式判定
    Plim(loop,1) = 50; 
elseif PGG(loop,1) > 200
    Plim(loop,1) = 200;
else 
    Plim(loop,1) = PGG(loop,1);
end
 
if QGG(loop,1) < -20    %Qg1懲罰項限制式判定
    Qlim(loop,1) = -20;
elseif QGG(loop,1) > 200
    Qlim(loop,1) = 200;
else 
    Qlim(loop,1) = QGG(loop,1);
end
 
if QGG(loop,2) < -20  %Qg2懲罰項限制式判定
    Qlim(loop,2) = -20;
elseif QGG(loop,2) > 100
    Qlim(loop,2) = 100;
else 
    Qlim(loop,2) = QGG(loop,2);
end


if QGG(loop,5) < -15 %Qg5懲罰項限制式判定
    Qlim(loop,3) = -15;
elseif QGG(loop,5) > 80
    Qlim(loop,3) = 80;
else 
    Qlim(loop,3) = QGG(loop,5);
end


if QGG(loop,8) < -15 %Qg8懲罰項限制式判定
    Qlim(loop,4) = -15;
elseif QGG(loop,8) > 60
    Qlim(loop,4) = 60;
else Qlim(loop,4) = QGG(loop,8);
end


if QGG(loop,11) < -10 %Qg11懲罰項限制式判定
    Qlim(loop,5) = -10;
elseif QGG(loop,11) > 50
    Qlim(loop,5) = 50;
else Qlim(loop,5) = QGG(loop,11);
end

  
if QGG(loop,13) < -15 %Qg13懲罰項限制式判定
    Qlim(loop,6) = -15;
elseif QGG(loop,13) > 60
    Qlim(loop,6) = 60;
else Qlim(loop,6) = QGG(loop,13);
end

if SGG(loop,[1,2,4,5,9]) > 130 %S懲罰項限制式判定
    Slim(loop,[1,2,4,5,9]) = 130;
else Slim(loop,[1,2,4,5,9]) = SGG(loop,[1,2,4,5,9]);
end

if SGG(loop,[3,6,11,13,14,15,16,36]) > 65 %S懲罰項限制式判定
    Slim(loop,[3,6,11,13,14,15,16,36]) = 65;
else Slim(loop,[3,6,11,13,14,15,16,36]) = SGG(loop,[3,6,11,13,14,15,16,36]);
end

if SGG(loop,7) > 90 %S懲罰項限制式判定
    Slim(loop,7) = 90;
else Slim(loop,7) = SGG(loop,7);
end

if SGG(loop,8) > 70 %S懲罰項限制式判定
    Slim(loop,8) = 70;
else Slim(loop,8) = SGG(loop,8);
end

if SGG(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]) > 32 %S懲罰項限制式判定
    Slim(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]) = 32;
else Slim(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]) = SGG(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]);
end

if SGG(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]) > 16 %S懲罰項限制式判定
    Slim(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]) = 16;
else Slim(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]) = SGG(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]);
end


for Vpf=1:24  %VL 懲罰項限制式判定
    if VGG(loop,Vpf) < 0.95
   Vlim(loop,Vpf) = 0.95;
    elseif VGG(loop,Vpf) > 1.05
   Vlim(loop,Vpf) = 1.05;
    else
   Vlim(loop,Vpf) = VGG(loop,Vpf);
    end
end

%Pg1懲罰
Pn(loop,1) = (PGG(loop,1) - Plim(loop,1))^2;
%Qg1懲罰
Qn(loop,1) = (QGG(loop,1) - Qlim(loop,1))^2;
%Qg2懲罰
Qn(loop,2) = (QGG(loop,2) - Qlim(loop,2))^2;
%Qg5懲罰
Qn(loop,3) = (QGG(loop,5) - Qlim(loop,3))^2;
%Qg8懲罰
Qn(loop,4) = (QGG(loop,8) - Qlim(loop,4))^2;
%Qg11懲罰
Qn(loop,5) = (QGG(loop,11) - Qlim(loop,5))^2;
%Qg13懲罰
Qn(loop,6) = (QGG(loop,13) - Qlim(loop,6))^2;

Qtot(loop,1)=Qn(loop,1)+Qn(loop,2)+Qn(loop,3)+Qn(loop,4)+Qn(loop,5)+Qn(loop,6);
%Vl懲罰
Vn(loop,1)=0;
%S懲罰 
for Spf=1:41
Sn(loop,1) = (SGG(loop,Spf) - Slim(loop,Spf))^2;
end

for Vpf=1:24
Vn(loop,1) = Vn(loop,1) + (VGG(loop,Vpf) - Vlim(loop,Vpf))^2;
end
PF(loop,1) = PgPF*Pn(loop,1)  + QgPF*Qtot(loop,1) + VlPF*Vn(loop,1) + SgPF*Sn(loop,1); 

%能量函數(目標函數+懲罰項)
Ea1(loop,1)=FaALL1(loop,1) + PF(loop,1);
Ea2(loop,1)=FaALL2(loop,1) + PF(loop,1);
Ea3(loop,1)=FaALL3(loop,1) + PF(loop,1);

end

%------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------

Tau=Ea1;

for NC=1:NC_max    %迭代次數回圈
    NC
    %更新解
    lamda=1/NC;
    [Tau_Best,BestIndex]=min(Tau);
    for num=1:Ant_Quantity 
        for m=1:Ant_Quantity
            P(NC,m)=(Tau(BestIndex)-Tau(m))/(Tau(BestIndex));
        end
        
            
        if  P(NC,num)>P0            %局部搜索
            aco_control_variables(num,1:15)=control_variables(num,1:15)+(2*rand-1)*step*lamda;
            aco_control_variables(num,16:17)=round(control_variables(num,16:17)+(2*rand-1)*step*lamda);
        else                        %全局搜索
            aco_control_variables(num,1)=control_variables(num,1)+(rand-0.5)*(80-20); %pg2   
            aco_control_variables(num,2)=control_variables(num,2)+(rand-0.5)*(50-15); %pg5
            aco_control_variables(num,3)=control_variables(num,3)+(rand-0.5)*(35-10); %pg8
            aco_control_variables(num,4)=control_variables(num,4)+(rand-0.5)*(30-10); %pg11
            aco_control_variables(num,5)=control_variables(num,5)+(rand-0.5)*(40-12); %pg13
            aco_control_variables(num,6)=control_variables(num,6)+(rand-0.5)*(1.1-0.95); %Vg1
            aco_control_variables(num,7)=control_variables(num,7)+(rand-0.5)*(1.1-0.95); %Vg2
            aco_control_variables(num,8)=control_variables(num,8)+(rand-0.5)*(1.1-0.95); %Vg5
            aco_control_variables(num,9)=control_variables(num,9)+(rand-0.5)*(1.1-0.95); %Vg8
            aco_control_variables(num,10)=control_variables(num,10)+(rand-0.5)*(1.1-0.95); %Vg11
            aco_control_variables(num,11)=control_variables(num,11)+(rand-0.5)*(1.1-0.95); %Vg13
            aco_control_variables(num,12)=control_variables(num,12)+round((rand-0.5)*(0.2)); %T6-9
            aco_control_variables(num,13)=control_variables(num,13)+round((rand-0.5)*(0.2)); %T6-10
            aco_control_variables(num,14)=control_variables(num,14)+round((rand-0.5)*(0.2)); %T4-12
            aco_control_variables(num,15)=control_variables(num,15)+round((rand-0.5)*(0.2)); %T28-27
            aco_control_variables(num,16)=control_variables(num,16)+round((rand-0.5)*(5-0)); %Q10
            aco_control_variables(num,17)=control_variables(num,17)+round((rand-0.5)*(5-0)); %Q24                        
        end

             %驗證變異後的解是否超出限制式
            %Pg驗證限制式
           if aco_control_variables(num,1)<20
                aco_control_variables(num,1)=20;  
           elseif aco_control_variables(num,1) > 80
                  aco_control_variables(num,1) = 80;
           else
                 aco_control_variables(num,1) = aco_control_variables(num,1);
           end
           
    
           if aco_control_variables(num,2)<15
                aco_control_variables(num,2)=15;  
           elseif aco_control_variables(num,2) > 50
                aco_control_variables(num,2) = 50;
           end
           
           
           if aco_control_variables(num,3)<10
                aco_control_variables(num,3)=10;  
           elseif aco_control_variables(num,3) > 35
                aco_control_variables(num,3) = 35;
           end
           
           if aco_control_variables(num,4)<10
                aco_control_variables(num,4)=10;  
           elseif aco_control_variables(num,4) > 30
                aco_control_variables(num,4) = 30;

           end
           
           if aco_control_variables(num,5)<12
                aco_control_variables(num,5)=12;  
           elseif aco_control_variables(num,5) > 40
                aco_control_variables(num,5) = 40;
           end
            
         %Vg驗證限制式
        for Vrf=6:11
           if aco_control_variables(num,Vrf)<0.95
           aco_control_variables(num,Vrf)=0.95;
           elseif aco_control_variables(num,Vrf) > 1.1
          aco_control_variables(num,Vrf) = 1.1; 
           end
        end
        %T驗證限制式
        for Trf=12:15
           if aco_control_variables(num,Trf)<0.9
            aco_control_variables(num,Trf) = 0.9;
           elseif aco_control_variables(num,Trf) > 1.1
            aco_control_variables(num,Trf) = 1.1;
           else
            aco_control_variables(num,Trf) = round( aco_control_variables(num,Trf) / 0.0125 )*0.0125;  
           end
        end
        %Qc驗證限制式
        for Qrf=16:17
           if aco_control_variables(num,Qrf) < 0
           aco_control_variables(num,Qrf) = 0;  
           elseif aco_control_variables(num,Qrf) > 5
           aco_control_variables(num,Qrf) = 5;
           end     
        end
            %保存搜索後的控制變數
        for new_c=1:17   
            new_aco_control_variables(num,new_c)= aco_control_variables(num,new_c);
        end
    end
    
    %更新解代入電力潮流
    for num=1:Ant_Quantity
        busdata(2,7)=new_aco_control_variables(num,1);% PG 更新控制變數
        busdata(5,7)=new_aco_control_variables(num,2);
        busdata(8,7)=new_aco_control_variables(num,3);
        busdata(11,7)=new_aco_control_variables(num,4);
        busdata(13,7)=new_aco_control_variables(num,5);

        busdata(1,3)=new_aco_control_variables(num,6); %VG 更新控制變數
        busdata(2,3)=new_aco_control_variables(num,7);
        busdata(5,3)=new_aco_control_variables(num,8);
        busdata(8,3)=new_aco_control_variables(num,9);
        busdata(11,3)=new_aco_control_variables(num,10);
        busdata(13,3)=new_aco_control_variables(num,11);

        busdata(10,11)=new_aco_control_variables(num,16); %QC 更新控制變數
        busdata(24,11)=new_aco_control_variables(num,17);

        linedata(11,6)=new_aco_control_variables(num,12);% T 更新控制變數 
        linedata(12,6)=new_aco_control_variables(num,13);
        linedata(15,6)=new_aco_control_variables(num,14);
        linedata(36,6)=new_aco_control_variables(num,15);


        lfybus                            % form the bus admittance matrix
        lfnewton                % Load flow solution by Gauss-Seidel method
        lineflow          % Computes and displays the line flow and losses


        new_PGG(num,:)=Pgg(1,:);
        new_QGG(num,:)=Qg(1,:);
        Vm(:,[1 2 5 8 11 13])=[];
        new_VGG(num,:)=Vm(1,:);
        new_SGG(num,:)=Snk_abs(1,:);
        new_PL_all(num,:)=PL_all(1,:);
        new_PGT(num,:)=Pgt(1,:);
        new_PDT(num,:)=Pdt(1,:);
    end
    
    clear_new_PGG=new_PGG;
    clear_new_PGG=new_PGG(:,[1]);
    clear_new_QGG=new_QGG;
    clear_new_QGG=clear_new_QGG(:,[1 2 5 8 11 13]);
    new_state_variables=[clear_new_PGG clear_new_QGG new_VGG new_SGG];
   


        %新目標函數
        for loop=1:Ant_Quantity  
            
%             %總發電成本
            new_Fa2(loop,1)=0.00375*new_PGG(loop,1)^2 + 2*new_PGG(loop,1);
            new_Fa2(loop,2)=0.0175*new_PGG(loop,2)^2 + 1.75*new_PGG(loop,2);
            new_Fa2(loop,3)=0.0625*new_PGG(loop,3)^2 + 1*new_PGG(loop,3);
            new_Fa2(loop,4)=0.00834*new_PGG(loop,4)^2 + 3.25*new_PGG(loop,4);
            new_Fa2(loop,5)=0.025*new_PGG(loop,5)^2 + 3*new_PGG(loop,5);
            new_Fa2(loop,6)=0.025*new_PGG(loop,6)^2 + 3*new_PGG(loop,6);
            new_FaALL2(loop,1)=new_Fa2(loop,1)+new_Fa2(loop,2)+new_Fa2(loop,3)+new_Fa2(loop,4)+new_Fa2(loop,5)+new_Fa2(loop,6);

            %總實功率損失
            new_FaALL3(loop,1)=new_PL_all(num,:);
            new_Fa3(loop,1)=new_PGT(loop,1) - new_PDT(loop,1);
            new_FaALL3(loop,1)=new_Fa3(loop,1);
            
            %廢氣排放量
%             
            new_Fa1(loop,1)=0.04091-0.05554*new_PGG(loop,1)/100+0.06490*(new_PGG(loop,1)/100)^2+0.000200*exp(2.857*new_PGG(loop,1)/100);
            new_Fa1(loop,2)=0.02543-0.06407*new_PGG(loop,2)/100+0.05638*(new_PGG(loop,2)/100)^2+0.000500*exp(3.333*new_PGG(loop,2)/100);
            new_Fa1(loop,3)=0.04258-0.05094*new_PGG(loop,3)/100+0.06250*(new_PGG(loop,3)/100)^2+0.000001*exp(8.000*new_PGG(loop,3)/100);
            new_Fa1(loop,4)=0.05326-0.03550*new_PGG(loop,4)/100+0.00834*(new_PGG(loop,4)/100)^2+0.002000*exp(2.000*new_PGG(loop,4)/100);
            new_Fa1(loop,5)=0.04258-0.05094*new_PGG(loop,5)/100+0.02500*(new_PGG(loop,5)/100)^2+0.000001*exp(8.000*new_PGG(loop,5)/100);           
            new_Fa1(loop,6)=0.06131-0.05555*new_PGG(loop,6)/100+0.02500*(new_PGG(loop,6)/100)^2+0.000010*exp(6.667*new_PGG(loop,6)/100);              
            new_FaALL1(loop,1)=new_Fa1(loop,1)+new_Fa1(loop,2)+new_Fa1(loop,3)+new_Fa1(loop,4)+new_Fa1(loop,5)+new_Fa1(loop,6);

        end


        %計算懲罰項
        for loop=1:Ant_Quantity  
            if new_PGG(loop,1) < 50   %Pg1懲罰項限制式判定
                new_Plim(loop,1) = 50; 
            elseif new_PGG(loop,1) > 200
                new_Plim(loop,1) = 200;
            else 
                new_Plim(loop,1) = new_PGG(loop,1);
            end

            if new_QGG(loop,1) < -20    %Qg1懲罰項限制式判定
                new_Qlim(loop,1) = -20;
            elseif new_QGG(loop,1) > 200
                new_Qlim(loop,1) = 200;
            else 
                new_Qlim(loop,1) = new_QGG(loop,1);
            end

            if new_QGG(loop,2) < -20  %Qg2懲罰項限制式判定
               new_Qlim(loop,2) = -20;
            elseif new_QGG(loop,2) > 100
                new_Qlim(loop,2) = 100;
            else 
                new_Qlim(loop,2) = new_QGG(loop,2);
            end


            if new_QGG(loop,5) < -15 %Qg5懲罰項限制式判定
                new_Qlim(loop,3) = -15;
            elseif new_QGG(loop,5) > 80
                new_Qlim(loop,3) = 80;
            else 
                new_Qlim(loop,3) = new_QGG(loop,5);
            end


            if new_QGG(loop,8) < -15 %Qg8懲罰項限制式判定
                new_Qlim(loop,4) = -15;
            elseif new_QGG(loop,8) > 60
                new_Qlim(loop,4) = 60;
            else new_Qlim(loop,4) = new_QGG(loop,8);
            end


            if new_QGG(loop,11) < -10 %Qg11懲罰項限制式判定
                new_Qlim(loop,5) = -10;
            elseif new_QGG(loop,11) > 50
                new_Qlim(loop,5) = 50;
            else new_Qlim(loop,5) = new_QGG(loop,11);
            end


            if new_QGG(loop,13) < -15 %Qg13懲罰項限制式判定
                new_Qlim(loop,6) = -15;
            elseif new_QGG(loop,13) > 60
                new_Qlim(loop,6) = 60;
            else new_Qlim(loop,6) = new_QGG(loop,13);
            end

            for Vpf=1:24  %VL 懲罰項限制式判定
                if new_VGG(loop,Vpf) < 0.95
               new_Vlim(loop,Vpf) = 0.95;
                elseif new_VGG(loop,Vpf) > 1.05
               new_Vlim(loop,Vpf) = 1.05;
                else
               new_Vlim(loop,Vpf) = new_VGG(loop,Vpf);
                end
            end
            
            if new_SGG(loop,[1,2,4,5,9]) > 130 %S懲罰項限制式判定
                new_Slim(loop,[1,2,4,5,9]) = 130;
            else new_Slim(loop,[1,2,4,5,9]) = new_SGG(loop,[1,2,4,5,9]);
            end

            if new_SGG(loop,[3,6,11,13,14,15,16,36]) > 65 %S懲罰項限制式判定
                new_Slim(loop,[3,6,11,13,14,15,16,36]) = 65;
            else new_Slim(loop,[3,6,11,13,14,15,16,36]) = new_SGG(loop,[3,6,11,13,14,15,16,36]);
            end

            if new_SGG(loop,7) > 90 %S懲罰項限制式判定
                new_Slim(loop,7) = 90;
            else new_Slim(loop,7) = new_SGG(loop,7);
            end

            if new_SGG(loop,8) > 70 %S懲罰項限制式判定
                new_Slim(loop,8) = 70;
            else new_Slim(loop,8) = new_SGG(loop,8);
            end

            if new_SGG(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]) > 32 %S懲罰項限制式判定
                new_Slim(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]) = 32;
            else new_Slim(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]) = new_SGG(loop,[10,12,17,18,19,24,25,26,27,28,29,40,41]);
            end

            if new_SGG(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]) > 16 %S懲罰項限制式判定
                new_Slim(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]) = 16;
            else new_Slim(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]) = new_SGG(loop,[20,21,22,23,30,31,32,33,34,35,37,38,39]);
            end

            %Pg1懲罰
            new_Pn(loop,1) = (new_PGG(loop,1) - new_Plim(loop,1))^2;
            %Qg1懲罰
            new_Qn(loop,1) = (new_QGG(loop,1) - new_Qlim(loop,1))^2;
            %Qg2懲罰
            new_Qn(loop,2) = (new_QGG(loop,2) - new_Qlim(loop,2))^2;
            %Qg5懲罰
            new_Qn(loop,3) = (new_QGG(loop,5) - new_Qlim(loop,3))^2;
            %Qg8懲罰
            new_Qn(loop,4) = (new_QGG(loop,8) - new_Qlim(loop,4))^2;
            %Qg11懲罰
            new_Qn(loop,5) = (new_QGG(loop,11) - new_Qlim(loop,5))^2;
            %Qg13懲罰
            new_Qn(loop,6) = (new_QGG(loop,13) - new_Qlim(loop,6))^2;
            new_Qtot(loop,1)=new_Qn(loop,1)+new_Qn(loop,2)+new_Qn(loop,3)+new_Qn(loop,4)+new_Qn(loop,5)+new_Qn(loop,6);
            
            %Vl懲罰(先清空上一次之數值)
            new_Vn(loop,1)=0;
            
            for Vpf=1:24
            new_Vn(loop,1) = new_Vn(loop,1) + (new_VGG(loop,Vpf) - new_Vlim(loop,Vpf))^2;
            end
            
            for Spf=1:41
                new_Sn(loop,1) = (new_SGG(loop,Spf) - new_Slim(loop,Spf))^2;
            end
            
            new_PF(loop,1) = PgPF*new_Pn(loop,1)  + QgPF*new_Qtot(loop,1) + VlPF*new_Vn(loop,1) + SgPF*new_Sn(loop,1); 

            %能量函數(目標函數+懲罰項)
            new_Ea1(loop,1)=new_FaALL1(loop,1) + new_PF(loop,1);
            new_Ea2(loop,1)=new_FaALL2(loop,1) + new_PF(loop,1);
            new_Ea3(loop,1)=new_FaALL3(loop,1) + new_PF(loop,1);
        end

        for loop=1:Ant_Quantity
            if new_Ea1(loop,1) < Ea1(loop,1)
                control_variables(loop,:)=new_aco_control_variables(loop,:);
                state_variables(loop,:)=new_state_variables(loop,:);
                Ea1(loop,1)=new_Ea1(loop,1);
                Ea2(loop,1)=new_Ea2(loop,1);
                Ea3(loop,1)=new_Ea3(loop,1);
                
            end
            

            
        end
        
        for  loop=1:Ant_Quantity
            many_Ea1(loop)=Ea1(loop,:);
            many_Ea2(loop)=Ea2(loop,:);
            many_Ea3(loop)=Ea3(loop,:);
        end
        
        [C,Index]=min(many_Ea1);



        %F為全域最佳解

        E_1(NC,1)=C;
        E_2(NC,1)=many_Ea2(Index);
        E_3(NC,1)=many_Ea3(Index);
        
        E_control_variables(NC,:)=control_variables(Index,:);
        E_state_variables(NC,:)=state_variables(Index,:);
      
       
        
        %費洛蒙更新
        for  loop=1:Ant_Quantity
            Tau(loop)=(1-Rho)*Tau(loop)+Ea1(loop,1);
        end
        
        trace(NC)=E_1(NC,1);
      
end

% 收斂曲線圖

figure
plot(trace)
xlabel('迭代次數')
ylabel('總發電成本($/h)')
title('收斂曲線圖')

% 
% 
% figure
% plot(trace)
% xlabel('迭代次數')
% ylabel('總實功率損失(MW)')
% title('收斂曲線圖')

%
% 
% figure
% plot(trace)
% xlabel('迭代次數')
% ylabel('總廢棄排放量(ton/h)')
% title('收斂曲線圖')


toc


