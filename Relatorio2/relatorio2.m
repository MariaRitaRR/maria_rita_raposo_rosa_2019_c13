%% Config
clc;
clear;
close all;

%% Exercício 01
massa1 = 2;
massa2 = 4;
atrito1 = 3;
atrito2 = 6;

ft1 = tf(1, [massa1 atrito1]);
ft2 = tf(1, [massa2 atrito2]);

disp("Funções de Transferência")
disp("Sistema 1")
ft1
disp("Sistema 2")
ft2

tempo = 0:0.01:20;
[saida1, tempo1] = step(ft1, tempo);
[saida2, tempo2] = step(ft2, tempo);

% Respostas juntas + força unitária tracejada
figure('Name','Ex1 - Respostas juntas');
plot(tempo1, saida1, 'b', 'LineWidth', 1.5); hold on;
plot(tempo2, saida2, 'r', 'LineWidth', 1.5);
plot(tempo, ones(size(tempo)), 'k--', 'LineWidth', 1.2);
hold off;
title('Resposta ao degrau — Sistemas massa–atrito');
xlabel('Tempo (s)'); ylabel('Velocidade (saída)');
legend('Sistema 1 (M=2, B=3)','Sistema 2 (M=4, B=6)','Força unitária', ...
       'Location','east');
grid on;

% Janela de zoom (0-5 s) no canto superior esquerdo
faixa = tempo <= 5;
axes('Position',[0.18 0.55 0.30 0.30]);
box on;
plot(tempo1(faixa), saida1(faixa), 'b', 'LineWidth',1.5);
hold on;
plot(tempo2(faixa), saida2(faixa), 'r', 'LineWidth',1.5);
hold off;
title('Zoom: 0-5 s');
xlabel('t (s)');
ylabel('saída');
grid on;

% Respostas separadas
figure('Name','Ex1 - Respostas separadas');
subplot(2,1,1);
plot(tempo1, saida1, 'b', 'LineWidth', 1.5);
title('Sistema 1 (M=2, B=3)');
xlabel('Tempo (s)'); ylabel('Saída'); grid on;

subplot(2,1,2);
plot(tempo2, saida2, 'r', 'LineWidth', 1.5);
title('Sistema 2 (M=4, B=6)');
xlabel('Tempo (s)'); ylabel('Saída'); grid on;

%% Exercício 02
resistencia = 2000;
tau = 2.5;
capacitancia = tau / resistencia;
ftRC = tf(1, [tau 1]);

disp('=== Exercício 2: Circuito RC ===')
fprintf('Capacitância calculada: C = %g F\n', capacitancia);
disp('Função de Transferência:')
ftRC

figure('Name','Ex2 - Resposta ao degrau RC');
step(ftRC, 15);
title('Resposta ao degrau — Circuito RC');
xlabel('Tempo (s)'); ylabel('Tensão no capacitor');
grid on;

% Varredura de resistências e constantes de tempo
resistenciaTeste = 100:100:10000;
tauTeste = resistenciaTeste * capacitancia;

figure('Name','Ex2 - Comparação de escalas');

subplot(2,2,1);
plot(resistenciaTeste, tauTeste, 'LineWidth', 1.3);
title('Escala comum (linear-linear)');
xlabel('Resistência (\Omega)'); ylabel('\tau (s)'); grid on;

subplot(2,2,2);
semilogy(resistenciaTeste, tauTeste, 'LineWidth', 1.3);
title('Log no eixo vertical');
xlabel('Resistência (\Omega)'); ylabel('\tau (s)'); grid on;

subplot(2,2,3);
semilogx(resistenciaTeste, tauTeste, 'LineWidth', 1.3);
title('Log no eixo horizontal');
xlabel('Resistência (\Omega)'); ylabel('\tau (s)'); grid on;

subplot(2,2,4);
loglog(resistenciaTeste, tauTeste, 'LineWidth', 1.3);
title('Log nos dois eixos');
xlabel('Resistência (\Omega)'); ylabel('\tau (s)'); grid on;

