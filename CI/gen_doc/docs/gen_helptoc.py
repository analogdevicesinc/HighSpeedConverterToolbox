"""Generate helptoc.xml, the table of contents MATLAB's help browser reads."""

import os

from jinja2 import Environment, FileSystemLoader

# Top level pages, in the order they appear in index.md's toctree.  The
# behavioral models, device interfaces, and reference designs are nested and
# handled by the template itself.
PAGES = [
    ("install.html", "Installation"),
    ("streaming.html", "Data Streaming"),
    ("ad9081.html", "AD9081/2 Specific Features"),
    ("targeting.html", "HDL Targeting"),
    ("examples.html", "Examples"),
    ("support.html", "Support"),
]


def gen_helptoc(devices, designs):
    loc = os.path.join(os.path.dirname(__file__), "_tmpl")
    env = Environment(loader=FileSystemLoader(loc), keep_trailing_newline=True)

    template = env.get_template("toc.tmpl")

    pages = [{"target": target, "title": title} for target, title in PAGES]
    output = template.render(pages=pages, devices=devices, designs=designs)

    loc = os.path.join(os.path.dirname(__file__), "helptoc.xml")
    with open(loc, "w") as f:
        f.write(output)
