function tetafin = posicaoterra(tetaini,t)

T_terra = 365.26; %per�odo orbital da Terra
deltateta = 2*pi/T_terra*t;
tetafin = tetaini+deltateta; %posi��o final da Terra

end