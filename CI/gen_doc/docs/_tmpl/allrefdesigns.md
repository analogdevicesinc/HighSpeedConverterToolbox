# HDL Reference Designs

HDL reference designs that support the HDL-Coder IP-Core generation flow:

{% for design in designs -%}
- [{{ design }}]({{ design }}.md)
{% endfor %}

```{toctree}
:maxdepth: 1
:hidden:

{% for design in designs -%}
{{ design }}
{% endfor %}
```
