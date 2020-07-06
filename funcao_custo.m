%% function value = funcao_custo(x)
% Funcao para calculo do custo total de transferencia interplanetaria
%   Considera-se 4 pontos principais, com 3 orbitas coladas, portanto
%   Ex.: x = [  ];

% Carrega dados de refer�ncia
dados;

% Posi��o dos planetas
theta_oe_terra = x(1);
theta_soi_terra = x(2);
phase_terra = 0;

theta_soi_venus = x(3);
r_p = x(4)*R_soi_venus;
phase_venus = x(5); 

theta_soi_marte = x(6);
theta_oe_marte = x(7);
phase_marte = x(8);

% Tempos de transfer�ncia
t_oe_terra_soi_terra = x(9);
t_soi_terra_soi_venus = x(10);
t_soi_venus_soi_marte = x(11);
t_soi_marte_oe_marte = x(12);

base = [1 0 0];             % Vetor de refer�ncia da base can�nica de R3
M = @(a)[ cos(a)  sin(a)  0;
          -sin(a) cos(a)  0;
          0       0       1
        ];                  % Matriz de rota��o
deltaV = zeros(5,1);        % Matriz de custo [|V_a|, |V_b|, |V_c|, |V_d|]

% Em rela��o � Terra
r_oe_terra = R_soi_terra * base * M(theta_oe_terra);  % Definida em projeto
r_soi_terra = R_oe_terra * base * M(theta_soi_terra);  % SOI da Terra

% Em rela��o � Venus
r_soi_venus = R_soi_venus * base * M(theta_soi_venus);  % Definida em projeto

% Em rela��o � Marte
r_soi_marte = R_soi_marte * base * M(theta_soi_marte);  % Definida em projeto
r_oe_marte = R_oe_marte * base * M(theta_oe_marte);  % SOI de Marte

% Posi��es e velocidades dos planetas em relacao ao Sol
r_terra_sol = r_st * base*M(phase_terra);
r_venus_sol = r_sv * base*M(phase_venus);
r_marte_sol = r_sm * base*M(phase_marte);
v_terra_sol = (mi_sol/norm(r_terra_sol))^(0.5)*base*M(phase_terra + pi/2);
v_venus_sol = (mi_sol/norm(r_venus_sol))^(0.5)*base*M(phase_venus + pi/2);
v_marte_sol = (mi_sol/norm(r_marte_sol))^(0.5)*base*M(phase_marte + pi/2);

%% Transfer�ncia Terra - SOI(Terra)
% Em torno da Terra
r_saida = r_oe_terra;
r_chegada = r_soi_terra;
t_voo = t_oe_terra_soi_terra;
GM = mi_terra;
[v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
v_inicial = (mi_terra/norm(r_saida))^(0.5)*[-sin(theta_oe_terra) cos(theta_oe_terra) 0];
if (norm(v_saida - v_inicial) > norm(-v_saida - v_inicial))
    v_inicial = -v_inicial;
end
deltaV(1) = norm(v_saida - v_inicial);

%% Transfer�ncia SOI(Terra)-SOI(V�nus)
% Mudan�a de referencial: Terra -> Sol
v_inicial = v_chegada + v_terra_sol;  % V espa�onave em rel ao Sol
r_saida = r_soi_terra + r_terra_sol;
r_chegada = r_soi_venus + r_venus_sol;
t_voo = t_soi_terra_soi_venus;
GM = mi_sol;
[v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
deltaV(2) = norm(v_saida - v_inicial);

%% Swing by por V�nus
% Mudan�a de referencial: Sol -> V�nus
v_inicial = v_chegada - v_venus_sol;  % V espa�onave em rel a Venus

% N�o tem propuls�o, apenas deflex�o de �rbita
deflexao = asin(1/(1 + r_p * norm(v_inicial) / mi_venus));
sin_deflexao = 1/(1 + r_p * norm(v_inicial) / mi_venus);
assistencia = 2 * v_inicial * sin_deflexao;
v_saida = v_inicial + v_venus_sol;    % V espa�onave em rel ao Sol
v_chegada = v_saida + assistencia;    % V espa�onave em rel ao Sol


%% Transfer�ncia SOI(Venus)-SOI(Marte)
% Mudan�a de referencial: V�nus -> Sol
v_inicial = v_chegada;                % V espa�onave em rel ao Sol
r_saida = r_soi_venus + r_venus_sol;
r_chegada = r_soi_marte + r_marte_sol;
t_voo = t_soi_venus_soi_marte;
GM = mi_sol;
[v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
deltaV(3) = norm(v_saida - v_inicial);

%% Transfer�ncia SOI(Marte)-Marte
% Mudan�a de referencial: Sol -> Marte
v_inicial = v_chegada - v_marte_sol;  % V em rel a Marte
r_saida = r_soi_marte;
r_chegada = r_oe_marte;
t_voo = t_soi_marte_oe_marte;
GM = mi_marte;
[v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
deltaV(4) = norm(v_saida - v_inicial);

%% �rbita estacionamento Marte
v_inicial = v_chegada;
v_final = (mi_marte/norm(r_chegada))^(0.5)*[-sin(theta_oe_marte) cos(theta_oe_marte) 0];
if (norm(v_final - v_inicial) > norm(-v_final - v_inicial))
    v_final = -v_final;
end
deltaV(5) = norm(v_final - v_inicial);

%% C�lculo custo final
value = sum(deltaV);

if (isnan(value))
    value = Inf;
end
