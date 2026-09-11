clc;
clear all;
close all;

%% Exercicio 1 - Identificação de um sistema de primeira ordem a partir de um ensaio

K = 1.8;
tau = 1.2;

G1 = tf(K, [tau 1])

polo_1 = pole(G1);
ganho_rp_1 = dcgain(G1);

t = 0:0.001:8;
[y_1, t] = step(G1, t);

t10 = t(find(y_1 >= 0.1*ganho_rp_1, 1));
t90 = t(find(y_1 >= 0.9*ganho_rp_1, 1));
tr_1 = t90 - t10;

info_1 = stepinfo(y_1, t, ganho_rp_1, 'SettlingTimeThreshold', 0.02);

fprintf('\n===== Exercicio 1 =====\n');
fprintf('Ganho K = %g\n', K);
fprintf('Constante de tempo tau = %g s\n', tau);
fprintf('Polo = %.4f\n', polo_1);
fprintf('Tempo de subida = %.4f s (aprox. 2,2*tau = %.2f s)\n',tr_1, 2.2*tau);
fprintf('Tempo de acomodacao (2%%) = %.4f s (aprox. 4*tau = %.2f s)\n', info_1.SettlingTime, 4*tau);
fprintf('Ganho em regime permanente = %g\n', ganho_rp_1);

figure
plot(t, y_1, 'LineWidth', 1.5)
hold on
plot(tau, (1 - exp(-1))*K, 'ro', 'MarkerFaceColor', 'r')
yline(K, '--k');
ylim([0 2])
grid on
title('Exercicio 1 - Resposta ao degrau unitario')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('Resposta ao degrau', '63% do valor final (t = \tau)', 'Valor final = 1,8', 'Location', 'southeast')
hold off

amplitude = 2.5;
[y_1b, t] = step(amplitude*G1, t);
valor_final_1b = amplitude*ganho_rp_1;

fprintf('Valor final para degrau de amplitude 2,5 = %g\n', valor_final_1b);

figure
plot(t, y_1, 'LineWidth', 1.5)
hold on
plot(t, y_1b, 'LineWidth', 1.5)
yline(valor_final_1b, '--k');
ylim([0 5])
grid on
title('Exercicio 1 - Degrau unitario x degrau de amplitude 2,5')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('Degrau unitario', 'Degrau de 2,5', 'Valor final = 4,5', 'Location', 'southeast')
hold off

% A constante de tempo define a posicao do polo (s = -1/tau), com tau = 1,2 s, o polo fica em -0,833.
% Quanto menor tau, mais longe da origem fica o polo e mais rapida e a resposta, a amplitude do degrau so escala a saida, sem mudar tau.

%% Exercicio 2 - Escolha entre tres sistemas de segunda ordem

GA = tf(25, [1 3 25])
GB = tf(25, [1 10 25])
GC = tf(25, [1 16 25])

sistemas = {GA, GB, GC};
nomes = {'A', 'B', 'C'};

t = 0:0.001:8;
y_2 = zeros(length(t), 3);
polos_2 = cell(1, 3);
overshoot_2 = zeros(1, 3);
ts_2 = zeros(1, 3);

fprintf('\n===== Exercicio 2 =====\n');

for i = 1:3
    G = sistemas{i};

    [~, den] = tfdata(G, 'v');
    wn = sqrt(den(3));
    zeta = den(2)/(2*wn);

    if zeta == 0
        tipo = 'nao amortecido';
    elseif zeta < 1
        tipo = 'subamortecido';
    elseif zeta == 1
        tipo = 'criticamente amortecido';
    else
        tipo = 'superamortecido';
    end

    polos_2{i} = pole(G);
    y_2(:, i) = step(G, t);
    info = stepinfo(y_2(:, i), t, dcgain(G), 'SettlingTimeThreshold', 0.02);
    overshoot_2(i) = info.Overshoot;
    ts_2(i) = info.SettlingTime;

    fprintf('\nSistema %s\n', nomes{i});
    fprintf('Polos:\n');
    disp(polos_2{i});
    fprintf('wn = %g rad/s\n', wn);
    fprintf('zeta = %g\n', zeta);
    fprintf('Tipo de resposta: %s\n', tipo);
    fprintf('Ganho em regime permanente = %g\n', dcgain(G));
    fprintf('Sobressinal = %.2f%%  |  Tempo de acomodacao (2%%) = %.4f s\n', overshoot_2(i), ts_2(i));
