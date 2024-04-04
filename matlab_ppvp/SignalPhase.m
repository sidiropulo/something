function SignalPhase =  SignalPhase(signal,phaseLength)
    SignalPhase = unwrap(angle(FlattopWin(fft(signal, phaseLength))));
end

