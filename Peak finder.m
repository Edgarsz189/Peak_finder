%El siguiente algoritmo encuentra el pico de dos se�ales card�acas (ECG y pulso), 
%calcula el tiempo de transito del pulso y con ello la velocidad de onda
%de pulso, tambi�n calcula la frecuencia card�aca latido a latido a partir
%del ECG.
close all;
clear Estado Flag ECG Pulse S_ECG S_Pulse ECG Pulse t N Distancia N_Muestras Tin Tfin Tventana 
clear Tolerancia Tin Tfin Tventana Delta Delta1 A_ECG A_Pulse C d_ECG d_Pulse m_ECG
clear m_Pulse meandelta meanPWV Num_ventana op op1 op4 op5 PWV S_ECG_A S_Pulse_A t1
clear T_ECG T_Pulse 
Estado      = 0 ;                   % Inicializo variable Estado
ECG         = 1;                    % seleccionar canal de cada se�al
Pulse       = 2;
Tventana    = 600;                  % tama�o de ventana (N�mero de muestras)
Tolerancia  = 200;
Tin         = 93610;                % N�mero de muestra inicial 
Tfin        = 5;                    % tiempo final (segundos)
N_Muestras  = Tfin*(600);           % Calcula el n�mero de muestras
Distancia	= 0.69;                 % Distancia del coraz�n a la mu�eca
S_ECG       = yout(:,ECG);          % se�al de ECG
S_Pulse     = yout(:,Pulse);        % se�al de pulso
S_ECG       = S_ECG(Tin:Tin+N_Muestras);    % recorto se�al (Tfin segundos)
S_Pulse     = S_Pulse(Tin:Tin+N_Muestras);  % recorto se�al (Tfin segundos)
t           = 0:(1/600):(Tfin);       % Vector de tiempo
N           = length(S_ECG);        % Calcula tama�o de la se�ales
C           = 1;
P_ECG       = 0;
P_Pulse     = 0;
Num_ventana = 0;

Flag        = 1;                    % Inicializo variable Flag
while Flag                          % Mientras Flag = 1 entra al ciclo
    switch Estado
        case 0                                  % En el primer estado (0) recorta se�al y calcula su media y desviaci�n estandar
            if Num_ventana < 10
                if (C + Tventana-1)  > (N-1)
                    break 
                end
                S_ECG_A(1:Tventana) = S_ECG(C: C + Tventana-1);    % Recorto se�al al tama�o de ventana 
                S_Pulse_A(1:Tventana) = S_Pulse(C: C + Tventana-1);  % Recorto se�al al tama�o de ventana
                %C = Num_ventana*(Tventana) +1;
                d_ECG = std(S_ECG_A);               % calcula la desviaci�n est�ndar de los datos
                m_ECG = mean(S_ECG_A);              % calcula la media de los datos
                d_Pulse = std(S_Pulse_A);           % calcula la desviaci�n est�ndar de la se�al de pulso
                m_Pulse = mean(S_Pulse_A);          % calcula la media de la se�al de pulso 
                Num_ventana = Num_ventana + 1;      % incremento numero de ventana
                Estado = 1;                         % Cambio de estado
                
            else 
                Flag = 0;                           % Termina an�lisis
            end
        case 1                                  % En el estado 1 Buscar� pico en se�al de ECG
            C = C +1 ;                          % Incremento Contador
            if S_ECG(C)>= m_ECG + 2*d_ECG & S_ECG(C+1)< S_ECG(C) & S_ECG(C-1)<= S_ECG(C) & S_ECG(C)< 3 & S_ECG(C)>.5 % Busca pico 
                P_ECG = P_ECG +1;               % Incremento n�mero de picos
                A_ECG(P_ECG) = S_ECG(C);      % Guardo amplitud de pico
                T_ECG(P_ECG) = C;               % Guardo tiempo en que ocurrio el pico
                Estado = 2;                     % Cambio de estado
            end
            if C == Num_ventana*(Tventana-1)
                Estado = 0;                     % Cambio de estado
            end
            
        case 2                                  % En el estado 2 Buscar� pico en se�al de pulso
            C = C +1 ;                          % Incremento Contador
            if S_Pulse(C)>= 1*d_Pulse + m_Pulse & S_Pulse(C+1)< S_Pulse(C) & S_Pulse(C-1)<=S_Pulse(C)  & S_Pulse(C)<5 & S_Pulse(C)>.5% Busca pico & C>(M(pico)+ 50) & C< (M(pico)+500)
                P_Pulse = P_Pulse +1;           % Incremento n�mero de picos
                A_Pulse(P_Pulse) = S_Pulse(C);  % Guardo amplitud de pico
                T_Pulse(P_Pulse) = C;           % Guardo tiempo en que ocurrio el pico
                Delta(P_Pulse) = T_Pulse(P_Pulse) - T_ECG(P_ECG); % Calcula Retardo
                Estado = 0;                     % Cambia de estado
            end
