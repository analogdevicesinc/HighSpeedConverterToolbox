function Filter = HB1_TX()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRInterpolator;
Filter.InterpolationFactor = 2;
Filter.Numerator =  [4 0 -33 0 144 0 -448 0 1152 0 -2819 0 10192 2^14 ...
    10192 0 -2819 0 1152 0 -448 0 144 0 -33 0 4]/2^14;
% Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

