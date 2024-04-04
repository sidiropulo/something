function SignalSpectrum = SignalSpectrum(signal, spectrumLength)
    SignalSpectrum = fft(signal,spectrumLength);
    SignalSpectrum = FlattopWin(SignalSpectrum);
    % Нормирование спектра сигнала по амплитуде
    amplitude_factor = 2 / spectrumLength;
    SignalSpectrum = amplitude_factor*abs(SignalSpectrum);
    % Нормирование постоянной составляющей сигнала
    SignalSpectrum(1) = SignalSpectrum(1)/2;
end

