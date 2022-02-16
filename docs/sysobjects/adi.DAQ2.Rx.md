

<!-- <div class="sysobj_h1">adi.DAQ2.Rx</div> -->

<!-- <div class="sysobj_top_desc">
Receive data from Analog Devices AD9361 transceiver
</div> -->

<!-- <div class="sysobj_desc_title">Description</div> -->

<div class="sysobj_desc_txt">
<span>
    The adi.DAQ2.Rx System object is a signal source that can <br>    receive complex data from the DAQ2.<br> <br>    rx = adi.DAQ2.Rx;<br>    rx = adi.DAQ2.Rx('uri','ip:192.168.2.1');<br> <br>    <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a><br> <br>
</span>

</div>

<div class="sysobj_desc_title">Creation</div>

The class can be instantiated in the following way with and without property name value pairs.

```matlab
dev = adi.DAQ2.Rx
dev = adi.DAQ2.Rx(Name, Value)
```

<div class="sysobj_desc_title">Properties</div>

<div class="sysobj_desc_txt">
<span>
Unless otherwise indicated, properties are non-tunable, which means you cannot change their values after calling the object. Objects lock when you call them, and the release function unlocks them.
<br><br>
If a property is tunable, you can change its value at any time.
<br><br>
For more information on changing property values, see <a href="https://www.mathworks.com/help/matlab/matlab_prog/system-design-in-matlab-using-system-objects.html">System Design in MATLAB Using System Objects.</a>
</span>
</div>
<div class="property">
  <button type="button" onclick="collapse('SamplingRate')" class="collapsible-property collapsible-property-SamplingRate">SamplingRate <span style="text-align:right" class="plus-SamplingRate">+</span></button>
  <div class="content content-SamplingRate" style="display: none;">
    <p style="padding: 0px;">Baseband sampling rate in Hz, specified as a scalar in samples per second. This value is constantHelp for adi.DAQ2.Rx.SamplingRate is inherited from superclass ADI.AD9680.RX</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('EnabledChannels')" class="collapsible-property collapsible-property-EnabledChannels">EnabledChannels <span style="text-align:right" class="plus-EnabledChannels">+</span></button>
  <div class="content content-EnabledChannels" style="display: none;">
    <p style="padding: 0px;">Indexs of channels to be enabled. Input should be a [1xN] vector with the indexes of channels to be enabled. Order is irrelevant</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('uri')" class="collapsible-property collapsible-property-uri">uri <span style="text-align:right" class="plus-uri">+</span></button>
  <div class="content content-uri" style="display: none;">
    <p style="padding: 0px;">Hostname or IP address of remote libIIO deviceHelp for adi.DAQ2.Rx/uri is inherited from superclass MATLABSHARED.LIBIIO.BASE</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('SamplesPerFrame')" class="collapsible-property collapsible-property-SamplesPerFrame">SamplesPerFrame <span style="text-align:right" class="plus-SamplesPerFrame">+</span></button>
  <div class="content content-SamplesPerFrame" style="display: none;">
    <p style="padding: 0px;">Number of samples per frame, specified as an even positive integer from 2 to 16,777,216. Using values less than 3660 can yield poor performance.Help for adi.DAQ2.Rx/SamplesPerFrame is inherited from superclass ADI.AD9680.BASE</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('kernelBuffersCount')" class="collapsible-property collapsible-property-kernelBuffersCount">kernelBuffersCount <span style="text-align:right" class="plus-kernelBuffersCount">+</span></button>
  <div class="content content-kernelBuffersCount" style="display: none;">
    <p style="padding: 0px;">The number of buffers allocated in the kernel for data transfersHelp for adi.DAQ2.Rx/kernelBuffersCount is inherited from superclass MATLABSHARED.LIBIIO.BASE</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('dataTypeStr')" class="collapsible-property collapsible-property-dataTypeStr">dataTypeStr <span style="text-align:right" class="plus-dataTypeStr">+</span></button>
  <div class="content content-dataTypeStr" style="display: none;">
    <p style="padding: 0px;">A String Representing the data typeHelp for adi.DAQ2.Rx/dataTypeStr is inherited from superclass MATLABSHARED.LIBIIO.BASE</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('SamplesPerFrame')" class="collapsible-property collapsible-property-SamplesPerFrame">SamplesPerFrame <span style="text-align:right" class="plus-SamplesPerFrame">+</span></button>
  <div class="content content-SamplesPerFrame" style="display: none;">
    <p style="padding: 0px;">Number of samples per frame, specified as an even positive integer from 2 to 16,777,216. Using values less than 3660 can yield poor performance.Help for adi.DAQ2.Rx/SamplesPerFrame is inherited from superclass ADI.AD9680.BASE</p>
  </div>
  </div>

<div class="sysobj_desc_title">Example Usage</div>

```

%% Rx set up
rx = adi.adi.DAQ2.Rx.Rx('uri','ip:analog.local');
rx.CenterFrequency = 1e9;
rx.EnabledChannels = 1;
%% Run
for k=1:10
    valid = false;
    while ~valid
        [out, valid] = rx();
    end
end

```