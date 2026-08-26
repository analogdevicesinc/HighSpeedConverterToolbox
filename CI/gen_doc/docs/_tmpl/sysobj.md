# {{ obj.name }}

{{ obj.dec }}

## Creation

The class can be instantiated in the following way with and without property name value pairs.

```matlab
dev = {{ obj.name }}
dev = {{ obj.name }}(Name, Value)
```

## Properties

Unless otherwise indicated, properties are non-tunable, which means you cannot
change their values after calling the object. Objects lock when you call them,
and the release function unlocks them.

If a property is tunable, you can change its value at any time.

For more information on changing property values, see
[System Design in MATLAB Using System Objects](https://www.mathworks.com/help/matlab/matlab_prog/system-design-in-matlab-using-system-objects.html).

{% for prop in obj.props %}
:::{collapsible} {{ prop.prop_name }}
{{ prop.prop_description or prop.prop_title.strip() }}
:::
{% endfor %}

## Example Usage

{% if obj.type == "Tx" -%}
```matlab
%% Configure device
tx = {{ obj.name }};
tx.uri = "ip:analog.local";
tx.DataSource = 'DMA';
tx.EnableCyclicBuffers = true;
tx.EnabledChannels = 1;

%% Generate tone
amplitude = 2^15; frequency = 0.12e6;
swv1 = dsp.SineWave(amplitude, frequency);
{% if obj.name == "adi.AD9081.Tx" or obj.name == "adi.AD9081.Rx" -%}
swv1.ComplexOutput = true;
{% endif -%}
swv1.SamplesPerFrame = 2^14;
{% if (obj.name == "adi.AD9081.Tx") or (obj.name == "adi.AD9081.Rx") -%}
swv1.SampleRate = 250e6;
{% else -%}
swv1.SampleRate = tx.SamplingRate;
{% endif -%}
y = swv1();

%% Send
tx(y);
```
{%- else -%}
```matlab
%% Rx set up
rx = {{ obj.name }}('uri','ip:analog.local');
rx.SamplesPerFrame = 2^14;
rx.EnabledChannels = 1;

%% Run
for k=1:10
    valid = false;
    while ~valid
        [out, valid] = rx();
    end
end

%% Cleanup
release(rx)
```
{%- endif %}
