# AD9081 DAC


The DAC models are simplied behavioral implementations that are based on the currently estimated specifications of the data converters. They are designed to match the noise spectral density (NSD). Note that since physical hardware does not exist these are estimated values and will likely change by a few dB.


# Top-Level Control


There are one control properties related to the DACs: **SampleRate**.




**SampleRate** is the data rate of the converters themselves. Therefore, the input datarate of the model will be this **SampleRate** divided by the different interpolations used.



```python
help adi.sim.AD9081.Tx.SampleRate
```


```
  SampleRate Sample Rate of DACs
    Scalar in Hz
 InverseSincGainAdjustDB Inverse Gain Adjust DB
    Add gain to the output signal filter. Gain is in dB and can
    only be >=0 but <=8.7040.  This will be internally quantized 
    based on the 8-bit allowed values with steps of 0.034dB.
```

