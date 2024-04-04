function [Windowed_Spec] = FlattopWin(Spec)

%  Given an input spectral sequence 'Spec', that is the 
%  FFT of some time sequence 'x', FlattopWin(Spec) 
%  returns a spectral sequence that is equivalent
%  to the FFT of a flat-top windowed version of time 
%  sequence 'x'.  The peak magnitude values of output 
%  sequence 'Windowed_Spec' can be used to accurately 
%  estimate the peak amplitudes of sinusoidal components 
%  in time sequence 'x'.

%   Input: 'Spec' (a sequence of complex FFT sample values)
%
%   Output: 'Windowed_Spec' (a sequence of complex flat-top  
%                            windowed FFT sample values)
%
%   Based on Lyons': "Reducing FFT Scalloping Loss Errors 
%   Without Multiplication", IEEE Signal Processing Magazine, 
%   DSP Tips & Tricks column, March, 2011, pp. 112-116.
%
%   Richard Lyons [December, 2011]

N = length(Spec);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Perform freq-domain convolution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g_Coeffs = [1, -0.94247, 0.44247];

% Compute first two convolved spec samples using spectral 'wrap-around'
Windowed_Spec(1) = g_Coeffs(3)*Spec(N-1) ...
    +g_Coeffs(2)*Spec(N) + Spec(1) ...
    +g_Coeffs(2)*Spec(2) + g_Coeffs(3)*Spec(3);

Windowed_Spec(2) = g_Coeffs(3)*Spec(N) ...
    +g_Coeffs(2)*Spec(1) + Spec(2) ...
    +g_Coeffs(2)*Spec(3) + g_Coeffs(3)*Spec(4);

% Compute last two convolved spec samples using spectral 'wrap-around'
Windowed_Spec(N-1) = g_Coeffs(3)*Spec(N-3) ...
    +g_Coeffs(2)*Spec(N-2) + Spec(N-1) ...
    +g_Coeffs(2)*Spec(N) + g_Coeffs(3)*Spec(1);

Windowed_Spec(N) = g_Coeffs(3)*Spec(N-2) ...
    +g_Coeffs(2)*Spec(N-1) + Spec(N) ...
    +g_Coeffs(2)*Spec(1) + g_Coeffs(3)*Spec(2);

% Compute convolved spec samples for the middle of the spectrum
for K = 3:N-2
	Windowed_Spec(K) = g_Coeffs(3)*Spec(K-2) ...
        +g_Coeffs(2)*Spec(K-1) + Spec(K) ...
        +g_Coeffs(2)*Spec(K+1) + g_Coeffs(3)*Spec(K+2);
end % % End of 'Wind_Flattop(Spec)' function

