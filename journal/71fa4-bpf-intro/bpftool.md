These BPF programs were available by default.
Maybe https://github.com/systemd/systemd/pull/6764 ?

```
[root@ip-xx ~]# bpftool prog show
82: cgroup_device  tag ee0e253c78993a24  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 416B  jited 255B  memlock 4096B
83: cgroup_device  tag 2c86c96f352db46b  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 496B  jited 307B  memlock 4096B
84: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
85: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
86: cgroup_device  tag 63878b01a3de7bae  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 464B  jited 288B  memlock 4096B
87: cgroup_device  tag 03e2cf74d47166f5  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 744B  jited 447B  memlock 4096B
88: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
89: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
90: cgroup_device  tag ee0e253c78993a24  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 416B  jited 255B  memlock 4096B
91: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
92: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
93: cgroup_device  tag 3a32ccd9e03ea87a  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 504B  jited 309B  memlock 4096B
94: cgroup_device  tag 7bd59a43600ecbbd  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 464B  jited 288B  memlock 4096B
95: cgroup_device  tag 3a32ccd9e03ea87a  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 504B  jited 309B  memlock 4096B
96: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
97: cgroup_skb  tag 6deef7357e7b4530  gpl
        loaded_at 2023-02-12T02:22:55+0000  uid 0
        xlated 64B  jited 54B  memlock 4096B
[root@ip-xx ~]#
[root@ip-xx ~]#
[root@ip-xx ~]# bpftool prog dump xlated id 96
   0: (bf) r6 = r1
   1: (69) r7 = *(u16 *)(r6 +176)
   2: (b4) w8 = 0
   3: (44) w8 |= 2
   4: (b7) r0 = 1
   5: (55) if r8 != 0x2 goto pc+1
   6: (b7) r0 = 0
   7: (95) exit
```