end


sem_sobressinal = find(overshoot_2 < 0.01);
[~, idx] = min(ts_2(sem_sobressinal));
escolhido = sem_sobressinal(idx);
fprintf('\nSistema mais adequado (sem sobressinal e mais rapido): %s\n', nomes{escolhido});

figure
plot(t, y_2, 'LineWidth', 1.5)
hold on
yline(1, '--k');
grid on
title('Exercicio 2 - Resposta ao degrau dos sistemas A, B e C')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('Sistema A (\zeta = 0,3)', 'Sistema B (\zeta = 1)', 'Sistema C (\zeta = 1,6)', ...
    'Valor final', 'Location', 'southeast')
hold off

figure
hold on
plot(real(polos_2{1}), imag(polos_2{1}), 'x', 'MarkerSize', 12, 'LineWidth', 2)
plot(real(polos_2{2}), imag(polos_2{2}), 'x', 'MarkerSize', 12, 'LineWidth', 2)
plot(real(polos_2{3}), imag(polos_2{3}), 'x', 'MarkerSize', 12, 'LineWidth', 2)
xline(0, 'k');
yline(0, 'k');
xlim([-16 1])
ylim([-6 6])
grid on
title('Exercicio 2 - Posicao dos polos')
xlabel('Eixo real')
ylabel('Eixo imaginario')
legend('Sistema A', 'Sistema B (polo duplo)', 'Sistema C', 'Location', 'best')
hold off

% O sistema A ultrapassa o valor final (~37% de sobressinal) e fica descartado, entre B e C, que nao tem sobressinal, B acomoda mais rapido (~1,17 s contra ~2,30 s de C), pois o polo lento de C (-1,76) esta mais perto da origem.

%% Exercicio 3 - Avaliacao de desempenho de dois sistemas de segunda ordem

G_1 = tf(16, [1 2.8 16])
G_2 = tf(25, [1 6.5 25])

sistemas = {G_1, G_2};
t = 0:0.001:8;
y_3 = zeros(length(t), 2);
atende = false(1, 2);

Mp_max = 10;  
ts_max = 1.5;  

fprintf('\n===== Exercicio 3 =====\n');

for i = 1:2
    G = sistemas{i};
    valor_final = dcgain(G);
    y_3(:, i) = step(G, t);

    [wn_polos, zeta_polos, polos] = damp(G);

    td = t(find(y_3(:, i) >= 0.5*valor_final, 1));

    info = stepinfo(y_3(:, i), t, valor_final, 'RiseTimeLimits', [0 1], ...
        'SettlingTimeThreshold', 0.02);

    atende(i) = info.Overshoot < Mp_max && info.SettlingTime < ts_max;

    fprintf('\nSistema %d\n', i);
    fprintf('Valor final = %g\n', valor_final);
    fprintf('Tempo de atraso = %.4f s\n', td);
    fprintf('Tempo de subida (0 a 100%%) = %.4f s\n', info.RiseTime);
    fprintf('Tempo de pico = %.4f s\n', info.PeakTime);
    fprintf('Primeiro pico = %.4f\n', info.Peak);
    fprintf('Maximo sobressinal = %.2f%%\n', info.Overshoot);
    fprintf('Tempo de acomodacao (2%%) = %.4f s\n', info.SettlingTime);
    fprintf('wn = %g rad/s\n', wn_polos(1));
    fprintf('zeta = %g\n', zeta_polos(1));
    fprintf('Polos:\n');
    disp(polos);
end

fprintf('Requisitos: sobressinal < %g%% e acomodacao < %g s\n', Mp_max, ts_max);
for i = 1:2
    if atende(i)
        fprintf('Sistema %d: atende aos requisitos\n', i);
    else
        fprintf('Sistema %d: nao atende aos requisitos\n', i);
    end
end

figure
plot(t, y_3, 'LineWidth', 1.5)
hold on
yline(1, '--k');
yline(1 + Mp_max/100, ':r');
xline(ts_max, ':r');
grid on
title('Exercicio 3 - Resposta ao degrau dos sistemas 1 e 2')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('Sistema 1 (\zeta = 0,35)', 'Sistema 2 (\zeta = 0,65)', 'Valor final', ...
    'Limite de sobressinal (10%)', 'Limite de acomodacao (1,5 s)', 'Location', 'southeast')
