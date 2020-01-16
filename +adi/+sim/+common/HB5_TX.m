function Filter = HB5_TX()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRInterpolator;
Filter.InterpolationFactor = 2;
Filter.Numerator =  [-1 0 18 0 -112 0 607 1024 607 0 -112 0 18 0 -1]/1024;
% Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

