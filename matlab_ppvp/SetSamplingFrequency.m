function ActualSamplingFrequency = SetSamplingFrequency(session, samplingFrequency)
    % ���� ��������� ������� ������������� �������� ���������� ��� ���
    if (session.RateLimit(1)<samplingFrequency) && (samplingFrequency<session.RateLimit(2))
        % ������� ������������� ������������ � ������� �������� ������������
        % ������� ������������� ����������
        % ��� ���� �������� ������ ���� �������� 2
        frequency_divider = 2^nextpow2(round(session.RateLimit(2)/samplingFrequency));
        session.Rate = session.RateLimit(2)/frequency_divider;
        
    elseif  samplingFrequency<=session.RateLimit(1)
        % ���� ��������� ������� ������������� ������ ���������� ���������� ��� ���
        session.Rate = session.RateLimit(1);
    else
        % ���� ��������� ������� ������������� ������ ����������� ���������� ��� ���
        session.Rate = session.RateLimit(2);
    end
    
    ActualSamplingFrequency = session.Rate;
end