%             if C == Tventana -1
%                 Estado = 0;                     % Cambio de estado
%             end
        otherwise
      
    end  
end

    plot(t,S_ECG)                           % Grafica la se�al de ECG
    xlabel('Tiempo(s)')                 % Etiqueta el eje horizontal
    ylabel('Amplitud (V)')
    hold on
    plot(T_ECG*(1/600) -(1/600),A_ECG,'v')      % Grafica sobre la se�al de ECG las posiciones de los picos
    hold off
%   
    figure 
    plot(t,S_Pulse)                           % Grafica la se�al de pulso  
    xlabel('Tiempo(s)')                 % Etiqueta el eje horizontal
    ylabel('Amplitud (V)')
    hold on
    plot(T_Pulse*(1/600)-(1/600) ,A_Pulse,'v')    % Grafica sobre la se�al de pulso las posiciones de los picos
    hold off
%   
    figure                              % Grafica ambas se�ales con la detecci�n de sus picos:
    plot(t,S_ECG)
    hold on
    plot(T_ECG*(1/600) -(1/600),A_ECG,'v') 
    plot(t,S_Pulse,'k')
    hold on
    plot(T_Pulse*(1/600)-(1/600) ,A_Pulse,'v') 
    xlabel('Tiempo(s)')                 % Etiqueta el eje horizontal
    ylabel('Amplitud (V)')
    hold off
   
    figure
    Delta1 = Delta;                     % Guardo los retardos en una variable auxiliar
    Delta1 = Delta1.*(1/600);           % los convierto a tiempo (segundos)
    t1= 0:(Tfin/(length(Delta) - 1)):Tfin;    % Vector de tiempo
    plot(t1, Delta1)                    % Gr�fico delta1 (Retardo)
    stddelta = std(Delta1);             % calculo desviaci�n estandar 
    meandelta = mean(Delta1);           % calculo media
    hold on
    op= ones(length(Delta),1);
    op1 = op.*(meandelta);
    plot(t1,op1)                        % Grafico la media sobre la gr�fica anterior
    xlabel('tiempo (s)'); % etiqueta de eje x
    ylabel(' Retardo(s)');              % etiqueta de eje y
%Calculo de la velocidad de onda de pulso:
    PWV = Distancia./Delta1;            % Calcula velocidad de onda de pulso
    meanPWV = mean(PWV);                % Calcula la media 
    stdPWV = std(PWV);                  % Calcula desviaci�n est�ndar
    figure
    plot(t1, PWV)
    xlabel('Tiempo (s)');               % etiqueta de eje x
    ylabel('Velocidad de onda de pulso (m/s)');% etiqueta de eje y
    hold on
    op4= ones(length(PWV),1);
    op5 = op4.*(meanPWV);
    plot(t1,op5)
%Frecuencia card�aca media:
%     fs =600;                            % frecuencia de muestreo
%     ts = 1/fs;                          % periodo de muestreo
%     Tmax = (N-1)*ts;                    % calcula el tiempo m�ximo de adquisici�n
%     frec=(pico*60)/Tmax ;               % calcula frecuencia cardiaca 