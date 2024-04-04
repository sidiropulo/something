function SignalSpectrum = SignalSpectrum(signal, spectrumLength)
    SignalSpectrum = fft(signal,spectrumLength);
    SignalSpectrum = FlattopWin(SignalSpectrum);
    % ������������ ������� ������� �� ���������
    amplitude_factor = 2 / spectrumLength;
    SignalSpectrum = amplitude_factor*abs(SignalSpectrum);
    % ������������ ���������� ������������ �������
    SignalSpectrum(1) = SignalSpectrum(1)/2;
end