hold off

% O sistema 1 (zeta = 0,35) oscila bastante, com ~31% de sobressinal e acomodacao em ~2,75 s,já o sistema 2 (zeta = 0,65) sobe de forma mais suave, com ~6,8% de sobressinal e acomodacao em ~1,20 s.
% Apenas o sistema 2 atende aos dois requisitos, o amortecimento maior (parte real dos polos -3,25 contra -1,4) reduz o sobressinal e acelera a acomodacao, mesmo com tempo de subida um pouco maior.

%% Exercicio 4 - Selecao de parametros para um sistema de segunda ordem

zeta_4 = [0.35 0.55 0.70 0.80];
wn_4 = [6 5 4 3.2];
nomes = {'A', 'B', 'C', 'D'};

G4_A = tf(wn_4(1)^2, [1 2*zeta_4(1)*wn_4(1) wn_4(1)^2])
G4_B = tf(wn_4(2)^2, [1 2*zeta_4(2)*wn_4(2) wn_4(2)^2])
G4_C = tf(wn_4(3)^2, [1 2*zeta_4(3)*wn_4(3) wn_4(3)^2])
G4_D = tf(wn_4(4)^2, [1 2*zeta_4(4)*wn_4(4) wn_4(4)^2])

sistemas = {G4_A, G4_B, G4_C, G4_D};

% Requisitos 
Mp_max = 10;  
ts_max = 1.5;  

t = 0:0.001:8;
y_4 = zeros(length(t), 4);
tr_4 = zeros(1, 4);
valida = false(1, 4);

fprintf('\n===== Exercicio 4 =====\n');

for i = 1:4
    G = sistemas{i};
    valor_final = dcgain(G);
    y_4(:, i) = step(G, t);

    info = stepinfo(y_4(:, i), t, valor_final, 'RiseTimeLimits', [0 1], ...
        'SettlingTimeThreshold', 0.02);

    tr_4(i) = info.RiseTime;
    valida(i) = info.Overshoot < Mp_max && info.SettlingTime < ts_max;

    fprintf('\nConfiguracao %s (zeta = %g, wn = %g rad/s)\n', nomes{i}, zeta_4(i), wn_4(i));
    fprintf('Polos:\n');
    disp(pole(G));
    fprintf('Maximo sobressinal = %.2f%%\n', info.Overshoot);
    fprintf('Tempo de subida (0 a 100%%) = %.4f s\n', info.RiseTime);
    fprintf('Tempo de pico = %.4f s\n', info.PeakTime);
    fprintf('Tempo de acomodacao (2%%) = %.4f s\n', info.SettlingTime);
    fprintf('Valor final = %g\n', valor_final);
end

validas = find(valida);
[~, idx] = min(tr_4(validas));
escolhida = validas(idx);

fprintf('\nRequisitos: sobressinal < %g%% e acomodacao < %g s\n', Mp_max, ts_max);
fprintf('Configuracoes que atendem: %s\n', strjoin(nomes(valida), ', '));
fprintf('Configuracoes que nao atendem: %s\n', strjoin(nomes(~valida), ', '));
fprintf('Configuracao escolhida (menor tempo de subida entre as validas): %s\n', nomes{escolhida});

figure
plot(t, y_4, 'LineWidth', 1.5)
hold on
yline(1, '--k');
yline(1 + Mp_max/100, ':r');
xline(ts_max, ':r');
grid on
title('Exercicio 4 - Resposta ao degrau das configuracoes A, B, C e D')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('A (\zeta = 0,35; \omega_n = 6)', 'B (\zeta = 0,55; \omega_n = 5)', ...
    'C (\zeta = 0,70; \omega_n = 4)', 'D (\zeta = 0,80; \omega_n = 3,2)', 'Valor final', ...
    'Limite de sobressinal (10%)', 'Limite de acomodacao (1,5 s)', 'Location', 'southeast')
hold off

% A e B sobem mais rapido, mas seus picos passam da linha de 10% (~31% e ~12,6%), por isso foram descartadas, C e D ficam abaixo do limite e acomodam antes de 1,5 s.
% Entre as validas, C cruza o valor final bem antes de D (subida de ~0,82 s contra ~1,30 s) e foi escolhida, D quase nao tem sobressinal, mas com wn menor sua subida fica mais lenta.

