function Filter = HB4()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRDecimator;
Filter.DecimationFactor = 2;
Filter.Numerator = [1746, 0, -13400, 0, 77190, 131072, 77190, 0, -13400,...
    0, 1746];
Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;

end

