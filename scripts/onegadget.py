#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
`one_gadget` is a standalone ROP gadget finding tool. It finds single gadgets
in `libc` to spawn a shell without the need to create a whole gadget chain.
This new `onegadget` command introduces this tool as a plugin to `gef`.
The found gadgets are printed out with their offset into the `libc` and a list
of constraints that need to be fulfilled for successful execution. Instead of
the offsets this tool can also rebase the results to fit the memory addresses.
Have in mind that these rebased addresses can change between executions if the
executable has memory randomization techniques enabled.

Credits for `one_gadget` to @david942j
Credits for this plugin idea to @bata24
"""

import os

plugin_author = "theguy147"
plugin_version = 0.1
plugin_license = "MIT"


class OneGadgetCommand(GenericCommand):
    """Exec `one_gadget`. If `rebase` is given as an argument, gadgets will be
    rebased to current libc base address."""

    _cmdline_ = "onegadget"
    _syntax_ = f"{_cmdline_} [rebase]"
    _example_ = f"{_cmdline_} rebase"

    def check_plugin(self):
        try:
            which("one_gadget")
        except FileNotFoundError:
            msg = "Missing `one_gadget` gem for Ruby, install with: "\
                  "`gem install one_gadget`."
            raise ImportWarning(msg)
        return

    @only_if_gdb_running
    def do_invoke(self, argv):
        self.check_plugin()

        libc = None
        for name in ("libc-2.", "libc.so.6"):
            libc = process_lookup_path(name)
            if libc is not None:
                break

        if libc is None:
            err("libc not found")
            return
        libc_base = libc.page_start if "rebase" in argv else 0

        one_gadget = which("one_gadget")
        gef_print(titlify(f"{one_gadget} {libc.path} -l 1 --base {libc_base}"))
        os.system(f"{one_gadget} {libc.path} -l 1 --base {libc_base}")
        return


if __name__ == "__main__":
    register_external_command(OneGadgetCommand())
