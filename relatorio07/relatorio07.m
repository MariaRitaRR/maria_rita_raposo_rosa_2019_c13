%% Relatório - Introdução aos Controladores PID 
clc;
clear;
close all;

%% Preparação
s = tf('s');
motor = 1/(s+3);
planta = 2/(s+2);
G = motor * planta

%% a) Faixa de K para estabilidade

Kcrit = -3;
fprintf('(a) Sistema estável para K > %.1f  ->  Kcritico = %.1f\n\n', Kcrit, Kcrit);

Kvet = -5:0.01:50;
estavel = arrayfun(@(K) isstable(feedback(K*G, 1)), Kvet);
fprintf('    Menor K estável encontrado na varredura: %.2f\n\n', min(Kvet(estavel)));


%% b) K = 10
K = 10;
T10 = feedback(K*G, 1);
polos10 = pole(T10);
fprintf('(b) K = 10 -> polos em malha fechada:\n');
disp(polos10);
if isstable(T10)
    fprintf('    Todos os polos com parte real negativa -> sistema ESTÁVEL\n\n');
else
    fprintf('    Existe polo com parte real >= 0 -> sistema INSTÁVEL\n\n');
end

%% c) K = 0,6*Kcritico, SetPoint = 150
K = 0.6 * Kcrit;                 % K = -1,8
SP = 150;
T = feedback(K*G, 1);

fprintf('(c) K = %.2f -> polos em malha fechada:\n', K);
disp(pole(T));

figure;
step(SP*T);
grid on;
title('Step Response (K = 0,6 \cdot K_{critico}, SetPoint = 150)');
xlabel('Time'); ylabel('Amplitude');

info = stepinfo(SP*T);
fprintf('    Tempo de acomodação: %.2f s\n\n', info.SettlingTime);

%% d) Valor final
yfinal = SP * dcgain(T);
fprintf('(d) Valor final = %.1f\n', yfinal);
fprintf('    Erro em regime = %.1f\n', SP - yfinal);
