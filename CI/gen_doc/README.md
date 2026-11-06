# High-Speed Converter Toolbox documentation

The documentation is built with [Sphinx](https://www.sphinx-doc.org) using the
`cosmic` theme from [ADI Doctools](https://github.com/analogdevicesinc/doctools),
the same theme as [pyadi-iio](https://analogdevicesinc.github.io/pyadi-iio/).
Pages are written in Markdown and parsed by
[MyST](https://myst-parser.readthedocs.io).

## Building

```bash
pip install -r requirements_doc.txt
make doc
```

The rendered site is written to `doc/` at the root of the repository, which is
also where MATLAB looks for the toolbox help (see `info.xml`).

To build the variant that is embedded in MATLAB's help browser, which drops the
theme's own navigation in favor of `helptoc.xml`:

```bash
make doc_ml
```

While writing, `make html` skips the generation step and leaves the output in
`build/html`.

## Layout

`docs/` is the Sphinx source directory:

| Path | Contents |
| ---- | -------- |
| `docs/conf.py` | Sphinx configuration |
| `docs/*.md` | Hand written pages |
| `docs/models/` | Behavioral model pages exported from MATLAB live scripts |
| `docs/assets/` | Images and reference design diagrams |
| `docs/_static/` | Logos and stylesheets |
| `docs/_tmpl/` | Jinja templates for the generated pages |

## Generated pages

`docs/gen_all_doc.py` renders the pages that are derived from machine readable
sources, and the Makefile runs it before Sphinx. Its output is not checked in:

- `docs/sysobjects/` from `docs/sysobjs.json`, which `docs/gen_sysobj_doc.m`
  produces by walking the system object help text in MATLAB.
- `docs/hdlrefdesigns/` from `CI/scripts/ports.json`.
- `docs/assets/*_custom.svg` and `docs/_static/css/rd_style.css`, the clickable
  reference design diagrams.
- `docs/helptoc.xml`, the table of contents MATLAB's help browser reads.
