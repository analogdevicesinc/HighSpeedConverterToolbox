# AD9081 Digital Up Converters


The AD9081 has two sets of digital up converters (DUC), the coarse (CDUC) and fine (FDUC). These are used to both interpolate and move signals using the NCOs. They also can be used to phase shift and apply gain to the input signal.




The CDUCs and FDUC are almost identical except for their available interpolations, allowable rates, and count. There are two CDUCs per DAC pair and four FDUCs per DAC pair. In the data pipeline, data from the input will be passed through the FDUCs, or bypass the FDUCs, then routed through a mux into the CDUCs, which can also be bypassed.


# Top-Level Control


The CDUC and FDUC interpolations are controlled by **MainDataPathInterpolation** and **ChannelizerPathInterpolation** respectively.



```python
help adi.sim.AD9081.Tx.MainDataPathInterpolation
```


```
  MainDataPathInterpolation Main Data Path Interpolation
    Specify the decimation in the main data path which can be
    [1,2,3,4,6]
```


```python
help adi.sim.AD9081.Tx.ChannelizerPathInterpolation
```


```
  ChannelizerPathInterpolation Channelizer Path Interpolation
    Specify the decimation in the channelizer path which can be
    [1,2,3,4,6,8,12,16,24]
```

## Muxing


The FDUC quads share a common full crossbar to the pairs of upstream CDUCs connected to them. This is represented by a single summing crossbar that limits routes to the halves of AD9081. This crossbar or mux is controlled by the **Crossbar8x8Mux** and will constrain all the mappings.



```python
help adi.sim.AD9081.Tx.Crossbar8x8Mux
```


```
  Crossbar8x8Mux Crossbar 8x8 Mux
    Logical 4x8 array of for MainDataPath input summers. Each row
    corresponds to each summmer [1-4] and each column corresponds
    to an input Channelizer path 1-8]. Set indexes to true to
    enable a given path to be added into summer's output.
```



The 8x8 summing crossbar can sum any channels within the FDUC quads (FDUC0->FDUC3 and FDUC4->FDUC7). This is controlled by the columns of **Crossbar8x8Mux**, where each true row in a given column is feed into the individual summers feeding the inputs to the CDUCs. Below is an example of summing FDUC0,FDUC1,FDUC3 to CDDC0 and  FDUC4,FDUC5 to CDDC2:



```python
tx = adi.sim.AD9081.Tx;
tx.Crossbar8x8Mux = [...
    1,0,0,0,0,0,0,0;...FDUC0->CDUC0
    0,1,0,0,0,0,0,0;...FDUC1->CDUC1
    0,0,1,0,0,0,0,0;...FDUC2->CDUC2
    0,0,0,1,0,0,0,0]; %FDUC3->CDUC3
```

## NCO Frequency and Phase


Once the NCOs are enabled the frequencies and phases of the NCOs can be controlled individually. This is done through the **CDUCNCOFrequencies, FDUCNCOFrequencies**, **CDUCNCOPhases**, and **FDUCNCOPhases**. The frequencies will be limited based on the rate going into the NCO at that stage.



```python
help adi.sim.AD9081.Tx.CDUCNCOFrequencies
```


```
  CDUCNCOFrequencies CDUC NCO Frequencies
    1x4 Array of frequencies of NCOs in main data path
```


```python
help adi.sim.AD9081.Tx.FDUCNCOFrequencies
```


```
  FDUCNCOFrequencies FDUC NCO Frequencies
    1x8 Array of frequencies of NCOs in channelizer path
```

