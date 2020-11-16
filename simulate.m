%% function value = funcao_custo(x)
% Funcao para calculo do custo total de transferencia interplanetaria
%   Considera-se 4 pontos principais, com 3 orbitas coladas, portanto
%   Ex.: x = [  ];

%% Inicializa��es
global venus_swing_by parametro
parametro = 0;
banco_velocidades_chegada = [];
banco_velocidades_saida = [];
banco_velocidades_inicial = [];

base = [1 0 0];             % Vetor de refer�ncia da base can�nica de R3
M = @(a)[ cos(a)  sin(a)  0;
          -sin(a) cos(a)  0;
          0       0       1
        ];                  % Matriz de rota��o

deltaV = [];                % Matriz de custo (|V_i|)_i

% Carrega dados de refer�ncia
dados;

%% Par�metros
% Posi��o dos planetas
phase_terra = 0;
phase_marte = pega_parametro(x);

if venus_swing_by == 1
    phase_venus = pega_parametro(x);
    % Tempos de transfer�ncia
    t_terra_venus = pega_parametro(x);
    t_venus_marte = pega_parametro(x);
    % Par�metros do swingby
    rp = pega_parametro(x) * R_soi_venus;
else
    phase_venus = 0;
    t_terra_marte = pega_parametro(x);
end

%% Defini��es base
% Posi��es e velocidades dos planetas em relacao ao Sol
r_terra_sol = r_st * base*M(phase_terra);
r_venus_sol = r_sv * base*M(phase_venus);
r_marte_sol = r_sm * base*M(phase_marte);
v_terra_sol = (mi_sol/norm(r_terra_sol))^(0.5)*base*M(phase_terra + pi/2);
v_venus_sol = (mi_sol/norm(r_venus_sol))^(0.5)*base*M(phase_venus + pi/2);
v_marte_sol = (mi_sol/norm(r_marte_sol))^(0.5)*base*M(phase_marte + pi/2);

omega = @(r,v) (cross(r,v)/norm(r)^2);
omega_terra_sol = omega(r_terra_sol, v_terra_sol);
omega_venus_sol = omega(r_venus_sol, v_venus_sol);
omega_marte_sol = omega(r_marte_sol, v_marte_sol);


%% C�lculo dos custos

if venus_swing_by == 1
    %% 1. Transfer�ncia Terra-V�nus
    % Referencial: Sol
    r_saida = r_terra_sol;
    r_chegada = r_venus_sol;
    t_voo = t_terra_venus;
    GM = mi_sol;
    [v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
    
    banco_velocidades_chegada(end+1,:) = v_chegada;
    banco_velocidades_saida(end+1,:) = v_saida;
    
    %deltaV(end+1) = norm(v_saida - v_terra_sol);
    
    v_inicial = sqrt(mi_terra/R_oe_terra);
    v_inf = v_saida - v_terra_sol;
    v_saida = sqrt(norm(v_inf)^2 + 2*mi_terra/R_oe_terra);
    
    deltaV(end+1) = norm(v_saida - v_inicial);
    
    %% 2. Venus swing by
    omega = omega_venus_sol;
    v_inf = v_chegada - cross(omega, r_venus_sol);  % V espa�onave em rel a Venus
    
    sin_deflexao_venus = 1/(1 + rp*norm(v_inicial)/mi_venus);
    deflexao_venus = asin(sin_deflexao_venus);
    
    v_p_versor = v_inf/norm(v_inf)*M(deflexao_venus);
    v_p = sqrt(norm(v_inf)^2 + 2*mi_venus/(R_v + rp))*v_p_versor;
    
    v_chegada = v_inf*M(2*deflexao_venus);  % V espa�onave no final do swing by

    %% 3. Transfer�ncia Venus-Marte
    % Mudan�a de referencial: V�nus -> Sol
    r_saida = r_venus_sol;
    r_chegada = r_marte_sol;
    v_inicial = v_chegada + cross(omega, r_venus_sol);  % V espa�onave em rel ao Sol
    t_voo = t_venus_marte;
    GM = mi_sol;
    [v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
    
    banco_velocidades_chegada(end+1,:) = v_chegada;
    banco_velocidades_saida(end+1,:) = v_saida;
    
    v_p_inicial = v_p; % ref em venus
    v_inf = v_saida - v_venus_sol; % ref em venus
    v_p_saida = sqrt(norm(v_inf)^2 + 2*mi_venus/(R_v + rp))*v_p_versor;
    
    % Impulso no periapsis de Venus durante o swing by
    %deltaV(end+1) = norm(v_p_saida - v_p_inicial);
    
    % Impulso na sa�da da SOI de Venus ap�s o swing by
    deltaV(end+1) = norm(v_saida - v_inicial);
else
    %% 1. Transfer�ncia Terra-Marte
    % Referencial: Sol
    r_saida = r_terra_sol;
    r_chegada = r_marte_sol;
    t_voo = t_terra_marte;
    GM = mi_sol;
    [v_saida, v_chegada, extremal_distances, exitflag] = lambert(r_saida, r_chegada, t_voo, 0, GM);
    
    v_inicial = sqrt(mi_terra/R_oe_terra);
    v_inf = v_saida - v_terra_sol;
    v_final = sqrt(norm(v_inf)^2 + 2*mi_terra/R_oe_terra);
    
    deltaV(end+1) = norm(v_final - v_inicial);
    banco_velocidades_chegada(end+1,:) = v_chegada;
    banco_velocidades_inicial(end+1,:) = v_inicial;
    banco_velocidades_saida(end+1,:) = v_saida;    
end

%% 4/2. Chegada em Marte
v_inf = v_chegada - v_marte_sol; % v_inf hiperb�lica de chegada em marte
v_p = sqrt(norm(v_inf)^2 + 2*mi_marte/R_oe_marte);
v_inicial = norm(v_p);
v_final = sqrt(mi_marte/R_oe_marte); % v_p necessaria para ser capturada

deltaV(end+1) = norm(v_final - v_inicial);
%deltaV(end+1) = norm(v_chegada - v_marte_sol);

%% C�lculo custo final
value = sum(deltaV);

if (isnan(value))
    value = Inf;
end

function valor = pega_parametro(x)
    global parametro;
    parametro = parametro + 1;
    valor = x(parametro);
end