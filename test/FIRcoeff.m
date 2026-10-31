function [hex_I, hex_Q] = FIRcoeff(taps)
% FIRcoeff  Quantize filter taps to Q15 hex and return I/Q columns.
%   [hex_I, hex_Q] = FIRcoeff(taps)
%
%   Real taps:    hex_I = hex_Q (duplicated)
%   Complex taps: hex_I = real part, hex_Q = imaginary part
%
%   Quantization: scale by 2^15, clamp to int16 range [-32768, 32767]

    scale = 2^15;

    % Quantize real part
    i_scaled = round(scale * real(taps));
    i_scaled = max(min(i_scaled, 32767), -32768);
    hex_I = dec2hex(double(typecast(int16(i_scaled), 'uint16')), 4);

    % Quantize imaginary part (zero if taps are real)
    if ~isreal(taps)
        q_scaled = round(scale * imag(taps));
        q_scaled = max(min(q_scaled, 32767), -32768);
        hex_Q = dec2hex(double(typecast(int16(q_scaled), 'uint16')), 4);
    else
        hex_Q = hex_I;
    end
end