%% Exercicio 5 - Comparacao entre sistemas de primeira e segunda ordem

G5_A = tf(2, [1.2 1])
G5_B = tf(32, [1 5.6 16])

t = 0:0.001:8;
y_5A = step(G5_A, t);
y_5B = step(G5_B, t);

ganho_A = dcgain(G5_A);
ganho_B = dcgain(G5_B);

t10 = t(find(y_5A >= 0.1*ganho_A, 1));
t90 = t(find(y_5A >= 0.9*ganho_A, 1));
tr_A = t90 - t10;
info_A = stepinfo(y_5A, t, ganho_A, 'SettlingTimeThreshold', 0.02);

[wn_polos, zeta_polos] = damp(G5_B);
info_B = stepinfo(y_5B, t, ganho_B, 'RiseTimeLimits', [0 1], ...
    'SettlingTimeThreshold', 0.02);

fprintf('\n===== Exercicio 5 =====\n');

fprintf('\nEquipamento A (primeira ordem)\n');
fprintf('Polo = %.4f\n', pole(G5_A));
fprintf('Ganho em regime permanente = %g\n', ganho_A);
fprintf('Valor final (degrau unitario) = %g\n', y_5A(end));
fprintf('Tempo de subida (10 a 90%%) = %.4f s\n', tr_A);
fprintf('Tempo de acomodacao (2%%) = %.4f s\n', info_A.SettlingTime);

fprintf('\nEquipamento B (segunda ordem)\n');
fprintf('Polos:\n');
disp(pole(G5_B));
fprintf('Ganho em regime permanente = %g\n', ganho_B);
fprintf('Valor final (degrau unitario) = %g\n', y_5B(end));
fprintf('Tempo de subida (0 a 100%%) = %.4f s\n', info_B.RiseTime);
fprintf('Tempo de acomodacao (2%%) = %.4f s\n', info_B.SettlingTime);
fprintf('wn = %g rad/s\n', wn_polos(1));
fprintf('zeta = %g\n', zeta_polos(1));
fprintf('Tempo de pico = %.4f s\n', info_B.PeakTime);
fprintf('Primeiro pico = %.4f\n', info_B.Peak);
fprintf('Maximo sobressinal = %.2f%%\n', info_B.Overshoot);

figure
plot(t, y_5A, 'LineWidth', 1.5)
hold on
plot(t, y_5B, 'LineWidth', 1.5)
yline(ganho_A, '--k');
ylim([0 2.5])
grid on
title('Exercicio 5 - Resposta ao degrau unitario dos equipamentos')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('Equipamento A (1a ordem)', 'Equipamento B (2a ordem)', 'Valor final = 2', 'Location', 'southeast')
hold off

amplitude = 1.5;
y_5A_amp = step(amplitude*G5_A, t);
y_5B_amp = step(amplitude*G5_B, t);

fprintf('\nDegrau de amplitude 1,5\n');
fprintf('Valor final do equipamento A = %g\n', amplitude*ganho_A);
fprintf('Valor final do equipamento B = %g\n', amplitude*ganho_B);

figure
plot(t, y_5A_amp, 'LineWidth', 1.5)
hold on
plot(t, y_5B_amp, 'LineWidth', 1.5)
yline(amplitude*ganho_A, '--k');
ylim([0 3.5])
grid on
title('Exercicio 5 - Resposta ao degrau de amplitude 1,5')
xlabel('Tempo (s)')
ylabel('Amplitude')
legend('Equipamento A (1a ordem)', 'Equipamento B (2a ordem)', 'Valor final = 3', 'Location', 'southeast')
hold off

% Rapidez: o equipamento B é bem mais rapido, acomodando em ~1,49 s, enquanto o A (tau = 1,2 s) leva ~4,69 s para entrar na faixa de 2%.
% Sobressinal: o A, de primeira ordem, nunca ultrapassa o valor final, o B (zeta = 0,7) passa um pouco dele, com pico de ~2,09 (~4,6%) em 1,1 s.
% Regime permanente: os dois tem ganho 2 e chegam ao mesmo valor final (2 no degrau unitario e 3 no degrau de 1,5), diferindo apenas no transitorio.