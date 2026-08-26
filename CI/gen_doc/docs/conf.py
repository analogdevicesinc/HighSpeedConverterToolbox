# Configuration file for the Sphinx documentation builder.
#
# For a full list of options see:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import datetime
import os
import re
from typing import List

# -- Project information -----------------------------------------------------

repository = "HighSpeedConverterToolbox"
project = "Analog Devices High-Speed Converter Toolbox"
year_now = datetime.datetime.now().year
copyright = f"2021-{year_now}, Analog Devices, Inc"
author = "Analog Devices, Inc"


def _toolbox_release() -> str:
    """Read the toolbox release out of +adi/Version.m."""
    version_m = os.path.join(
        os.path.dirname(__file__), "..", "..", "..", "+adi", "Version.m"
    )
    try:
        with open(version_m) as f:
            match = re.search(r"Release\s*=\s*'([^']+)'", f.read())
    except OSError:
        return ""
    return match.group(1) if match else ""


release = _toolbox_release()
version = release

# Set when the documentation is built for MATLAB's embedded help browser
# instead of for the web.  The Makefile's doc_ml target sets it.
matlab_help = bool(os.environ.get("MATLAB"))

# -- General configuration ---------------------------------------------------

extensions = [
    "sphinx.ext.githubpages",
    "myst_parser",
    "sphinxcontrib.mermaid",
    "adi_doctools",
]

needs_extensions = {"adi_doctools": "0.4.21"}

templates_path: List[str] = []

# _tmpl holds the Jinja templates gen_all_doc.py renders, they are not documents
exclude_patterns: List[str] = [
    "_tmpl",
]

source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}

# -- MyST configuration -------------------------------------------------------

myst_enable_extensions = [
    "attrs_inline",
    "attrs_block",
    "colon_fence",
    "deflist",
    "dollarmath",
    "html_image",
    "substitution",
]

myst_heading_anchors = 3

# -- Custom extensions configuration ------------------------------------------

hide_collapsible_content = True

# -- External docs configuration ----------------------------------------------

interref_repos = ["doctools"]

# -- Options for HTML output --------------------------------------------------

html_theme = "cosmic"
html_favicon = os.path.join("_static", "favicon.png")

html_static_path = ["_static"]

# helptoc.xml is consumed by MATLAB's help browser, it is not a document
html_extra_path = ["helptoc.xml"]

html_css_files = [
    "css/style.css",
    "css/rd_style.css",
]

html_theme_options = {
    "light_logo": os.path.join("logos", "hsx_300.png"),
    "dark_logo": os.path.join("logos", "hsx_w_300.png"),
}

if matlab_help:
    # MATLAB renders these pages inside its own help browser, which supplies
    # the surrounding navigation, so strip ours.
    html_css_files.append("css/matlab.css")
    html_theme_options["standalone"] = True
    html_theme_options["show_relbar"] = False
