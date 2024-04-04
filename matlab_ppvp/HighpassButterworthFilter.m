function FilteredSignal = HighpassButterworthFilter(Signal, samplingFrequency, cutoffFrequency)
    % ������� �����, ������������� �� ������� ���������
    norm_cutoff_frequency = (2*cutoffFrequency)/samplingFrequency;
    if 0 >= norm_cutoff_frequency || norm_cutoff_frequency >=1 
        throw(MException('ButterworthFilter:CutoffFrequencyOutOfRange',...
                    '������� ����� %f ��� ������� (0 samplingFrequency(%f)).', ...
                    cutoffFrequency, samplingFrequency)); 
    end
    
    % ������ ������� ������� ������ ����������� 1-�� �������
    % b � a - ������������ ��������� ��������� � ����������� ������� 
    % �������� � ������� �������� �������� ���������� z:
    [b,a] = butter(1,norm_cutoff_frequency,'high');
    
    % ���������� �������
    FilteredSignal = filter(b,a,Signal);
end

