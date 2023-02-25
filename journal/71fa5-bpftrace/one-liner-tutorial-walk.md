# Description

Follow bpftrace tutorial, document some output and for each command explore at least one more variation or wider/deeper options.

tutorial: https://github.com/iovisor/bpftrace/blob/master/docs/tutorial_one_liners.md

https://www.brendangregg.com/BPF/bpftrace-cheat-sheet.html


## 3

```shell
bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s %s\n", comm, str(args->filename)); }'
```

in another terminal this seen in bpf prog list
```
96: tracepoint  name sys_enter_opena  tag 3218caa6110d9509  gpl
        loaded_at 2023-02-25T00:19:55+0000  uid 0
        xlated 424B  jited 247B  memlock 4096B  map_ids 28
```
explore args struct
```
$ bpftrace -vl tracepoint:syscalls:sys_enter_getpeername
tracepoint:syscalls:sys_enter_getpeername
    int __syscall_nr
    int fd
    struct sockaddr * usockaddr
    int * usockaddr_len
```

Try another system call, and print what bpf calls have been performed
```
strace -e trace=bpf bpftrace -e 'tracepoint:syscalls:sys_enter_getpeername { printf("%s %s %s\n", comm, probe, str(pid)); }'
```
output:
```
--- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=30912, si_uid=0, si_status=127, si_utime=0, si_stime=0} ---
bpf(BPF_PROG_LOAD, {prog_type=BPF_PROG_TYPE_KPROBE, insn_cnt=2, insns=0x7ffeb60b7800, license="GPL", log_level=1, log_size=4096, log_buf="", kern_version=KERNEL_VERSION(5, 15, 73), prog_flags=0, prog_name="", prog_ifindex=0, expected_attach_type=BPF_CGROUP_INET_INGRESS, prog_btf_fd=0, func_info_rec_size=0, func_info=NULL, func_info_cnt=0, line_info_rec_size=0, line_info=NULL, line_info_cnt=0, attach_btf_id=0, attach_prog_fd=0, fd_array=NULL}, 128) = -1 EACCES (Permission denied)
bpf(BPF_PROG_LOAD, {prog_type=BPF_PROG_TYPE_KPROBE, insn_cnt=2, insns=0x7ffeb60b7800, license="GPL", log_level=1, log_size=4096, log_buf="", kern_version=KERNEL_VERSION(5, 15, 73), prog_flags=0, prog_name="", prog_ifindex=0, expected_attach_type=BPF_CGROUP_INET_INGRESS, prog_btf_fd=0, func_info_rec_size=0, func_info=NULL, func_info_cnt=0, line_info_rec_size=0, line_info=NULL, line_info_cnt=0, attach_btf_id=0, attach_prog_fd=0, fd_array=NULL}, 128) = -1 EACCES (Permission denied)
bpf(BPF_PROG_LOAD, {prog_type=BPF_PROG_TYPE_KPROBE, insn_cnt=2, insns=0x7ffeb60b7800, license="GPL", log_level=1, log_size=4096, log_buf="", kern_version=KERNEL_VERSION(5, 15, 73), prog_flags=0, prog_name="", prog_ifindex=0, expected_attach_type=BPF_CGROUP_INET_INGRESS, prog_btf_fd=0, func_info_rec_size=0, func_info=NULL, func_info_cnt=0, line_info_rec_size=0, line_info=NULL, line_info_cnt=0, attach_btf_id=0, attach_prog_fd=0, fd_array=NULL}, 128) = -1 EACCES (Permission denied)
WARNING: Addrspace is not set
Attaching 1 probe...
bpf(BPF_MAP_CREATE, {map_type=BPF_MAP_TYPE_PERF_EVENT_ARRAY, key_size=4, value_size=4, max_entries=2, map_flags=0, inner_map_fd=0, map_name="printf", map_ifindex=0, btf_fd=0, btf_key_type_id=0, btf_value_type_id=0, btf_vmlinux_value_type_id=0, map_extra=0}, 128) = 3
bpf(BPF_MAP_UPDATE_ELEM, {map_fd=3, key=0x7ffeb60b9de0, value=0x7ffeb60b9de8, flags=BPF_ANY}, 128) = 0
bpf(BPF_MAP_UPDATE_ELEM, {map_fd=3, key=0x7ffeb60b9de0, value=0x7ffeb60b9de8, flags=BPF_ANY}, 128) = 0
bpf(BPF_PROG_LOAD, {prog_type=BPF_PROG_TYPE_TRACEPOINT, insn_cnt=56, insns=0x563fc5271a20, license="GPL", log_level=0, log_size=0, log_buf=NULL, kern_version=KERNEL_VERSION(5, 15, 73), prog_flags=0, prog_name="sys_enter_getpe", prog_ifindex=0, expected_attach_type=BPF_CGROUP_INET_INGRESS, prog_btf_fd=0, func_info_rec_size=0, func_info=NULL, func_info_cnt=0, line_info_rec_size=0, line_info=NULL, line_info_cnt=0, attach_btf_id=0, attach_prog_fd=0, fd_array=NULL}, 128) = 8
curl tracepoint:syscalls:sys_enter_getpeername
curl tracepoint:syscalls:sys_enter_getpeername
curl tracepoint:syscalls:sys_enter_getpeername
curl tracepoint:syscalls:sys_enter_getpeername
```

