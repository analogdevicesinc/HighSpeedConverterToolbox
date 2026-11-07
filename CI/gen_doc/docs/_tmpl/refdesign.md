# {{ obj.name }} Reference Design Integration

This page outlines the HDL reference design integration for the *{{ obj.name }}* reference design for the Analog Devices
{{ obj.chip }} component. The IP-Core Generation follow is available on the based on the following base HDL reference design for the following board and design variants:

{% if obj.hdl_rd_doc -%}
- [Base reference design documentation]({{ obj.hdl_rd_doc }})
{% endif -%}
- Supported FPGA carriers:
{%- for carrier in obj.fpga %}
    - {{ carrier.upper() }}
{%- endfor %}
- Supported design variants:
{%- for supported_rd in obj.supported_rd %}
    - {{ supported_rd.upper() }}
{%- endfor %}

## Reference Design

::::{container} refdesign
:::{raw} html
:file: ../assets/rd_{{ obj.rd_image }}_custom.svg
:::

HDL Reference Design with Custom IP from HDL-Coder. Click on sub-blocks for more documentation.
::::

The IP-Core generation flow will integrate IP generated from Simulink subsystem into an ADI authored reference design. Depending on the FPGA carrier and FMC card or SoM, this will support different IP locations based on the diagram above.

## HDL Workflow Advisor Port Mappings

When using the HDL Workflow Advisor, the following port mappings are used to connect the reference design to the HDL-Coder generated IP-Core:

| Type | Target Platform Interface (MATLAB) | Reference Design Connection (Vivado) | Width | Reference Design Variant |
| ---- | ------------------------ | --------------------------- | ----- | ----------- |
{%- for rds in obj.ports[0] %}
{%- for rd in obj.ports[0][rds] %}
| {{ rd['type'].upper() }}-{% if rd['input'] == "true" %}IN{% else %}OUT{% endif %} | {{ rd['m_name'] }} | {{ rd['name'] }} | {{ rd['width'] }} | {{ rds.upper() }} |
{%- endfor %}
{%- endfor %}
