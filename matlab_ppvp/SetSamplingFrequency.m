function ActualSamplingFrequency = SetSamplingFrequency(session, samplingFrequency)
    % Если указанная частота дискретизации является допустимой для АЦП
    if (session.RateLimit(1)<samplingFrequency) && (samplingFrequency<session.RateLimit(2))
        % Частота дискретизации выставляется с помощью делителя максимальной
        % частоты дискретизации устройства
        % При этом делитель должен быть степенью 2
        frequency_divider = 2^nextpow2(round(session.RateLimit(2)/samplingFrequency));
        session.Rate = session.RateLimit(2)/frequency_divider;
        
    elseif  samplingFrequency<=session.RateLimit(1)
        % Если указанная частота дискретизации меньше минимально допустимой для АЦП
        session.Rate = session.RateLimit(1);
    else
        % Если указанная частота дискретизации больше максимально допустимой для АЦП
        session.Rate = session.RateLimit(2);
    end
    
    ActualSamplingFrequency = session.Rate;
end