What is it curling? no user workload on VM.



## 4

manually removed entries from output, to leave only the highest volume entries. no user action or programs on the VM.
```
$ time bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'
Attaching 1 probe...
^C

@[cat]: 248
@[amazon-ssm-agen]: 760
@[systemd-network]: 1038
@[systemd-userwor]: 1131
@[bpftrace]: 1528
@[(y-routes)]: 1544
@[ps]: 4255
@[logger]: 4632
@[curl]: 5376
@[containerd]: 11376
@[ssm-session-wor]: 28054

real    2m33.258s
user    0m0.076s
sys     0m0.139s
```


# 5

Before using this one, need to find a process that is using this syscall. Using one of the examples above:
```
bpftrace -e 'tracepoint:syscalls:sys_exit_read { printf("%s %d\n", comm, pid) }'
ssm-session-wor 1881
...
```
this guy is chatty!

now run the command
```shell
$ time bpftrace -e 'tracepoint:syscalls:sys_exit_read /pid == 1881/ { @bytes = hist(args->ret); }'
Attaching 1 probe...
^C

@bytes:
(..., 0)               1 |@@@@@                                               |
[0]                    0 |                                                    |
[1]                   10 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[2, 4)                 1 |@@@@@                                               |
[4, 8)                 0 |                                                    |
[8, 16)                0 |                                                    |
[16, 32)               0 |                                                    |
[32, 64)               0 |                                                    |
[64, 128)              0 |                                                    |
[128, 256)             1 |@@@@@                                               |
[256, 512)             1 |@@@@@                                               |


real    1m34.803s
user    0m0.080s
sys     0m0.148s
```

# 6

```
[root@ip-10-192-10-53 bin]# bpftool -f map
11: hash_of_maps  name cgroup_hash  flags 0x0
        key 8B  value 4B  max_entries 2048  memlock 32768B
46: percpu_hash  name AT_bytes  flags 0x0
        key 8B  value 8B  max_entries 4096  memlock 98304B
47: perf_event_array  name printf  flags 0x0
        key 4B  value 4B  max_entries 2  memlock 4096B
[root@ip-10-192-10-53 bin]# bpftool prog list | tail -3
109: kprobe  name vfs_read  tag 62751f4ff740a893  gpl
        loaded_at 2023-02-25T01:10:45+0000  uid 0
        xlated 240B  jited 162B  memlock 4096B  map_ids 46
```
output:

```
time bpftrace -e 'kretprobe:vfs_read { @bytes = lhist(retval, 0, 2000, 200); }'
Attaching 1 probe...
^C

@bytes:
(..., 0)              74 |@@@@@@                                              |
[0, 200)             606 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[200, 400)            16 |@                                                   |
[400, 600)             2 |                                                    |
[600, 800)            53 |@@@@                                                |
[800, 1000)           73 |@@@@@@                                              |
[1000, 1200)          94 |@@@@@@@@                                            |
[1200, 1400)           5 |                                                    |
[1400, 1600)           0 |                                                    |
[1600, 1800)           0 |                                                    |
[1800, 2000)           0 |                                                    |
[2000, ...)           19 |@                                                   |


real    2m19.591s
user    0m0.105s
sys     0m0.125s
```

## 9

where did 7 and 8 go? It's Saturday, I need a break!!!
```
 bpftrace -e 'profile:hz:99 { @[kstack] = count(); }'
Attaching 1 probe...
^C

@[]: 13
...
@[
    acpi_idle_do_entry+80
    acpi_idle_enter+128
    cpuidle_enter_state+137
    cpuidle_enter+41
    cpuidle_idle_call+277
    do_idle+118
    cpu_startup_entry+25
    secondary_startup_64_no_verify+176
]: 8095
```

## 10

Scheduler most frequent stack:
```
$ bpftrace -e 'tracepoint:sched:sched_switch { @[kstack] = count(); }'
```
output
```
@[
    __schedule+778
    __schedule+778
    schedule_idle+38
    do_idle+171
    cpu_startup_entry+25
    secondary_startup_64_no_verify+176
]: 9844
```

