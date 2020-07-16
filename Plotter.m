% Vetor de estado que caracteriza nossa transferencia de interesse
%x = [ 2.6147    6.2832    3.0095    0.8353 3.09 261.96 2.28];
format shortg
x = best_global;
funcao_custo;

plot_v = 1;
plot_info = 1;

UA = 1.496e8;

figure;
legenda = string();
legenda(end+1) = plotar_ponto([0,0], "Sol",  'd');
legenda(end+1) = plotar_ponto(r_terra_sol/UA, "Terra",  'o');
legenda(end+1) = plotar_ponto(r_venus_sol/UA, "Venus",  'o');
legenda(end+1) = plotar_ponto(r_marte_sol/UA, "Marte",  'o');

[x,y] = definir_orbita_cartesiana(...
    r_oe_terra, ...
    banco_velocidades_saida(1,:), ...
    mi_terra);
legenda(end+1) = plotar_ponto((r_oe_terra + r_terra_sol)/UA, "A");
legenda(end+1) = plotar_ponto(([x' y'] + r_terra_sol(1:2))/UA, "Trajet�ria T-T", '-');
legenda(end+1) = plotar_ponto((r_soi_terra + r_terra_sol)/UA, "B");

% �rbita BC: Transfer�ncia entre esferas de influ�ncia Terra - Venus
disp("Velocidade de sa�da da SOI da Terra: ");
disp(banco_velocidades_saida(2,:));
disp("Velocidade de chegada na SOI de Venus: ");
disp(banco_velocidades_chegada(2,:));
[x,y] = definir_orbita_cartesiana(...
    r_soi_terra + r_terra_sol, ...
    banco_velocidades_saida(2,:), ...
    mi_sol);
legenda(end+1) = plotar_ponto([x' y']/UA, "Trajet�ria T-V", '-');
legenda(end+1) = plotar_ponto((r_soi_venus + r_venus_sol)/UA, "C");

% �rbita CD: Transfer�ncia entre esferas dentro da influ�ncia de V�nus
[x,y] = definir_orbita_cartesiana(...
    r_soi_venus, ...
    banco_velocidades_saida(3,:), ...
    mi_venus);
legenda(end+1) = plotar_ponto(([x' y'] + r_venus_sol(1:2))/UA, "Trajet�ria V-V", '-');
legenda(end+1) = plotar_ponto((r_soi_venus * M(deflexao_venus) + r_venus_sol)/UA, "D");

% �rbita DE: Transfer�ncia SOI(Venus)-SOI(Marte)
[x,y] = definir_orbita_cartesiana(...
    r_soi_venus * M(deflexao_venus) + r_venus_sol, ...
    banco_velocidades_saida(4,:), ...
    mi_sol);
legenda(end+1) = plotar_ponto(([x' y'])/UA, "Trajet�ria V-M", '-');
legenda(end+1) = plotar_ponto((r_soi_marte + r_marte_sol)/UA, "E");


% �rbita DE: Transfer�ncia SOI(Marte)-OE(Marte)
[x,y] = definir_orbita_cartesiana(...
    r_soi_marte, ...
    banco_velocidades_saida(5,:), ...
    mi_marte);

legenda(end+1) = plotar_ponto(([x' y'] + r_marte_sol(1:2))/UA, "Trajet�ria M-M", '-');
legenda(end+1) = plotar_ponto((r_marte_sol + r_oe_marte)/UA, "F");

grid on;
axis equal
legend(legenda(2:end));
xlabel('x [UA]');
ylabel('y [UA]');

if plot_v == 1
    plotar_vetor(v_terra_sol, (r_terra_sol)/UA, 0.01);
    plotar_vetor(v_venus_sol, (r_venus_sol)/UA, 0.01);
    plotar_vetor(v_marte_sol, (r_marte_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_inicial(1,:), (r_oe_terra + r_terra_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_saida(1,:), (r_oe_terra + r_terra_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_inicial(2,:), (r_soi_terra + r_terra_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_saida(2,:), (r_soi_terra + r_terra_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_inicial(3,:), (r_soi_venus + r_venus_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_saida(3,:), (r_soi_venus + r_venus_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_inicial(4,:), (r_soi_venus * M(deflexao_venus) + r_venus_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_saida(4,:), (r_soi_venus * M(deflexao_venus) + r_venus_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_inicial(5,:), (r_soi_marte + r_marte_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_saida(5,:), (r_soi_marte + r_marte_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_inicial(6,:), (r_oe_marte + r_marte_sol)/UA, 0.01);
    plotar_vetor(banco_velocidades_saida(6,:), (r_oe_marte + r_marte_sol)/UA, 0.01);
end

if plot_info == 1
    disp("---");
    disp("Referencial na Terra");
    disp("�ngulo sa�da: " + theta_oe_terra*180/pi);
    disp("�ngulo chegada: " + theta_soi_terra*180/pi);
    
    if venus_swing_by == 1
        disp("---");
        disp("Referencial em V�nus");
        disp("Fase V�nus: " + phase_venus*180/pi);
        disp("�ngulo sa�da: " + theta_soi_venus*180/pi);
        disp("�ngulo chegada: " + (deflexao_venus + theta_soi_venus)*180/pi);
    end
    
    disp("---");
    disp("Referencial em Marte");
    disp("Fase Marte: " + phase_marte*180/pi);
    disp("�ngulo sa�da: " + theta_soi_marte*180/pi);
    disp("�ngulo chegada: " + theta_oe_marte*180/pi);
    
    disp("--- Tempos (dias) ---");
    disp("Viagem OE-SOI(Terra): " + t_oe_terra_soi_terra);
    if venus_swing_by == 1
        disp("Viagem SOI(Terra)-SOI(Venus): " + t_soi_terra_soi_venus);
        disp("Viagem swing-by: " + t_soi_venus_soi_venus);
        disp("Viagem SOI(Venus)-SOI(Marte): " + t_soi_venus_soi_marte);
        disp("Viagem SOI(Marte)-OE(Marte): " + t_soi_marte_oe_marte);
        disp("Tempo total de viagem: " + sum(best_global(8:12)));
    else
        disp("Viagem SOI(Terra)-SOI(Marte): " + t_soi_venus_soi_marte);
        disp("Viagem SOI(Marte)-OE(Marte): " + t_soi_marte_oe_marte);
        disp("Tempo total de viagem: " + sum([...
            best_global(9),...
            best_global(11),...
            best_global(12)])...
        );
    end
    
    disp("--- Custos (km/s) ---");
    disp("Sa�da Terra " + deltaV(1));
    if venus_swing_by == 1
        disp("SOI(Terra) " + deltaV(2));
        disp("Entrada SOI(Venus) " + deltaV(3));
        disp("Sa�da SOI(Venus) " + deltaV(4));
        disp("SOI(Marte) " + deltaV(5));
        disp("Chegada Marte " + deltaV(6));
    else
        disp("SOI(Terra) " + deltaV(2));
        disp("SOI(Marte) " + deltaV(3));
        disp("Chegada Marte " + deltaV(4));
    end
end

% Axis equal
lim = 1.6;
xlim([-lim lim]);
ylim([-lim lim]);

function [x,y] = definir_orbita_cartesiana(r_,v_,mi_)

r = orbita_from_rv(r_, v_, mi_);
theta = pi/180:pi/180:2*pi;
raio = r(theta);
x = raio.*cos(theta);
y = raio.*sin(theta);

end
