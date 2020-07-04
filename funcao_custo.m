%function value = funcao_custo(x)
%Funcao para calculo do custo total de transferencia interplanetaria
%   Considera-se 4 pontos principais, com 3 orbita coladas, portanto
%   Uso: x = [ theta_a, theta_b, theta_c, theta_d, t_ab, t_bc, t_cd, phase_rel ]
%   Ex.: x = [ pi/2 -pi/2 pi/2 -pi/2 15 270 15 pi ];

% Posi��o dos planetas
phase_a = x(1);
phase_b = x(2);
phase_c = x(3);
phase_d = x(4);
phase_rel = x(8);

% Tempos de transfer�ncia
t_ab = x(5);
t_bc = x(6);
t_cd = x(7);

base = [1 0 0];             % Vetor de refer�ncia da base can�nica de R3
M = @(a)[ cos(a)  sin(a)  0;
          -sin(a) cos(a)  0;
          0       0       1
        ];                  % Matriz de rota��o
deltaV = zeros(4,1);        % Matriz de custo [|V_a|, |V_b|, |V_c|, |V_d|]

% Carrega dados de refer�ncia
dados;

% Em rela��o � Terra
r_a_terra = R_oe_terra * base * M(phase_a);  % Definida em projeto
r_b_terra = R_soi_terra * base * M(phase_b);  % SOI da Terra

% Em rela��o � Marte
r_c_marte = R_oe_marte * base * M(phase_c);  % SOI de Marte
r_d_marte = R_soi_marte * base * M(phase_d);  % Definida em projeto

% Posi��es e velocidades dos planetas em relacao ao Sol
phase_terra = -pi/2;
phase_marte = -pi/2 + phase_rel;
r_terra_sol = r_st * base*M(phase_terra);
r_marte_sol = r_sm * base*M(phase_marte);
v_terra_sol = (mi_sol/norm(r_terra_sol))^(0.5)*base*M(phase_terra + pi/2);
v_marte_sol = (mi_sol/norm(r_marte_sol))^(0.5)*base*M(phase_marte + pi/2);

% Transfer�ncia Terra - SOI(Terra)
% Em torno da Terra
r1 = r_a_terra;
r2 = r_b_terra;
t_voo = t_ab;
GM = mi_terra;
[V1, V2, extremal_distances, exitflag] = lambert(r1, r2, t_voo, 0, GM);
v_a_1 = (mi_terra/norm(r1))^(0.5)*[-sin(phase_a) cos(phase_a) 0];
v_a_2 = V1;
if (norm(v_a_2 - v_a_1) > norm(-v_a_2 - v_a_1))
    v_a_2= -v_a_1;
end
deltaV(1) = norm(v_a_2 - v_a_1);

% Transfer�ncia SOI(Terra)-SOI(Marte)
% Mudan�a de refencial: Terra -> Sol
v_b_1 = V2 + v_terra_sol;  % V em rel ao Sol
r_b_sol = r_b_terra + r_terra_sol;
r_c_sol = r_c_marte + r_marte_sol;

r1 = r_b_sol;
r2 = r_c_sol;
t_voo = t_bc;
GM = mi_sol;
[V1, V2, extremal_distances, exitflag] = lambert(r1, r2, t_voo, 0, GM);
v_b_2 = V1;
deltaV(2) = norm(v_b_2 - v_b_1);


% Transfer�ncia SOI(Marte)-Marte
% Mudan�a de referencial: Sol -> Marte
v_c_1 = V2 - v_marte_sol;  % V em rel a Marte
r1 = r_c_marte;
r2 = r_d_marte;
t_voo = t_cd;
GM = mi_marte;
[V1, V2, extremal_distances, exitflag] = lambert(r1, r2, t_voo, 0, GM);
v_c_2 = V1;
deltaV(3) = norm(v_c_2 - v_c_1);
v_d_1 = V2;

% �rbita estacionamento Marte
v_d_2 = (mi_marte/norm(r2))^(0.5)*[-sin(phase_d) cos(phase_d) 0];
if (norm(v_d_2 - v_d_1) > norm(-v_d_2 - v_d_1))
    v_d_2 = -v_d_2;
end
deltaV(4) = norm(v_d_2 - v_d_1);

value = sum(deltaV);

if (isnan(value))
    value = Inf;
end
