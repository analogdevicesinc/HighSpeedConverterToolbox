function Filter = HB1()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRDecimator;
Filter.DecimationFactor = 2;
Filter.Numerator = [-12, 0, 44, 0, -116, 0, 258, 0, -516, 0, 948, 0,...
    -1632, 0, 2670, 0, -4185, 0, 6336, 0, -9328, 0, 13458, 0, -19188,...
    0, 27348, 0, -39700, 0, 60822, 0, -107602, 0, 332537, 524288, ...
    332537, 0, -107602, 0, 60822, 0, -39700, 0, 27348, 0, -19188, 0,...
    13458, 0, -9328, 0, 6336, 0, -4185, 0, 2670, 0, -1632, 0, 948, 0,...
    -516, 0, 258, 0, -116, 0, 44, 0, -12];
Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

