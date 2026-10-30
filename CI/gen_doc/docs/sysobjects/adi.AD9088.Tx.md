

<!-- <div class="sysobj_h1">adi.AD9088.Tx</div> -->

<!-- <div class="sysobj_top_desc">
Receive data from Analog Devices AD9361 transceiver
</div> -->

<!-- <div class="sysobj_desc_title">Description</div> -->

<div class="sysobj_desc_txt">
<span>
    The adi.AD9088.Tx System object is a signal sink that can transmit<br>    complex data from the AD9088.<br> <br>    tx = adi.AD9088.Tx;<br>    tx = adi.AD9088.Tx('uri','ip:192.168.2.1');<br> <br>    <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ad9088.pdf">AD9088 Datasheet</a><br> <br>
</span>

</div>

<div class="sysobj_desc_title">Creation</div>

The class can be instantiated in the following way with and without property name value pairs.

```matlab
dev = adi.AD9088.Tx
dev = adi.AD9088.Tx(Name, Value)
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
  <button type="button" onclick="collapse('ChannelNCOFrequencies')" class="collapsible-property collapsible-property-ChannelNCOFrequencies">ChannelNCOFrequencies <span style="text-align:right" class="plus-ChannelNCOFrequencies">+</span></button>
  <div class="content content-ChannelNCOFrequencies" style="display: none;">
    <p style="padding: 0px;">Frequency of NCO in fine interpolators in transmit path. Property must be a [1,N] vector where each value is the frequency of an NCO in hertz.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('MainNCOFrequencies')" class="collapsible-property collapsible-property-MainNCOFrequencies">MainNCOFrequencies <span style="text-align:right" class="plus-MainNCOFrequencies">+</span></button>
  <div class="content content-MainNCOFrequencies" style="display: none;">
    <p style="padding: 0px;">Frequency of NCO in coarse interpolators in transmit path. Property must be a [1,N] vector where each value is the frequency of an NCO in hertz.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('ChannelNCOPhases')" class="collapsible-property collapsible-property-ChannelNCOPhases">ChannelNCOPhases <span style="text-align:right" class="plus-ChannelNCOPhases">+</span></button>
  <div class="content content-ChannelNCOPhases" style="display: none;">
    <p style="padding: 0px;">Phase of NCO in fine interpolators in transmit path. Property must be a [1,N] vector where each value is the phase of an NCO in millidegrees.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('MainNCOPhases')" class="collapsible-property collapsible-property-MainNCOPhases">MainNCOPhases <span style="text-align:right" class="plus-MainNCOPhases">+</span></button>
  <div class="content content-MainNCOPhases" style="display: none;">
    <p style="padding: 0px;">Phase of NCO in coarse interpolators in transmit path. Property must be a [1,N] vector where each value is the phase of an NCO in millidegrees.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('ChannelNCOGainScales')" class="collapsible-property collapsible-property-ChannelNCOGainScales">ChannelNCOGainScales <span style="text-align:right" class="plus-ChannelNCOGainScales">+</span></button>
  <div class="content content-ChannelNCOGainScales" style="display: none;">
    <p style="padding: 0px;">Digital gain of fine interpolators in transmit path. Property must be a [1,N] vector where each value is a linear gain scale.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('NCOEnables')" class="collapsible-property collapsible-property-NCOEnables">NCOEnables <span style="text-align:right" class="plus-NCOEnables">+</span></button>
  <div class="content content-NCOEnables" style="display: none;">
    <p style="padding: 0px;">Vector of logicals which enabled individual NCOs in channel interpolators</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('DDROffloadEnable')" class="collapsible-property collapsible-property-DDROffloadEnable">DDROffloadEnable <span style="text-align:right" class="plus-DDROffloadEnable">+</span></button>
  <div class="content content-DDROffloadEnable" style="display: none;">
    <p style="padding: 0px;">Enable use of BRAM in Tx datapath to offload from DDR. This is necessary for highspeed configurations when DDR is not fast enough for datapath</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('SamplingRate')" class="collapsible-property collapsible-property-SamplingRate">SamplingRate <span style="text-align:right" class="plus-SamplingRate">+</span></button>
  <div class="content content-SamplingRate" style="display: none;">
    <p style="padding: 0px;">Baseband sampling rate in Hz, specified as a scalar in samples per second. This value is only readable once connected to hardwareHelp for adi.AD9088.Tx/SamplingRate is inherited from superclass adi.AD9088.Base</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('SamplesPerFrame')" class="collapsible-property collapsible-property-SamplesPerFrame">SamplesPerFrame <span style="text-align:right" class="plus-SamplesPerFrame">+</span></button>
  <div class="content content-SamplesPerFrame" style="display: none;">
    <p style="padding: 0px;">Number of samples per frame, specified as an even positive integer from 2 to 16,777,216. Using values less than 3660 can yield poor performance.Help for adi.AD9088.Tx/SamplesPerFrame is inherited from superclass adi.AD9088.Base</p>
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
    <p style="padding: 0px;">Hostname or IP address of remote libIIO deviceHelp for adi.AD9088.Tx/uri is inherited from superclass matlabshared.libiio.base</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('DataSource')" class="collapsible-property collapsible-property-DataSource">DataSource <span style="text-align:right" class="plus-DataSource">+</span></button>
  <div class="content content-DataSource" style="display: none;">
    <p style="padding: 0px;">Data source, specified as one of the following: 'DMA' — Specify the host as the source of the data. 'DDS' — Specify the DDS on the radio hardware as the source of the data. In this case, each channel has two additive tones.Help for adi.AD9088.Tx/DataSource is inherited from superclass adi.common.DDS</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('DDSFrequencies')" class="collapsible-property collapsible-property-DDSFrequencies">DDSFrequencies <span style="text-align:right" class="plus-DDSFrequencies">+</span></button>
  <div class="content content-DDSFrequencies" style="display: none;">
    <p style="padding: 0px;">Frequencies values in Hz of the DDS tone generators. For complex data devices the input is a [2xN] matrix where N is the available channels on the board. For complex data devices this is at most max(EnabledChannels)*2. For non-complex data devices this is at most max(EnabledChannels). If N < this upper limit, other DDSs are not set.Help for adi.AD9088.Tx/DDSFrequencies is inherited from superclass adi.common.DDS</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('DDSScales')" class="collapsible-property collapsible-property-DDSScales">DDSScales <span style="text-align:right" class="plus-DDSScales">+</span></button>
  <div class="content content-DDSScales" style="display: none;">
    <p style="padding: 0px;">Scale of DDS tones in range [0,1]. For complex data devices the input is a [2xN] matrix where N is the available channels on the board. For complex data devices this is at most max(EnabledChannels)*2. For non-complex data devices this is at most max(EnabledChannels). If N < this upper limit, other DDSs are not set.Help for adi.AD9088.Tx/DDSScales is inherited from superclass adi.common.DDS</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('DDSPhases')" class="collapsible-property collapsible-property-DDSPhases">DDSPhases <span style="text-align:right" class="plus-DDSPhases">+</span></button>
  <div class="content content-DDSPhases" style="display: none;">
    <p style="padding: 0px;">Phases of DDS tones in range [0,360000]. For complex data devices the input is a [2xN] matrix where N is the available channels on the board. For complex data devices this is at most max(EnabledChannels)*2. For non-complex data devices this is at most max(EnabledChannels). If N < this upper limit, other DDSs are not set.Help for adi.AD9088.Tx/DDSPhases is inherited from superclass adi.common.DDS</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('EnableCyclicBuffers')" class="collapsible-property collapsible-property-EnableCyclicBuffers">EnableCyclicBuffers <span style="text-align:right" class="plus-EnableCyclicBuffers">+</span></button>
  <div class="content content-EnableCyclicBuffers" style="display: none;">
    <p style="padding: 0px;">Enable Cyclic Buffers, configures transmit buffers to be cyclic, which makes them continuously repeatHelp for adi.AD9088.Tx/EnableCyclicBuffers is inherited from superclass adi.common.DDS</p>
  </div>
  </div>

<div class="sysobj_desc_title">Example Usage</div>

```

%% Configure device
tx = adi.AD9088.Tx;
tx.uri = "ip:analog.local";
tx.DataSource = 'DMA';
tx.EnableCyclicBuffers = true;
tx.EnabledChannels = 1;

%% Generate tone
amplitude = 2^15; frequency = 0.12e6;
swv1 = dsp.SineWave(amplitude, frequency);
swv1.SamplesPerFrame = 2^14;

swv1.SampleRate = tx.SamplingRate;
y = swv1();

%% Send
tx(y);

```