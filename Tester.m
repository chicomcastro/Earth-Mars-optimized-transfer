% Loads variables
simplePatchedConics;

% Test 1: Vetores a 90 graus
r1 = r_st*[1 0 0]; r2 = r_sm*[0 -1 0];
[V1, V2, extremal_distances, exitflag] = lambert(r1, r2, 9*30, 0, mi_terra)
plotter
hold on

% Test 2: vetores a 45 graus
r1 = r_st*[1 0 0]; r2 = r_sm*[1/2^0.5 -1/2^0.5 0];
[V1, V2, extremal_distances, exitflag] = lambert(r1, r2, 9*30, 0, mi_terra)
plotter

% Test 3: vetores a 180 graus (D� RUIM: V = NaN)
%r1 = r_ta*[1 0 0]; r2 = r_tb*[-1 0 0];
%[V1, V2, extremal_distances, exitflag] = lambert(r1, r2, 15, 0, mi_terra)
%plotter

%{
Observa��es:
- Quando os vetores est�o alinhados, a velocidade fica indefinida
- O tempo de voo muda a velocidade, n�o as caracter�sticas da �rbita
- Para m != 0, n�o h� solu��o
- extremal_distances � sempre a mesma (como se a elipse n�o mudasse para r1
e r2 se deslocando angularmente em uma circunfer�ncia predefinida)
- N�o encontrei garantia na documenta��o de que as solu��es seriam
elipticas, ser� que ser�o?
%}