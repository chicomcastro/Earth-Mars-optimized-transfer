function tetafin = posicaomarte(tetaini,t)

T_marte = 686.971; %per�odo orbital de Marte
deltateta = 2*pi/T_marte*t;
tetafin = tetaini+deltateta; %posi��o final de Marte

end