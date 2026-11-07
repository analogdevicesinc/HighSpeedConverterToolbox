# Device Interfaces

Available hardware streaming interfaces in High-Speed Converter Toolbox:

{% for obj in devices -%}
- [{{ obj }}]({{ obj }}.md)
{% endfor %}

```{toctree}
:maxdepth: 1
:hidden:

{% for obj in devices -%}
{{ obj }}
{% endfor %}
```
