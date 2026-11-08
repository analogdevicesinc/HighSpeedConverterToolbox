import json
import os

from jinja2 import Environment, FileSystemLoader


def update_hdl_refdesigns():

    # Data for template
    with open("ports.json") as f:
        objs = json.load(f)

    loc = os.path.join(os.path.dirname(__file__), "_tmpl")
    env = Environment(loader=FileSystemLoader(loc), keep_trailing_newline=True)
    template = env.get_template("refdesign.md")

    designs = {}

    os.makedirs("hdlrefdesigns", exist_ok=True)

    for obj in objs:
        # Render template
        objs[obj]["name"] = obj

        if objs[obj]["name"] in ["fmcomms2", "adrv9361z7035", "adrv9364z7020", "pluto"]:
            objs[obj]["rd_image"] = "ad9361"
        elif objs[obj]["name"] in ["adrv9002"]:
            objs[obj]["rd_image"] = "adrv9001"
        else:
            objs[obj]["rd_image"] = "jesd"

        output = template.render(obj=objs[obj])
        # Write output
        output_filename = os.path.join("hdlrefdesigns", f"{obj}.md")
        with open(output_filename, "w") as f:
            f.write(output)
        designs[obj] = output_filename

    # Generate the section index for the reference designs
    template = env.get_template("allrefdesigns.md")
    with open(os.path.join("hdlrefdesigns", "index.md"), "w") as f:
        f.write(template.render(designs=designs))

    return designs