%% Exercício 03
tempo3 = (0:25)';
entrada3 = [0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
saidaExp3 = [0.008 0.012 0.006 0.010 0.020 0.382 0.671 0.903 1.082 1.226 1.335 ...
    1.425 1.492 1.547 1.587 1.618 1.642 1.660 1.674 1.684 1.692 1.698 ...
    1.702 1.706 1.709 1.711];

entrada3 = entrada3(:);
saidaExp3 = saidaExp3(:);

figure('Name','Ex3 - Entrada e Saída');
subplot(2,1,1);
plot(tempo3, entrada3, 'b', 'LineWidth', 1.5);
title('Entrada u'); xlabel('Tempo (s)'); ylabel('u'); grid on;

subplot(2,1,2);
plot(tempo3, saidaExp3, 'r', 'LineWidth', 1.5);
title('Saída y'); xlabel('Tempo (s)'); ylabel('y'); grid on;

figure('Name','Ex3 - plot3');
plot3(tempo3, entrada3, saidaExp3, 'LineWidth', 1.5);
title('Visualização 3D — tempo x entrada x saída');
xlabel('Tempo (s)'); ylabel('Entrada u'); zlabel('Saída y');
grid on;

% Identificação da FT (1 polo, 0 zeros)
periodoAmostragem = 1;
dados3 = iddata(saidaExp3, entrada3, periodoAmostragem);
ftEstimada3 = tfest(dados3, 1, 0);

disp('=== Exercício 3: Função de Transferência Estimada ===')
ftEstimada3

figure('Name','Ex3 - Compare');
compare(dados3, ftEstimada3);
title('Comparação: dados experimentais x modelo');
grid on;

figure('Name','Ex3 - Step do modelo');
step(ftEstimada3, 25);
title('Resposta ao degrau do modelo identificado');
xlabel('Tempo (s)'); ylabel('Saída'); grid on;

%% Exercício 04
resistencia1 = 1000; tau1 = 1.2;
resistencia2 = 2000; tau2 = 2.8;
resistencia3 = 3000; tau3 = 3.9;
resistencia4 = 5000; tau4 = 7.0;

capacitancia1 = tau1 / resistencia1;
capacitancia2 = tau2 / resistencia2;
capacitancia3 = tau3 / resistencia3;
capacitancia4 = tau4 / resistencia4;

disp('=== Exercício 4: Capacitâncias ===')
fprintf('C1 = %g F\n', capacitancia1);
fprintf('C2 = %g F\n', capacitancia2);
fprintf('C3 = %g F\n', capacitancia3);
fprintf('C4 = %g F\n', capacitancia4);

resistenciaVetor = [resistencia1 resistencia2 resistencia3 resistencia4];
tauVetor = [tau1 tau2 tau3 tau4];
capacitanciaVetor = [capacitancia1 capacitancia2 capacitancia3 capacitancia4];

figure('Name','Ex4 - plot3 experimentos');
plot3(resistenciaVetor, tauVetor, capacitanciaVetor, 'o-', 'LineWidth', 1.5, 'MarkerFaceColor','b');
title('Experimentos RC — R x \tau x C');
xlabel('Resistência (\Omega)'); ylabel('\tau (s)'); zlabel('Capacitância (F)');
grid on;

% Experimento 3: FT e resposta ao degrau
ftExp3 = tf(1, [tau3 1]);

tempo4 = 0:0.01:20;
[saida4, tempo4] = step(ftExp3, tempo4);

figure('Name','Ex4 - Step Experimento 3');
plot(tempo4, saida4, 'b', 'LineWidth', 1.5);
title('Resposta ao degrau — Experimento 3');
xlabel('Tempo (s)'); ylabel('Tensão no capacitor'); grid on;

% Janela de zoom (0-5 s)
faixa4 = tempo4 <= 5;
axes('Position',[0.50 0.25 0.35 0.35]);
box on;
plot(tempo4(faixa4), saida4(faixa4), 'b', 'LineWidth', 1.5);
title('Zoom: 0–5 s'); xlabel('t (s)'); ylabel('saída'); grid on;

%% Exercício 05
massaA = 3; atritoA = 5;
ftA = tf(1, [massaA atritoA]);

resistenciaB = 1500; tauB = 3;
capacitanciaB = tauB / resistenciaB;
ftB = tf(1, [tauB 1]);

tempoC = (0:20)';
entradaC = [0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
saidaC = [0.010 0.006 0.012 0.018 0.408 0.706 0.934 1.103 1.229 1.322 1.391 ...
      1.441 1.479 1.505 1.526 1.540 1.551 1.558 1.564 1.568 1.571];
entradaC = entradaC(:);
saidaC = saidaC(:);

periodoAmostragem = 1;
dadosC = iddata(saidaC, entradaC, periodoAmostragem);
ftC = tfest(dadosC, 1, 0);

disp('=== Exercício 5 ===')
disp('Sistema A — FT:')
ftA
fprintf('Sistema B — Capacitância: C = %g F\n', capacitanciaB);
disp('Sistema B — FT:')
ftB
disp('Sistema C — FT estimada:')
ftC

figure('Name','Ex5 - Três respostas ao degrau');
subplot(3,1,1);
step(ftA, 20);
title('Sistema A — Caixa Branca'); xlabel('Tempo (s)'); ylabel('Saída'); grid on;

subplot(3,1,2);
step(ftB, 20);
title('Sistema B — Caixa Cinza'); xlabel('Tempo (s)'); ylabel('Saída'); grid on;

subplot(3,1,3);
step(ftC, 20);
title('Sistema C — Caixa Preta'); xlabel('Tempo (s)'); ylabel('Saída'); grid on;

figure('Name','Ex5 - Entrada e Saída Sistema C');
subplot(2,1,1);
plot(tempoC, entradaC, 'b', 'LineWidth', 1.5);
title('Entrada u — Sistema C'); xlabel('Tempo (s)'); ylabel('u'); grid on;

subplot(2,1,2);
plot(tempoC, saidaC, 'r', 'LineWidth', 1.5);
title('Saída y — Sistema C'); xlabel('Tempo (s)'); ylabel('y'); grid on;

figure('Name','Ex5 - Compare Sistema C');
compare(dadosC, ftC);
title('Comparação — Sistema C: dados x modelo'); grid on;

% Caixa Branca (A): física conhecida, parâmetros conhecidos, FT deduzida.
% Caixa Cinza (B): estrutura conhecida, parâmetro (C) obtido de medida.
% Caixa Preta (C): só entrada/saída, modelo obtido por identificação.