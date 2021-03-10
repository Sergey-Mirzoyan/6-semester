function lab1 ()
    function Mu = MathExpect(MyMassive)
         Mu = sum(MyMassive)/size(MyMassive, 2);
    end

    function Sigma = Dispersion(MyMassive)
        tmp = MathExpect(MyMassive);
        Sigma = sum((MyMassive - tmp) .* (MyMassive - tmp))/size(MyMassive, 2);
    end

    function countinterv = subIntervals(size)
        countinterv = floor(log2(size)) + 2; 
    end

    function Intervals(X, m)
        sortX = sort(X);
        n = size(sortX,2);
        delta = (sortX(end) - sortX(1)) / m;
        J = sortX(1):delta:sortX(end);
        numElem = zeros(1, m);

        for i = 1:n
            for j = 1:(size(J,2) - 1)
                if (sortX(i) >= J(j) && sortX(i) < J(j+1))
                    numElem(j) = numElem(j) + 1;
                    break;
                end
            end
        end
        numElem(end) = numElem(end) + 1;

        for i = 1:size(numElem,2)
            numElem(i) = numElem(i)/(n * delta);
        end
        J = [J(1) J];
        numElem = [0 numElem 0];

        stairs(J, numElem), grid;
    end

    function f(X, M, D, m, R)
            delta = R/m;
            Sigma = sqrt(D);
            Xn = min(X):delta/20:max(X);
            Y = normpdf(Xn, M, Sigma);
            plot(Xn, Y, '-*');
        end
    function F(X, MX, DX, m, R)
            delta = R/m;
            Xn = min(X):delta/20:max(X);
            Y = 1/2 * (1 + erf((Xn - MX) / sqrt(2*DX))); 

            plot(Xn, Y, '--');
    end
    function emprf(Mas)
        [eY, eX] = ecdf(sort(Mas));
        stairs(eX, eY)
    end
    
    clear all;
    
    MyMassive = [11.89,9.60,9.29,10.06,9.50,8.93,9.58,6.81,8.69,9.62,9.01,10.59,10.50,11.53,9.94,8.84,8.91,6.90,9.76,7.09,11.29,11.25,10.84,10.76,7.42,8.49,10.10,8.79,11.87,8.77,9.43,12.41,9.75,8.53,9.72,9.45,7.20,9.23,8.93,9.15,10.19,9.57,11.09,9.97,8.81,10.73,9.57,8.53,9.21,10.08,9.10,11.03,10.10,9.47,9.72,9.60,8.21,7.78,10.21,8.99,9.14,8.60,9.14,10.95,9.33,9.98,9.09,10.35,8.61,9.35,10.04,7.85,9.64,9.99,9.65,10.89,9.08,8.60,7.56,9.27,10.33,10.09,8.51,9.86,9.24,9.63,8.67,8.85,11.57,9.85,9.27,9.69,10.90,8.84,11.10,8.19,9.26,9.93,10.15,8.42,9.36,9.93,9.11,9.07,7.21,8.22,9.08,8.88,8.71,9.93,12.04,10.41,10.80,7.17,9.00,9.46,10.42,10.43,8.38,9.01];
    
    % Задание 1
    %% поиск Min и Max
    
    MinMas = min(MyMassive);
    MaxMas = max(MyMassive);
    
    %% размах R
    
    R = MaxMas - MinMas;
    
    %% оценки мат. ожидания и дисперсии
   
    Mu = MathExpect(MyMassive);
    Sigma = Dispersion(MyMassive);
    
    %% Интервалы
    
    countinterv = subIntervals(size(MyMassive, 2)); 
    
    %% график 1 
    %%% f(X, MX, DX, m, R) - Нормальная функция плотности вероятности
    Intervals(MyMassive, countinterv);
    hold on;
    f(MyMassive, Mu, (size(MyMassive,2)/(size(MyMassive,2) * Sigma)), countinterv, R);
    legend('Гистограмма','Функция плотности распределения нормальной случайной величины');
    hold off;

    %% график 2
    %%% F(X, MX, DX, m, R) - 
    figure;
    emprf(sort(MyMassive));
    hold on;
    F(sort(MyMassive), Mu, (size(MyMassive,2)/(size(MyMassive,2) * Sigma)), countinterv, R);
    grid on;
    legend('Эмпирическая функция распределения','Функция распределения нормальной случайной величины');
    hold off;
end