## 11

```
$ bpftrace -e 'tracepoint:block:block_rq_issue { @ = hist(args->bytes); }'
Attaching 1 probe...
^C

@:
[512, 1K)              3 |@@@@@                                               |
[1K, 2K)               0 |                                                    |
[2K, 4K)               0 |                                                    |
[4K, 8K)              28 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[8K, 16K)              2 |@@@                                                 |
[16K, 32K)             4 |@@@@@@@                                             |
[32K, 64K)             2 |@@@                                                 |
```




# Dumps

## 3


`bpftool prog dump xlated id 96` output:

```bpf
   0: (bf) r6 = r1
   1: (b7) r7 = 0
   2: (7b) *(u64 *)(r10 -152) = r7
   3: (7b) *(u64 *)(r10 -56) = r7
   4: (7b) *(u64 *)(r10 -64) = r7
   5: (bf) r1 = r10
   6: (07) r1 += -64
   7: (b7) r2 = 16
   8: (85) call bpf_get_current_comm#143536
   9: (79) r1 = *(u64 *)(r10 -64)
  10: (7b) *(u64 *)(r10 -144) = r1
  11: (79) r1 = *(u64 *)(r10 -56)
  12: (7b) *(u64 *)(r10 -136) = r1
  13: (7b) *(u64 *)(r10 -8) = r7
  14: (7b) *(u64 *)(r10 -16) = r7
  15: (7b) *(u64 *)(r10 -24) = r7
  16: (7b) *(u64 *)(r10 -32) = r7
  17: (7b) *(u64 *)(r10 -40) = r7
  18: (7b) *(u64 *)(r10 -48) = r7
  19: (7b) *(u64 *)(r10 -56) = r7
  20: (7b) *(u64 *)(r10 -64) = r7
  21: (79) r3 = *(u64 *)(r6 +24)
  22: (bf) r1 = r10
  23: (07) r1 += -64
  24: (b7) r2 = 64
  25: (85) call bpf_probe_read_user_str#-63568
  26: (79) r1 = *(u64 *)(r10 -64)
  27: (7b) *(u64 *)(r10 -128) = r1
  28: (79) r1 = *(u64 *)(r10 -56)
  29: (7b) *(u64 *)(r10 -120) = r1
  30: (79) r1 = *(u64 *)(r10 -48)
  31: (7b) *(u64 *)(r10 -112) = r1
  32: (79) r1 = *(u64 *)(r10 -40)
  33: (7b) *(u64 *)(r10 -104) = r1
  34: (79) r1 = *(u64 *)(r10 -32)
  35: (7b) *(u64 *)(r10 -96) = r1
  36: (79) r1 = *(u64 *)(r10 -24)
  37: (7b) *(u64 *)(r10 -88) = r1
  38: (79) r1 = *(u64 *)(r10 -16)
  39: (7b) *(u64 *)(r10 -80) = r1
  40: (79) r1 = *(u64 *)(r10 -8)
  41: (7b) *(u64 *)(r10 -72) = r1
  42: (18) r2 = map[id:28]
  44: (bf) r4 = r10
  45: (07) r4 += -152
  46: (bf) r1 = r6
  47: (18) r3 = 0xffffffff
  49: (b7) r5 = 88
  50: (85) call bpf_perf_event_output_tp#-62208
  51: (b7) r0 = 1
  52: (95) exit
```

## 6

```
[root@ip-10-192-10-53 bin]# bpftool prog dump xlated id 109
   0: (79) r2 = *(u64 *)(r1 +80)
   1: (79) r1 = *(u64 *)(r1 +80)
   2: (b7) r2 = 0
   3: (6d) if r2 s> r1 goto pc+5
   4: (b7) r2 = 11
   5: (65) if r1 s> 0x7d0 goto pc+3
   6: (37) r1 /= 200
   7: (07) r1 += 1
   8: (bf) r2 = r1
   9: (7b) *(u64 *)(r10 -16) = r2
  10: (18) r1 = map[id:46]
  12: (bf) r2 = r10
  13: (07) r2 += -16
  14: (85) call htab_percpu_map_lookup_elem#168336
  15: (b7) r1 = 1
  16: (15) if r0 == 0x0 goto pc+2
  17: (79) r1 = *(u64 *)(r0 +0)
  18: (07) r1 += 1
  19: (7b) *(u64 *)(r10 -8) = r1
  20: (18) r1 = map[id:46]
  22: (bf) r2 = r10
  23: (07) r2 += -16
  24: (bf) r3 = r10
  25: (07) r3 += -8
  26: (b7) r4 = 0
  27: (85) call htab_percpu_map_update_elem#170832
  28: (b7) r0 = 0
  29: (95) exit
```
