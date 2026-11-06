from gen_helptoc import gen_helptoc
from gen_rd_svg import gen_rd_svg
from gen_sysobj_pages import gen_sys_obj_pages

if __name__ == "__main__":
    gen_rd_svg()
    devices, designs = gen_sys_obj_pages()
    gen_helptoc(devices, designs)
