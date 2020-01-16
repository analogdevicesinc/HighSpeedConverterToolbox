function Filter = HB2()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRDecimator;
Filter.DecimationFactor = 2;
Filter.Numerator = [180  0  -1410  0, 5990, 0, -19477, 0, 80254, 131072,...
    80254, 0, -19477, 0, 5990, 0, -1410, 0, 180];
Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;

end

