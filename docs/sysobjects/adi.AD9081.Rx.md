---
hide:
  - navigation
  - toc
---

<!-- <div class="sysobj_h1">adi.AD9081.Rx</div> -->

<!-- <div class="sysobj_top_desc">
Receive data from Analog Devices AD9361 transceiver
</div> -->

<!-- <div class="sysobj_desc_title">Description</div> -->

<div class="sysobj_desc_txt">
<span>
    The adi.AD9081.Rx System object is a signal source that can receive<br>    complex data from the AD9081.<br> <br>    rx = adi.AD9081.Rx;<br>    rx = adi.AD9081.Rx('uri','ip:192.168.2.1');<br> <br>    <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a><br> <br>
</span>

</div>

<div class="sysobj_desc_title">Creation</div>

The class can be instantiated in the following way with and without property name value pairs.

```matlab
dev = adi.AD9081.Rx
dev = adi.AD9081.Rx(Name, Value)
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
    <p style="padding: 0px;">Baseband sampling rate in Hz, specified as a scalar in samples per second. This value is only readable once connected to hardware</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('ChannelNCOFrequencies')" class="collapsible-property collapsible-property-ChannelNCOFrequencies">ChannelNCOFrequencies <span style="text-align:right" class="plus-ChannelNCOFrequencies">+</span></button>
  <div class="content content-ChannelNCOFrequencies" style="display: none;">
    <p style="padding: 0px;">Frequency of NCO in fine decimators in receive path. Property must be a [1,N] vector where each value is the frequency of an NCO in hertz, and N is the number of channels available.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('MainNCOFrequencies')" class="collapsible-property collapsible-property-MainNCOFrequencies">MainNCOFrequencies <span style="text-align:right" class="plus-MainNCOFrequencies">+</span></button>
  <div class="content content-MainNCOFrequencies" style="display: none;">
    <p style="padding: 0px;">Frequency of NCO in fine decimators in receive path. Property must be a [1,N] vector where each value is the frequency of an NCO in hertz, and N is the number of channels available.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('ChannelNCOPhases')" class="collapsible-property collapsible-property-ChannelNCOPhases">ChannelNCOPhases <span style="text-align:right" class="plus-ChannelNCOPhases">+</span></button>
  <div class="content content-ChannelNCOPhases" style="display: none;">
    <p style="padding: 0px;">Frequency of NCO in fine decimators in receive path. Property must be a [1,N] vector where each value is the frequency of an NCO in hertz, and N is the number of channels available.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('MainNCOPhases')" class="collapsible-property collapsible-property-MainNCOPhases">MainNCOPhases <span style="text-align:right" class="plus-MainNCOPhases">+</span></button>
  <div class="content content-MainNCOPhases" style="display: none;">
    <p style="padding: 0px;">Frequency of NCO in fine decimators in receive path. Property must be a [1,N] vector where each value is the frequency of an NCO in hertz, and N is the number of channels available.</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('TestMode')" class="collapsible-property collapsible-property-TestMode">TestMode <span style="text-align:right" class="plus-TestMode">+</span></button>
  <div class="content content-TestMode" style="display: none;">
    <p style="padding: 0px;">Test mode of receive path. Options are: 'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7' 'pn15' 'pn31' 'ramp'</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('EnablePFIRs')" class="collapsible-property collapsible-property-EnablePFIRs">EnablePFIRs <span style="text-align:right" class="plus-EnablePFIRs">+</span></button>
  <div class="content content-EnablePFIRs" style="display: none;">
    <p style="padding: 0px;">Enable use of PFIR/PFILT filters</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('PFIRFilenames')" class="collapsible-property collapsible-property-PFIRFilenames">PFIRFilenames <span style="text-align:right" class="plus-PFIRFilenames">+</span></button>
  <div class="content content-PFIRFilenames" style="display: none;">
    <p style="padding: 0px;">Path(s) to FPIR/PFILT filter file(s). Input can be a string or cell array of strings. Files are loading in order</p>
  </div>
  </div>
<div class="property">
  <button type="button" onclick="collapse('SamplesPerFrame')" class="collapsible-property collapsible-property-SamplesPerFrame">SamplesPerFrame <span style="text-align:right" class="plus-SamplesPerFrame">+</span></button>
  <div class="content content-SamplesPerFrame" style="display: none;">
    <p style="padding: 0px;">Number of samples per frame, specified as an even positive integer from 2 to 16,777,216. Using values less than 3660 can yield poor performance.Help for adi.AD9081.Rx/SamplesPerFrame is inherited from superclass ADI.AD9081.BASE</p>
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
    <p style="padding: 0px;">Hostname or IP address of remote libIIO deviceHelp for adi.AD9081.Rx/uri is inherited from superclass MATLABSHARED.LIBIIO.BASE</p>
  </div>
  </div>

<div class="sysobj_desc_title">Example Usage</div>

```

%% Rx set up
rx = adi.adi.AD9081.Rx.Rx('uri','ip:analog.local');
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