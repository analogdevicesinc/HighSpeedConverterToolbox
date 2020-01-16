function Filter = TB1_TX()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRInterpolator;
Filter.InterpolationFactor = 3;
Filter.Numerator =  [7 13 0 -56 -96 0 256 392 0 -863 -1272 0 3156 6656 ...
    8192 6656 3156 0 -1272 -863 0 392 256 0 -96 -56 0 13 7]/8192;
% Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

