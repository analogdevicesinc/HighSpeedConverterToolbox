# AD9081 ADC and ADC Mux


The pipelined ADC models are simplied behavioral implementations that are based on the currently estimated specifications of the data converters. They are designed to be similar to the noise spectral density (NSD) of the converters. Note that since physical hardware does not exist these are estimated values and will likely change. There will be other distortions introduce by physical hardware as well, relating to front-end matches, internal chip structures, baluns, and gains stages among others. The ADC model should be considered similar but not exact.


# Top-Level Control


There are two control properties related to ADC control: **SampleRate** and **Crossbar4x4Mux0**.




**SampleRate** is the data rate of the converters themselves. Therefore, the output datarate of the model will be this SampleRate divided by the different decimations used.



```python
help adi.sim.AD9081.Rx.SampleRate
```


```
  SampleRate Sample Rate of ADCs
    Scalar in Hz. Currently this is fixed since NSD will change
    with this number, which would make the model invalid
```



**Crossbar4x4Mux0** is a full crossbar mux connecting the ADCs to the rest of the system.



```python
help adi.sim.AD9081.Rx.Crossbar4x4Mux0
```


```
  Crossbar4x4Mux0 Crossbar 4x4 Mux0
    Array of input and output mapping. Index is the output and the
    value is the selected input
```

# Example Configuration


Here is a basic example were we want to map ADC0, ADC1, and ADC2 out only.



```python
rx = adi.sim.AD9081.Rx;
rx.SampleRate = 4e9;
rx.Crossbar4x4Mux0 = [1,1,3,4];
% Pass noise through model at 10% and 1% fullscale
noiseVolts1 = 1.4/2*0.1*randn(1000,1);
noiseVolts2 = 1.4/2*0.01*randn(1000,1);
[o1,o2,~,~,o3,o4] = rx(noiseVolts1,noiseVolts2,noiseVolts1,noiseVolts1);
outs = [o1,o2,o3,o4];
fprintf('Mapped values identical %d\n',isequal(outs(:,1),outs(:,2)))
```


```
Mapped values identical 1
```


```python
fprintf('Mapped values identical %d\n',isequal(outs(:,3),outs(:,4)))
```


```
Mapped values identical 0
```

