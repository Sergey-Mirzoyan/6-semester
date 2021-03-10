function lab2()
    clear all;
    
    %Мат. ожидание
    function mu = expect(X)
        mu = mean(X); %mean - арифмитичекое среднее элементов массива
    end
    %Дисперсия
    function sSqr = variance(X)
        sSqr = var(X); %var - возвращает дисперсию ээлементов массива
    end
    %Массив мат. ожиданий
    function muArray = expectMas(X, N)
        muArray = [];
        for i = N
            muArray = [muArray, mean(X(1:i))];
        end
    end
    %Массив дисперсий 
    function varArray = varianceArray(X, N)
        varArray = [];
        for i = N
            varArray = [varArray, var(X(1:i))];
        end
    end

    X = [11.89,9.60,9.29,10.06,9.50,8.93,9.58,6.81,8.69,9.62,9.01,10.59,10.50,11.53,9.94,8.84,8.91,6.90,9.76,7.09,11.29,11.25,10.84,10.76,7.42,8.49,10.10,8.79,11.87,8.77,9.43,12.41,9.75,8.53,9.72,9.45,7.20,9.23,8.93,9.15,10.19,9.57,11.09,9.97,8.81,10.73,9.57,8.53,9.21,10.08,9.10,11.03,10.10,9.47,9.72,9.60,8.21,7.78,10.21,8.99,9.14,8.60,9.14,10.95,9.33,9.98,9.09,10.35,8.61,9.35,10.04,7.85,9.64,9.99,9.65,10.89,9.08,8.60,7.56,9.27,10.33,10.09,8.51,9.86,9.24,9.63,8.67,8.85,11.57,9.85,9.27,9.69,10.90,8.84,11.10,8.19,9.26,9.93,10.15,8.42,9.36,9.93,9.11,9.07,7.21,8.22,9.08,8.88,8.71,9.93,12.04,10.41,10.80,7.17,9.00,9.46,10.42,10.43,8.38,9.01];
    
    N = 10:100;
    %N = 1:40
    
    gamma = 0.99;
    alpha = (1 - gamma)/2;
    
    %Подсчет мат.ожидания и дисперсии
    mu = expect(X);
    sSqr = variance(X); 

    muArray = expectMas(X, N);
    varArray = varianceArray(X, N);
 
    figure
    plot([N(1), N(end)], [mu, mu], 'm');
    hold on;
    plot(N, muArray, 'g');
    
    %tinv - возвращает обратную кумулятивную функцию распределения 
    %(icdf) распределения t Студента
    Ml = muArray - sqrt(varArray./N).*tinv(1 - alpha, N - 1); 
    Mh = muArray + sqrt(varArray./N).*tinv(1 - alpha, N - 1);
    
    plot(N, Ml, 'b');
    plot(N, Mh, 'r');
    grid on;
    hold off;

    fprintf('µ = %.2f\n', mu); 
    fprintf('S^2 = %.2f\n\n', sSqr);
    fprintf('µ_low = %.2f\n', Ml(end));
    fprintf('µ_high = %.2f\n', Mh(end));

    
    figure
    plot([N(1), N(end)], [sSqr, sSqr], 'm');
    hold on;
    
    %chi2inv - возвращает обратную кумулятивную функцию распределения 
    %(icdf) распределения хи-квадрат со степенями свободы nu
    Sl = varArray.*(N - 1)./chi2inv(1 - alpha, N - 1); 
    Sh = varArray.*(N - 1)./chi2inv(alpha, N - 1);
    plot(N, varArray, 'g');
    plot(N, Sl, 'b');
    plot(N, Sh, 'r');
    grid on;
    hold off;
    fprintf('sigma^2_low = %.2f\n', Sl(end));
    fprintf('sigma^2_high = %.2f\n', Sh(end));
end
