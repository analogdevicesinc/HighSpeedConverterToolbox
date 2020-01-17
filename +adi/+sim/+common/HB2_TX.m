function Filter = HB2_TX()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRInterpolator;
Filter.InterpolationFactor = 2;
Filter.Numerator =  [496, 0, -3503, 0, 19392, 32768, 19392, 0, -3503, 0,...
    496]/32768;
% Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

