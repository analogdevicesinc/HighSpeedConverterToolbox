---
hide:
  - navigation
  - toc
---

<!-- <div class="sysobj_h1">adi.AD9467.Rx</div> -->

<!-- <div class="sysobj_top_desc">
Receive data from Analog Devices AD9361 transceiver
</div> -->

<!-- <div class="sysobj_desc_title">Description</div> -->

<div class="sysobj_desc_txt">
<span>
    The adi.AD9467.Rx System object is a signal source that can receive<br>    complex data from the AD9467.<br> <br>    rx = adi.AD9467.Rx;<br>    rx = adi.AD9467.Rx('uri','ip:192.168.2.1');<br> <br>    <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9467.pdf">AD9467 Datasheet</a><br>
</span>

</div>

<div class="sysobj_desc_title">Creation</div>

The class can be instantiated in the following way with and without property name value pairs.

```matlab
dev = adi.AD9467.Rx
dev = adi.AD9467.Rx(Name, Value)
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
    <p style="padding: 0px;">Baseband sampling rate in Hz, specified as a scalar in samples per second. This value read from the hardware after the object is setup.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('TestMode')" class="collapsible-property collapsible-property-TestMode">TestMode <span style="text-align:right" class="plus-TestMode">+</span></button>
  <div class="content content-TestMode" style="display: none;">
    <p style="padding: 0px;">Select ADC test mode. Options are: 'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 'checkerboard' 'pn_long' 'pn_short' 'one_zero_toggle'</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('FilterHighPass3dbFrequency')" class="collapsible-property collapsible-property-FilterHighPass3dbFrequency">FilterHighPass3dbFrequency <span style="text-align:right" class="plus-FilterHighPass3dbFrequency">+</span></button>
  <div class="content content-FilterHighPass3dbFrequency" style="display: none;">
    <p style="padding: 0px;">FilterHighPass3dbFrequency</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('Scale')" class="collapsible-property collapsible-property-Scale">Scale <span style="text-align:right" class="plus-Scale">+</span></button>
  <div class="content content-Scale" style="display: none;">
    <p style="padding: 0px;">Scale received data. Possible options are: 0.030517 0.032043 0.033569 0.035095 0.036621 0.038146</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('SamplesPerFrame')" class="collapsible-property collapsible-property-SamplesPerFrame">SamplesPerFrame <span style="text-align:right" class="plus-SamplesPerFrame">+</span></button>
  <div class="content content-SamplesPerFrame" style="display: none;">
    <p style="padding: 0px;">Number of samples per frame, specified as an even positive integer from 2 to 16,777,216. Using values less than 3660 can yield poor performance.Help for adi.AD9467.Rx/SamplesPerFrame is inherited from superclass ADI.AD9467.BASE</p>
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
    <p style="padding: 0px;">Hostname or IP address of remote libIIO deviceHelp for adi.AD9467.Rx/uri is inherited from superclass MATLABSHARED.LIBIIO.BASE</p>
  </div>
  </div>

<div class="sysobj_desc_title">Example Usage</div>

```

%% Rx set up
rx = adi.adi.AD9467.Rx.Rx('uri','ip:analog.local');
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