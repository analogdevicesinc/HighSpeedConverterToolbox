import json
import os
import re

from jinja2 import Environment, FileSystemLoader


def _template_env():
    loc = os.path.join(os.path.dirname(__file__), "_tmpl")
    return Environment(loader=FileSystemLoader(loc), keep_trailing_newline=True)


def gen_sys_obj_pages():

    # Data for template
    with open("sysobjs.json") as f:
        objs = json.load(f)

    env = _template_env()
    template = env.get_template("sysobj.md")

    devices = {}

    def cleanup(obj):
        """Turn MATLAB's fixed width help text into Markdown."""

        obj["dec"] = obj["dec"].replace("192.168.2.1", "ip:192.168.2.1")
        lines = []
        for d in obj["dec"].split("<br>"):

            if "See also" in d:
                continue
            if "Documentation for" in d:
                continue
            if "doc adi." in d:
                continue

            lines.append(d.strip())

        # Group the lines into blank line separated blocks
        blocks = []
        current = []
        for line in lines:
            if line:
                current.append(line)
            elif current:
                blocks.append(current)
                current = []
        if current:
            blocks.append(current)

        def render(block):
            # Blocks of MATLAB statements are kept verbatim in a code fence,
            # everything else is prose that was hard wrapped by MATLAB.
            if all(re.match(r"^\w+ = adi\.", line) for line in block):
                return "```matlab\n" + "\n".join(block) + "\n```"
            text = " ".join(block)
            return re.sub(r'<a href="([^"]+)">([^<]+)</a>', r"[\2](\1)", text)

        obj["dec"] = "\n\n".join(render(b) for b in blocks)

        if ".Rx" in obj["name"]:
            obj["type"] = "Rx"
        else:
            obj["type"] = "Tx"

        return obj

    os.makedirs("sysobjects", exist_ok=True)

    for obj in objs:
        # Render template
        obj = cleanup(obj)
        output = template.render(obj=obj)
        # Write output
        output_filename = os.path.join("sysobjects", f"{obj['name']}.md")
        with open(output_filename, "w") as f:
            f.write(output)
        devices[obj["name"]] = output_filename

    # Generate the section index for the devices
    template = env.get_template("allsysobjs.md")
    with open(os.path.join("sysobjects", "index.md"), "w") as f:
        f.write(template.render(devices=devices))

    ###############################################################################
    # HDL Refdesigns
    ###############################################################################
    from gen_hdl_refdesigns import update_hdl_refdesigns

    designs = update_hdl_refdesigns()

    return devices, designs
