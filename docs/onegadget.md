## Command onegadget ##

`one_gadget` is a standalone ROP gadget finding tool. It finds single gadgets
in `libc` to spawn a shell without the need to create a whole gadget chain.
This new `onegadget` command introduces this tool as a plugin to `gef`.
The found gadgets are printed out with their offset into the `libc` and a list
of constraints that need to be fulfilled for successful execution. Instead of
the offsets this tool can also rebase the results to fit the memory addresses.
Have in mind that these rebased addresses can change between executions if the
executable has memory randomization techniques enabled.

### Dependencies ###

- [`ruby`](https://www.ruby-lang.org/)
- [`one_gadget`](https://github.com/david942j/one_gadget)

The simplest way to install `ruby` is to use your Distributions package manager.
Then to install `one_gadget` simply run:

```bash
gem install one_gadget
```

### Example Usage ###

```
gef➤ onegadget
```

```
0xe6c7e execve("/bin/sh", r15, r12)
constraints:
  [r15] == NULL || r15 == NULL
  [r12] == NULL || r12 == NULL

0xe6c81 execve("/bin/sh", r15, rdx)
constraints:
  [r15] == NULL || r15 == NULL
  [rdx] == NULL || rdx == NULL

0xe6c84 execve("/bin/sh", rsi, rdx)
constraints:
  [rsi] == NULL || rsi == NULL
  [rdx] == NULL || rdx == NULL

0xe6e73 execve("/bin/sh", r10, r12)
constraints:
  address rbp-0x78 is writable
  [r10] == NULL || r10 == NULL
  [r12] == NULL || r12 == NULL

0xe6e76 execve("/bin/sh", r10, rdx)
constraints:
  address rbp-0x78 is writable
  [r10] == NULL || r10 == NULL
  [rdx] == NULL || rdx == NULL
```

The offsets in the above output are relative to the beginning of libc. They
can also be rebased to fit the currently loaded libc:

```
gef➤ onegadget rebase
```

```
0x7ffff7e8bc7e execve("/bin/sh", r15, r12)
constraints:
  [r15] == NULL || r15 == NULL
  [r12] == NULL || r12 == NULL

0x7ffff7e8bc81 execve("/bin/sh", r15, rdx)
constraints:
  [r15] == NULL || r15 == NULL
  [rdx] == NULL || rdx == NULL

0x7ffff7e8bc84 execve("/bin/sh", rsi, rdx)
constraints:
  [rsi] == NULL || rsi == NULL
  [rdx] == NULL || rdx == NULL

0x7ffff7e8be73 execve("/bin/sh", r10, r12)
constraints:
  address rbp-0x78 is writable
  [r10] == NULL || r10 == NULL
  [r12] == NULL || r12 == NULL

0x7ffff7e8be76 execve("/bin/sh", r10, rdx)
constraints:
  address rbp-0x78 is writable
  [r10] == NULL || r10 == NULL
  [rdx] == NULL || rdx == NULL
```
