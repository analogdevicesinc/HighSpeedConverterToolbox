function Filter = HB0_TX()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRInterpolator;
Filter.InterpolationFactor = 2;
Filter.Numerator = [-3 0 12 0 -31 0 68 0 -133 0 238 0 -400 0 641 0 -994 ...
    0 1512 0 -2308 0 3665 0 -6638 0 20754 2^15 20754 0 -6638 0 3665 0 ...
    -2308 0 1512 0 -994 0 641 0 -400 0 238 0 -133 0 68 0 -31 0 12 0 -3]/2^15;
% Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

