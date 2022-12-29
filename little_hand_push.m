%checking load cells
clear all
clc
load("Hand_push_raw_data.mat");
start = 8;
%dataName = fieldnames(data);
time = EF327.waveform(start:end);
Fx = EF327.Fx(start:end);
Fy = EF327.Fy(start:end);
Fz = EF327.Fz(start:end);
Mx = EF327.Mx(start:end);
My = EF327.My(start:end);
Mz = EF327.Mz(start:end);

wFx = EF327.WheelFx(start:end);
wFy = EF327.WheelFy(start:end);
wFz = EF327.WheelFz(start:end);
wMx = EF327.WheelMx(start:end);
wMy = EF327.WheelMy(start:end);
wMz = EF327.WheelMz(start:end);

figure;
T = tiledlayout(2,3);
nexttile
plot(time,Fx);
title('Fx v T');
grid on
nexttile
plot(time,Fy);
grid on
title('Fy v T');
nexttile
plot(time,Fz);
grid on
title('Fz v T');

nexttile
plot(time,Mx);
grid on
title('Mx v T');
nexttile
plot(time,My);
grid on
title('My v T');
nexttile
plot(time,Mz);
grid on
title('Mz v T');

figure
tiledlayout(2,3);
nexttile
plot(time,wFx);
grid on
title('wFx v T');
nexttile
plot(time,wFy);
grid on
title('wFy v T');
nexttile
plot(time,wFz);
grid on
title('wFz v T');

nexttile
plot(time,wMx);
grid on
title('wMx v T');
nexttile
plot(time,wMy);
grid on
title('wMx v T');
nexttile
plot(time,wMz);
grid on
title('wMz v T');


