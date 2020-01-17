function Filter = HB3()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type.
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type.

Filter = dsp.FIRDecimator;
Filter.DecimationFactor = 2;
Filter.Numerator = [-111, 0, 924, 0, -4156, 0, 19727, 32768, 19727, 0,...
    -4156, 0, 924, 0, -111];
Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;

end

