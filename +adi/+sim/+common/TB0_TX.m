function Filter = TB0_TX()

% NOTES:
% When at least one of the inputs to the multiplier is real, the output of the multiplier is in the product output data type. 
% When both inputs to the multiplier are complex, the result of the multiplication is in the accumulator data type. 

Filter = dsp.FIRInterpolator;
Filter.InterpolationFactor = 3;
Filter.Numerator =  [-2, -3,  0,  8, 11,  0,  -22,  -29,  0, 50 ...
  64,  0, -100, -123,  0,  183,  220,  0, -313, -369,  0 ...
  508,  591,  0, -794, -916,  0, 1214, 1396,  0 -1853 -2143 ...
  0, 2917, 3453,  0 -5114 -6528, 0, 13424, 27036, 32768, 27036 ...
  13424,  0, -6528, -5114,  0, 3453, 2917, 0, -2143, -1853,  0 ...
  1396, 1214,  0, -916, -794,  0,  591,  508,  0, -369, -313 ...
  0,  220,  183,  0, -123, -100,  0, 64, 50,  0,  -29 ...
  -22,  0, 11,  8,  0, -3, -2]/32768;
% Filter.Numerator = Filter.Numerator./sum(Filter.Numerator);

%% Full precision calculations, cast is done externally
Filter.FullPrecisionOverride = true;


end

