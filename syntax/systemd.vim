" Filename:     systemd.vim
" Purpose:      Vim syntax file
" Language:     systemd unit files
" Maintainer:   Will Woods <wwoods@redhat.com>
" Last Change:  Sep 15, 2011

" === Preamble ===

if exists("b:current_syntax") && !exists ("g:syntax_debug")
  finish
endif

syn case match
syntax sync fromstart
setlocal iskeyword+=-
syn iskeyword @,48-57,_,192-255,-,@-@

" === 1. Common syntactical elements ===

" hilight errors with this
syn match sdErr contained /\s*\S\+/ nextgroup=sdErr
" this doesn't set nextgroup - useful for list items
syn match sdErrItem contained /\S\+/ contains=sdErr

" comments
syn match   sdComment /^[;#].*/ contains=sdTodo containedin=ALL
syn keyword sdTodo contained TODO XXX FIXME NOTE

" format strings and environment args
syn match sdFormatStr contained /%[aAbBcCdDeEfgGhHiIjJlLmMnNoOpPqrRsStTuUvVwWyY%]/ containedin=ALLBUT,sdComment,sdErr
syn match sdEnvArg    contained /\$\i\+\|\${\i\+}/

" === 2. Common value types ===

" --- Primitives ---
syn match sdUInt     contained nextgroup=sdErr /\d\+/
syn match sdInt      contained nextgroup=sdErr /-\=\d\+/
syn match sdOctal    contained nextgroup=sdErr /0\=\o\{3,4}/
syn match sdPercent  contained nextgroup=sdErr /\d\+%/
syn match sdDatasize contained nextgroup=sdErr /\d\+[KMGT]/
syn keyword sdBool   contained nextgroup=sdErr 1 yes true on 0 no false off
syn keyword sdInfinity contained infinity
syn match sdByteVal  contained /\<\%(\d\|\d\d\|1\d\d\|2[0-4]\d\|25[0-5]\)\>/

" --- sdDuration, sdCalendar: see systemd.time(7) ---
syn match sdDuration contained nextgroup=sdErr /\d\+/
syn match sdDuration contained nextgroup=sdErr /\%(\d\+\s*\%(usec\|msec\|seconds\=\|minutes\=\|hours\=\|days\=\|weeks\=\|months\=\|years\=\|us\|ms\|sec\|min\|hr\|[smhdwMy]\)\s*\)\+/

syn keyword sdCalendarDayNames Monday Tuesday Wednesday Thursday Friday Saturday Sunday Mon Tue Wed Thu Fri Sat Sun
syn keyword sdCalendarInterval minutely hourly daily monthly weekly yearly quarterly semiannually
syn match sdCalendarDays contained /\i\+\,\=\|\i\+\.\.\i\+\,\=/ contains=sdCalendarDayNames,sdErr
syn match sdCalendarRepeat contained /\/\d\+\%(\.\d\+\)\=/
syn match sdCalendarSep  contained /[,~:-]\|../
syn match sdCalendarYear contained /\d{4}\|\*/
syn match sdCalendarMonth contained /0\=[1-9]\|1[012]\|*/
syn match sdCalendarDay contained /0\=[1-9]\|12[0-9]\|3[01]\|*/
syn match sdCalendarHour contained /[01]\=[0-9]\|2[0-4]\|*/
syn match sdCalendarMinute contained /[0-5]\=[0-9]\|*/
syn match sdCalendarSecond contained /\%([0-5]\=[0-9]\|60\)\%(\.\d+\)\=\|\*/
syn match sdCalendarTZ contained /UTC\|\i\+\/\i\+/
syn match sdCalendar contained /\%([A-Za-z,.]\+\s+\)\=\%([0-9*.,/-]\+\%(\s\+[0-9*.,/:]\+\)\=\|[0-9*.,/:]\+\)\%(\s\+\w\+\/\w\+\)/

" Calendar examples, from systemd.time(7)
"              Sat,Thu,Mon..Wed,Sat..Sun → Mon..Thu,Sat,Sun *-*-* 00:00:00
"                  Mon,Sun 12-*-* 2,1:23 → Mon,Sun 2012-*-* 01,02:23:00
"                                Wed *-1 → Wed *-*-01 00:00:00
"                       Wed..Wed,Wed *-1 → Wed *-*-01 00:00:00
"                             Wed, 17:48 → Wed *-*-* 17:48:00
"            Wed..Sat,Tue 12-10-15 1:2:3 → Tue..Sat 2012-10-15 01:02:03
"                            *-*-7 0:0:0 → *-*-07 00:00:00
"                                  10-15 → *-10-15 00:00:00
"                    monday *-12-* 17:00 → Mon *-12-* 17:00:00
"              Mon,Fri *-*-3,1,2 *:30:45 → Mon,Fri *-*-01,02,03 *:30:45
"                   12,14,13,12:20,10,30 → *-*-* 12,13,14:10,20,30:00
"                        12..14:10,20,30 → *-*-* 12..14:10,20,30:00
"              mon,fri *-1/2-1,3 *:30:45 → Mon,Fri *-01/2-01,03 *:30:45
"                         03-05 08:05:40 → *-03-05 08:05:40
"                               08:05:40 → *-*-* 08:05:40
"                                  05:40 → *-*-* 05:40:00
"                 Sat,Sun 12-05 08:05:40 → Sat,Sun *-12-05 08:05:40
"                       Sat,Sun 08:05:40 → Sat,Sun *-*-* 08:05:40
"                       2003-03-05 05:40 → 2003-03-05 05:40:00
"             05:40:23.4200004/3.1700005 → *-*-* 05:40:23.420000/3.170001
"                         2003-02..04-05 → 2003-02..04-05 00:00:00
"                   2003-03-05 05:40 UTC → 2003-03-05 05:40:00 UTC
"                             2003-03-05 → 2003-03-05 00:00:00
"                                  03-05 → *-03-05 00:00:00
"                                 hourly → *-*-* *:00:00
"                                  daily → *-*-* 00:00:00
"                              daily UTC → *-*-* 00:00:00 UTC
"                                monthly → *-*-01 00:00:00
"                                 weekly → Mon *-*-* 00:00:00
"                weekly Pacific/Auckland → Mon *-*-* 00:00:00 Pacific/Auckland
"                                 yearly → *-01-01 00:00:00
"                               annually → *-01-01 00:00:00
"                                  *:2/3 → *-*-* *:02/3:00

" --- Filenames ---
syn match sdFilename       contained nextgroup=sdErr /\/\S*/
syn match sdFileList       contained /.*/ contains=sdFilename,sdErr

" --- Unit names ---
syn match sdUnitName       contained /\S\+\.\(automount\|mount\|swap\|socket\|service\|target\|path\|timer\|device\|slice\|scope\)\_s/
syn match sdUnit           contained /\S\+/ contains=sdUnitName,sdErr nextgroup=sdErr
syn match sdUnitList       contained /.\+/ contains=sdUnitName,sdErr

" --- Users ---
syn match sdUser           contained nextgroup=sdErr /\d\+\|[A-Za-z_][A-Za-z0-9_-]*/ contains=sdFormatStr
syn match sdUser           contained nextgroup=sdErr /%[A-Za-z%]\+/ contains=sdFormatStr
syn keyword sdUserGroup    contained @system

" --- Resource limits ---
syn match sdRlimit         contained nextgroup=sdErr /\<\%(\d\+\|infinity\)\>\%(:\%(\d\+\|infinity\)\)\=/

" --- Documentation URIs ---
syn match sdDocUri         contained /\%(https\=:\/\/\|file:\|info:\|man:\)\S\+\s*/ nextgroup=sdDocUri,sdErr

" === 3. Common flag types ===

syn match sdConditionFlag  contained /[!|]/
syn match sdExecFlag       contained /-\=@\=/ nextgroup=sdExecFile,sdErr
syn match sdEnvDashFlag    contained /-/ nextgroup=sdFilename,sdErr

" === 4. Voluminous keyword lists ===

" type identifiers used in `systemd --dump-config`, from most to least common:
" 189 OTHER
" 179 BOOLEAN
" 136 LIMIT
"  46 CONDITION
"  36 WEIGHT
"  30 MODE
"  27 PATH
"  25 PATH [...]
"  24 SECONDS, STRING
"  20 SIGNAL
"  15 UNIT [...]
"  12 BANDWIDTH, DEVICEWEIGHT, SHARES, UNSIGNED
"  11 PATH [ARGUMENT [...]]
"   8 BOUNDINGSET, LEVEL, OUTPUT, PATH[:PATH[:OPTIONS]] [...], SOCKET [...]
"   6 ACTION, DEVICE, DEVICELATENCY, POLICY, SLICE, TIMER
"   5 KILLMODE
"   4 ARCHS, CPUAFFINITY, CPUSCHEDPOLICY, CPUSCHEDPRIO, ENVIRON, ERRNO, FACILITY, FAMILIES, FILE, INPUT, IOCLASS, IOPRIORITY, LABEL, MOUNTFLAG [...], NAMESPACES, NANOSECONDS, NICE, NOTSUPPORTED, OOMSCOREADJUST, PERSONALITY, SECUREBITS, SYSCALLS
"   3 INTEGER, SIZE, STATUS
"   2 LONG, UNIT
"   1 ACCESS, NETWORKINTERFACE, SERVICE, SERVICERESTART, SERVICETYPE, SOCKETBIND, SOCKETS, TOS, URL

" see signal(7)
"   - generated with `command kill -L`
"   - e.g. `command kill -L | awk '{ print "SIG" $2 }' | tr '\n' ' '`
syn keyword sdSignalName contained SIGHUP SIGINT SIGQUIT SIGILL SIGTRAP SIGABRT SIGIOT SIGBUS SIGFPE SIGKILL SIGUSR1 SIGSEGV SIGUSR2 SIGPIPE SIGALRM SIGTERM SIGSTKFLT SIGCHLD SIGCLD SIGCONT SIGSTOP SIGTSTP SIGTTIN SIGTTOU SIGURG SIGXCPU SIGXFSZ SIGVTALRM SIGPROF SIGWINCH SIGIO SIGPOLL SIGPWR SIGSYS SIGRTMIN SIGRTMAX
syn match sdSignal     /SIG\w\+/ contained contains=sdSignalName,sdErr nextgroup=sdErr
syn match sdSignalList /.\+/     contained contains=sdSignalName,sdByteVal,sdErrItem

" see systemd.exec(5), "PROCESS EXIT CODES"
"   - generated with `systemd-analyze exit-status`
syn keyword sdExitStatusName contained SUCCESS FAILURE INVALIDARGUMENT NOTIMPLEMENTED NOPERMISSION NOTINSTALLED NOTCONFIGURED NOTRUNNING USAGE DATAERR NOINPUT NOUSER NOHOST UNAVAILABLE SOFTWARE OSERR OSFILE CANTCREAT IOERR TEMPFAIL PROTOCOL NOPERM CONFIG CHDIR NICE FDS EXEC MEMORY LIMITS OOM_ADJUST SIGNAL_MASK STDIN STDOUT CHROOT IOPRIO TIMERSLACK SECUREBITS SETSCHEDULER CPUAFFINITY GROUP USER CAPABILITIES CGROUP SETSID CONFIRM STDERR PAM NETWORK NAMESPACE NO_NEW_PRIVILEGES SECCOMP SELINUX_CONTEXT PERSONALITY APPARMOR ADDRESS_FAMILIES RUNTIME_DIRECTORY CHOWN SMACK_PROCESS_LABEL KEYRING STATE_DIRECTORY CACHE_DIRECTORY LOGS_DIRECTORY CONFIGURATION_DIRECTORY NUMA_POLICY CREDENTIALS BPF KSM MEMORY_THP EXCEPTION
syn match sdExitStatusNum  /\d\+/ contained contains=sdByteVal nextgroup=sdErr
syn match sdExitStatus     /\S\+/ contained contains=sdExitStatusName,sdExitStatusNum nextgroup=sdErr
syn match sdExitStatusList /.*/   contained contains=sdExitStatusName,sdSignalName,sdByteVal,sdErrItem

" see capabilities(7), cap_text_formats(7)
"   - generated with `systemd-analyze capabilities`
syn case ignore
syn keyword sdCapName       contained CAP_CHOWN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_FOWNER CAP_FSETID CAP_KILL CAP_SETGID CAP_SETUID CAP_SETPCAP CAP_LINUX_IMMUTABLE CAP_NET_BIND_SERVICE CAP_NET_BROADCAST CAP_NET_ADMIN CAP_NET_RAW CAP_IPC_LOCK CAP_IPC_OWNER CAP_SYS_MODULE CAP_SYS_RAWIO CAP_SYS_CHROOT CAP_SYS_PTRACE CAP_SYS_PACCT CAP_SYS_ADMIN CAP_SYS_BOOT CAP_SYS_NICE CAP_SYS_RESOURCE CAP_SYS_TIME CAP_SYS_TTY_CONFIG CAP_MKNOD CAP_LEASE CAP_AUDIT_WRITE CAP_AUDIT_CONTROL CAP_SETFCAP CAP_MAC_OVERRIDE CAP_MAC_ADMIN CAP_SYSLOG CAP_WAKE_ALARM CAP_BLOCK_SUSPEND CAP_AUDIT_READ CAP_PERFMON CAP_BPF CAP_CHECKPOINT_RESTORE
syn match   sdCapNameList   contained /.*/ contains=sdAnyCapName,sdErr
syn match   sdAnyCapName    contained /CAP_[A-Z_]\+\s*/ contains=sdCapName
syn case match
syn cluster sdCap           contains=sdCapName,sdCapOps,sdCapFlags
syn match   sdCapOps        contained /[=+-]/
syn match   sdCapFlags      contained /\<[eip]\+/
syn match   sdCapability    contained /\%(\%([A-Za-z_]\+,\=\)*\|all\)\%(=[eip]*\|[+-][eip]\+\)\s*/ contains=@sdCap nextgroup=sdCapability,sdErr

" see syscalls(2)
"   - generated with `systemd-analyze syscall-filter` (as root)
"   - groups:
"     systemd-analyze syscall-filter \
"       | grep -E '^@'
"   - syscalls:
"     systemd-analyze syscall-filter \
"       | sed -r 's|^#   |    |' \
"       | sed -nr 's|^    (.+)|\1|p' \
"       | grep -E -v '^(@|#)' \
"       | sort -u
syn keyword sdSystemCallGroup contained @default @aio @basic-io @chown @clock @cpu-emulation @debug @file-system @io-event @ipc @keyring @memlock @module @mount @network-io @obsolete @pkey @privileged @process @raw-io @reboot @resources @sandbox @setuid @signal @swap @sync @system-service @timer @known
syn keyword sdSystemCallName  contained accept accept4 access acct add_key adjtimex afs_syscall alarm arc_gettls arch_prctl arc_settls arc_usr_cmpxchg arm_fadvise64_64 atomic_barrier atomic_cmpxchg_32 bdflush bind bpf break breakpoint brk cachectl cacheflush cachestat capget capset chdir chmod chown chown32 chroot clock_adjtime clock_adjtime64 clock_getres clock_getres_time64 clock_gettime clock_gettime64 clock_nanosleep clock_nanosleep_time64 clock_settime clock_settime64 clone clone3 close close_range connect copy_file_range creat create_module delete_module dipc dup dup2 dup3 epoll_create epoll_create1 epoll_ctl epoll_ctl_old epoll_pwait epoll_pwait2 epoll_wait epoll_wait_old eventfd eventfd2 execv execve execveat exec_with_loader exit exit_group faccessat faccessat2 fadvise64 fadvise64_64 fallocate fanotify_init fanotify_mark fchdir fchmod fchmodat fchmodat2 fchown fchown32 fchownat fcntl fcntl64 fdatasync fgetxattr file_getattr file_setattr finit_module flistxattr flock fork fremovexattr fsconfig fsetxattr fsmount fsopen fspick fstat fstat64 fstatat fstatat64 fstatfs fstatfs64 fsync ftime ftruncate ftruncate64 futex futex_requeue futex_time64 futex_wait futex_waitv futex_wake futimesat getcpu getcwd getdents getdents64 getdomainname getdtablesize getegid getegid32 geteuid geteuid32 getgid getgid32 getgroups getgroups32 gethostname getitimer get_kernel_syms get_mempolicy getpagesize getpeername getpgid getpgrp getpid getpmsg getppid getpriority getrandom getresgid getresgid32 getresuid getresuid32 getrlimit get_robust_list getrusage getsid getsockname getsockopt get_thread_area gettid gettimeofday get_tls getuid getuid32 getxattr getxattrat getxgid getxpid getxuid gtty idle init_module inotify_add_watch inotify_init inotify_init1 inotify_rm_watch io_cancel ioctl io_destroy io_getevents ioperm io_pgetevents io_pgetevents_time64 iopl ioprio_get ioprio_set io_setup io_submit io_uring_enter io_uring_register io_uring_setup ipc kcmp kern_features kexec_file_load kexec_load keyctl kill landlock_add_rule landlock_create_ruleset landlock_restrict_self lchown lchown32 lgetxattr link linkat listen listmount listns listxattr listxattrat llistxattr _llseek llseek lock lookup_dcookie lremovexattr lseek lsetxattr lsm_get_self_attr lsm_list_modules lsm_set_self_attr lstat lstat64 madvise map_shadow_stack mbind membarrier memfd_create memfd_secret memory_ordering migrate_pages mincore mkdir mkdirat mknod mknodat mlock mlock2 mlockall mmap mmap2 modify_ldt mount mount_setattr move_mount move_pages mprotect mpx mq_getsetattr mq_notify mq_open mq_timedreceive mq_timedreceive_time64 mq_timedsend mq_timedsend_time64 mq_unlink mremap mseal msgctl msgget msgrcv msgsnd msync multiplexer munlock munlockall munmap name_to_handle_at nanosleep newfstat newfstatat _newselect nfsservctl nice old_adjtimex oldfstat oldlstat oldolduname oldstat oldumount olduname open openat openat2 open_by_handle_at open_tree open_tree_attr or1k_atomic osf_fstat osf_fstatfs osf_fstatfs64 osf_getdirentries osf_getdomainname osf_getitimer osf_getrusage osf_getsysinfo osf_gettimeofday osf_lstat osf_mount osf_proplist_syscall osf_select osf_setitimer osf_set_program_attributes osf_setsysinfo osf_settimeofday osf_shmat osf_sigprocmask osf_sigstack osf_stat osf_statfs osf_statfs64 osf_swapon osf_syscall osf_sysinfo osf_usleep_thread osf_utimes osf_utsname osf_wait4 pause pciconfig_iobase pciconfig_read pciconfig_write perfctr perf_event_open personality pidfd_getfd pidfd_open pidfd_send_signal pipe pipe2 pivot_root pkey_alloc pkey_free pkey_mprotect poll ppoll ppoll_time64 prctl pread64 preadv preadv2 prlimit64 process_madvise process_mrelease process_vm_readv process_vm_writev prof profil pselect6 pselect6_time64 ptrace putpmsg pwrite64 pwritev pwritev2 query_module quotactl quotactl_fd read readahead readdir readlink readlinkat readv reboot recv recvfrom recvmmsg recvmmsg_time64 recvmsg remap_file_pages removexattr removexattrat rename renameat renameat2 request_key restart_syscall riscv_flush_icache riscv_hwprobe rmdir rseq rtas rt_sigaction rt_sigpending rt_sigprocmask rt_sigqueueinfo rt_sigreturn rt_sigsuspend rt_sigtimedwait rt_sigtimedwait_time64 rt_tgsigqueueinfo s390_guarded_storage s390_pci_mmio_read s390_pci_mmio_write s390_runtime_instr s390_sthyi sched_get_affinity sched_getaffinity sched_getattr sched_getparam sched_get_priority_max sched_get_priority_min sched_getscheduler sched_rr_get_interval sched_rr_get_interval_time64 sched_set_affinity sched_setaffinity sched_setattr sched_setparam sched_setscheduler sched_yield seccomp security select semctl semget semop semtimedop semtimedop_time64 send sendfile sendfile64 sendmmsg sendmsg sendto setdomainname setfsgid setfsgid32 setfsuid setfsuid32 setgid setgid32 setgroups setgroups32 sethae sethostname setitimer set_mempolicy set_mempolicy_home_node setns setpgid setpgrp setpriority setregid setregid32 setresgid setresgid32 setresuid setresuid32 setreuid setreuid32 setrlimit set_robust_list setsid setsockopt set_thread_area set_tid_address settimeofday set_tls setuid setuid32 setxattr setxattrat sgetmask shmat shmctl shmdt shmget shutdown sigaction sigaltstack signal signalfd signalfd4 sigpending sigprocmask sigreturn sigsuspend socket socketcall socketpair splice spu_create spu_run ssetmask stat stat64 statfs statfs64 statmount statx stime stty subpage_prot swapcontext swapoff swapon switch_endian symlink symlinkat sync sync_file_range sync_file_range2 syncfs syscall _sysctl sys_debug_setcontext sysfs sysinfo syslog sysmips tee tgkill time timer_create timer_delete timerfd timerfd_create timerfd_gettime timerfd_gettime64 timerfd_settime timerfd_settime64 timer_getoverrun timer_gettime timer_gettime64 timer_settime timer_settime64 times tkill truncate truncate64 tuxcall ugetrlimit ulimit umask umount umount2 uname unlink unlinkat unshare uprobe uretprobe uselib userfaultfd usr26 usr32 ustat utime utimensat utimensat_time64 utimes utrap_install vfork vhangup vm86 vm86old vmsplice vserver wait4 waitid waitpid write writev

" see systemd.unit(5), ConditionVirtualization=
"   - generated with `systemd-detect-virt --list`
syn keyword sdVirtType     contained nextgroup=sdErr none kvm amazon qemu bochs xen uml vmware oracle microsoft zvm parallels bhyve qnx acrn powervm apple sre google vm-other systemd-nspawn lxc-libvirt lxc openvz docker podman rkt wsl proot pouch container-other

" see systemd.unit(5), ConditionSecurity=
syn keyword sdSecurityType contained nextgroup=sdErr selinux apparmor tomoyo smack ima audit uefi-secureboot tpm2 cvm measured-uki

" see systemd.unit(5), ConditionArchitecture=
"   - generated with `systemd-analyze architectures`
"   - `native` is a special value
syn keyword sdArch         contained nextgroup=sdErr native alpha arc arc-be arm arm64 arm64-be arm-be cris ia64 loongarch64 m68k mips mips64 mips64-le mips-le nios2 parisc parisc64 ppc ppc64 ppc64-le ppc-le riscv32 riscv64 s390 s390x sh sh64 sparc sparc64 tilegx x86 x86-64

" Source: src/basic/cgroup-util.c — cgroup_controller_table[]
syn keyword sdControllerName contained cpu cpuacct cpuset io blkio memory devices pids bpf-firewall bpf-devices bpf-foreign bpf-socket-bind bpf-restrict-network-interfaces bpf-bind-network-interface
syn match   sdControllerList contained /.*/ contains=sdControllerName,sdErrItem

" === 5. Exec context keys and value types ===
" (for [Service|Socket|Mount|Swap])
" see systemd.exec(5)

syn match sdExecKey contained /^Exec\%(Start\%(Pre\|Post\|\)\|Reload\|Stop\|StopPost\|Condition\)=/ nextgroup=sdExecFlag,sdExecFile,sdErr
syn match sdExecKey contained /^\%(WorkingDirectory\|RootDirectory\|TTYPath\|RootImage\)=/ nextgroup=sdFilename,sdErr
syn match sdExecKey contained /^\%(Runtime\|State\|Cache\|Logs\|Configuration\)Directory=/ nextgroup=sdFilename,sdErr
syn match sdExecKey contained /^\%(Runtime\|State\|Cache\|Logs\|Configuration\)DirectoryMode=/ nextgroup=sdOctal,sdErr
syn match sdExecKey contained /^User=/ nextgroup=sdUser,sdErr
syn match sdExecKey contained /^Group=/ nextgroup=sdUser,sdErr
syn match sdExecKey contained /^\%(SupplementaryGroups\|CPUAffinity\|SyslogIdentifier\|PAMName\|TCPWrapName\|ControlGroup\|ControlGroupAttribute\|UtmpIdentifier\)=/
syn match sdExecKey contained /^Limit\%(CPU\|FSIZE\|DATA\|STACK\|CORE\|RSS\|NOFILE\|AS\|NPROC\|MEMLOCK\|LOCKS\|SIGPENDING\|MSGQUEUE\|NICE\|RTPRIO\|RTTIME\)=/ nextgroup=sdRlimit
syn match sdExecKey contained /^\%(CPUSchedulingResetOnFork\|TTYReset\|TTYVHangup\|TTYVTDisallocate\|SyslogLevelPrefix\|ControlGroupModify\|DynamicUser\|RemoveIPC\|NoNewPrivileges\|RestrictRealtime\|RestrictSUIDSGID\|LockPersonality\|MountAPIVFS\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^Private\%(Tmp\|Network\|Devices\|Users\|Mounts\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^Protect\%(KernelTunables\|KernelModules\|KernelLogs\|Clock\|ControlGroups\|Hostname\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^\%(Nice\|OOMScoreAdjust\)=/ nextgroup=sdInt,sdErr
syn match sdExecKey contained /^\%(CPUSchedulingPriority\|TimerSlackNSec\)=/ nextgroup=sdUInt,sdErr
" 'ReadOnlyDirectories' et al. are obsolete versions of ReadOnlyPaths' et al.
syn match sdExecKey contained /^\%(ReadWrite\|ReadOnly\|Inaccessible\)Directories=/ nextgroup=sdFileList
syn match sdExecKey contained /^\%(ReadWrite\|ReadOnly\|Inaccessible\|Exec\|NoExec\)Paths=/ nextgroup=sdExecPathList
syn match sdExecKey contained /^CapabilityBoundingSet=/ nextgroup=sdCapNameList
syn match sdExecKey contained /^Capabilities=/ nextgroup=sdCapability,sdErr
syn match sdExecKey contained /^UMask=/ nextgroup=sdOctal,sdErr
syn match sdExecKey contained /^StandardInput=/ nextgroup=sdStdin,sdErr
syn match sdExecKey contained /^Standard\%(Output\|Error\)=/ nextgroup=sdStdout,sdErr
syn match sdExecKey contained /^SecureBits=/ nextgroup=sdSecureBitList
syn match sdExecKey contained /^SyslogFacility=/ nextgroup=sdSyslogFacil,sdErr
syn match sdExecKey contained /^SyslogLevel=/ nextgroup=sdSyslogLevel,sdErr
syn match sdExecKey contained /^IOSchedulingClass=/ nextgroup=sdIOSchedClass,sdErr
syn match sdExecKey contained /^IOSchedulingPriority=/ nextgroup=sdIOSchedPrio,sdErr
syn match sdExecKey contained /^CPUSchedulingPolicy=/ nextgroup=sdCPUSchedPol,sdErr
syn match sdExecKey contained /^MountFlags=/ nextgroup=sdMountFlags,sdErr
syn match sdExecKey contained /^\%(IgnoreSIGPIPE\|MemoryDenyWriteExecute\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^Environment=/ nextgroup=sdEnvDefs
syn match sdExecKey contained /^EnvironmentFile=-\=/ contains=sdEnvDashFlag nextgroup=sdFilename,sdErr
" These are also shared by [Service|Socket|Mount|Swap], although they're not
" listed in systemd.exec(5)
syn match sdExecKey contained /^TimeoutSec=/ nextgroup=sdDuration,sdErr

" --- Exec context value types ---
syn match   sdExecFile      contained /\S\+/ nextgroup=sdExecArgs
syn match   sdExecArgs      contained /.*/ contains=sdEnvArg
syn match   sdEnvDefs       contained /.*/ contains=sdEnvDef
syn match   sdEnvDef        contained /\i\+=/he=e-1
syn match   sdExecPathList  contained /.*/ contains=sdExecPath,sdErr
syn match   sdExecPath      contained /-\=+\=\/\S\+\s*/
syn keyword sdStdin         contained nextgroup=sdErr null tty tty-force tty-fail socket data
syn match   sdStdin         contained nextgroup=sdErr /\%(fd\|file\):\S\+/
syn match   sdStdout        contained nextgroup=sdErr /\%(syslog\|kmsg\|journal\)\%(+console\)\=/
syn match   sdStdout        contained nextgroup=sdErr /\%(fd\|file\|append\|truncate\):\S\+/
syn keyword sdStdout        contained nextgroup=sdErr inherit null tty socket
syn keyword sdSyslogFacil   contained nextgroup=sdErr kern user mail daemon auth syslog lpr news uucp cron authpriv ftp
syn match   sdSyslogFacil   contained nextgroup=sdErr /\<local[0-7]\>/
syn keyword sdSyslogLevel   contained nextgroup=sdErr emerg alert crit err warning notice info debug
syn keyword sdIOSchedClass  contained nextgroup=sdErr 0 1 2 3 none realtime best-effort idle
syn keyword sdIOSchedPrio   contained nextgroup=sdErr 0 1 2 3 4 5 6 7
syn keyword sdCPUSchedPol   contained nextgroup=sdErr other batch idle fifo rr
syn keyword sdMountFlags    contained nextgroup=sdErr shared slave private
syn keyword sdSecureBits    contained nextgroup=sdErr keep-caps keep-caps-locked noroot noroot-locked no-setuid-fixup no-setuid-fixup-locked

" --- Exec context enum types ---
" Source: src/core/namespace.h — ProtectSystem
syn keyword sdProtectSystem   contained nextgroup=sdErr full strict
" Source: src/core/namespace.h — ProtectHome
syn keyword sdProtectHome     contained nextgroup=sdErr read-only tmpfs
" Source: src/core/namespace.h — ProtectProc
syn keyword sdProtectProc     contained nextgroup=sdErr default noaccess invisible ptraceable
" Source: src/core/namespace.h — ProcSubset
syn keyword sdProcSubset      contained nextgroup=sdErr all pid
" Source: src/core/execute.h — ExecKeyringMode
syn keyword sdKeyringMode     contained nextgroup=sdErr inherit private shared
" Source: src/core/execute.h — ExecPreserveMode
syn keyword sdPreserveMode    contained nextgroup=sdErr restart
" Source: src/core/namespace.h — ProtectHostname
syn keyword sdProtectHostname contained nextgroup=sdErr private
" Source: src/core/namespace.h — ProtectControlGroups
syn keyword sdProtectCG       contained nextgroup=sdErr private strict
" Source: src/core/namespace.h — PrivateTmp
syn keyword sdPrivateTmp      contained nextgroup=sdErr connected disconnected
" Source: src/core/namespace.h — PrivateUsers
syn keyword sdPrivateUsers    contained nextgroup=sdErr self identity full managed
" Source: src/core/execute.h — MemoryTHP
syn keyword sdMemoryTHP       contained nextgroup=sdErr inherit disable madvise system
" Source: src/core/namespace.h — namespace flags
syn keyword sdNamespace       contained nextgroup=sdErr cgroup ipc net mnt pid user uts time

" === 6. Kill context keys and value types ===
" (for [Service|Socket|Mount|Swap|Scope])
" see systemd.kill(5)

syn match sdKillKey  contained /^KillSignal=/ nextgroup=sdSignal,sdErr
syn match sdKillKey  contained /^KillMode=/ nextgroup=sdKillMode,sdErr
syn match sdKillKey  contained /^\%(SendSIGKILL\|SendSIGHUP\)=/ nextgroup=sdBool,sdErr

" --- Kill context value types ---
syn keyword sdKillMode contained nextgroup=sdErr control-group cgroup process mixed none

" === 7. Resource control (cgroup) context keys and value types ===
" (for [Service|Socket|Mount|Swap|Slice|Scope])
" see systemd.resource-control(5)

syn match sdResCtlKey contained /^Slice=/ nextgroup=sdSliceName,sdErr
syn match sdResCtlKey contained /^\%(CPUAccounting\|MemoryAccounting\|IOAccounting\|BlockIOAccounting\|TasksAccounting\|IPAccounting\|Delegate\)=/ nextgroup=sdBool,sdErr
syn match sdResCtlKey contained /^\%(CPUQuota\)=/ nextgroup=sdPercent,sdErr
syn match sdResCtlKey contained /^\%(CPUShares\|StartupCPUShares\)=/ nextgroup=sdUInt,sdErr
syn match sdResCtlKey contained /^MemoryLow=/ nextgroup=sdDatasize,sdPercent,sdErr
syn match sdResCtlKey contained /^\%(MemoryLimit\|MemoryHigh\|MemoryMax\)=/ nextgroup=sdDatasize,sdPercent,sdInfinity,sdErr
syn match sdResCtlKey contained /^TasksMax=/ nextgroup=sdUInt,sdInfinity,sdErr
syn match sdResCtlKey contained /^\%(IOWeight\|StartupIOWeight\|BlockIOWeight\|StartupBlockIOWeight\)=/ nextgroup=sdUInt,sdErr
syn match sdResCtlKey contained /^DeviceAllow=/ nextgroup=sdDevAllow,sdErr
syn match sdResCtlKey contained /^DevicePolicy=/ nextgroup=sdDevPolicy,sdErr

" --- Resource control value types ---
syn match sdSliceName contained /\S\+\.slice\_s/ contains=sdUnitName

syn match   sdDevAllow      contained /\%(\/dev\/\|char-\|block-\)\S\+\s\+/ nextgroup=sdDevAllowPerm
syn match   sdDevAllowPerm  contained /\S\+/ contains=sdDevAllowErr nextgroup=sdErr
syn match   sdDevAllowErr   contained /[^rwm]\+/
syn keyword sdDevPolicy     contained strict closed auto

" --- Resource control enum types ---
" Source: src/basic/cgroup-util.h — ManagedOOMMode
syn keyword sdManagedOOMMode  contained nextgroup=sdErr auto kill
" Source: src/basic/cgroup-util.h — ManagedOOMPreference
syn keyword sdManagedOOMPref  contained nextgroup=sdErr none avoid omit
" Source: src/core/cgroup.h — CGroupPressureWatch
syn keyword sdPressureWatch   contained nextgroup=sdErr auto skip
" Source: src/shared/cgroup-setup.c — cg_cpu_weight_parse
syn keyword sdCPUWeight       contained nextgroup=sdErr idle
" --- Resource control compound types ---
" Source: src/core/load-fragment.c — config_parse_io_device_weight
syn match   sdDeviceWeight    contained /\/\S\+\s\+/ nextgroup=sdUInt,sdErr
" Source: src/core/load-fragment.c — config_parse_io_device_latency
syn match   sdDeviceLatency   contained /\/\S\+\s\+/ nextgroup=sdDuration,sdErr
" Source: src/core/load-fragment.c — config_parse_io_limit
syn match   sdIOLimit         contained /\/\S\+\s\+/ nextgroup=sdDatasize,sdInfinity,sdErr

" === 8. Section blocks and section-specific keys ===

" --- [Unit] ---
" see systemd.unit(5)
syn region sdUnitBlock matchgroup=sdHeader start=/^\[Unit\]/ end=/^\[/me=e-2 contains=sdUnitKey
syn match sdUnitKey contained /^Description=/
syn match sdUnitKey contained /^Documentation=/ nextgroup=sdDocUri
syn match sdUnitKey contained /^SourcePath=/ nextgroup=sdFilename,sdErr
syn match sdUnitKey contained /^\%(Requires\|RequiresOverridable\|Requisite\|RequisiteOverridable\|Wants\|Binds\=To\|PartOf\|Conflicts\|Before\|After\|OnFailure\|Names\|Propagates\=ReloadTo\|ReloadPropagatedFrom\|PropagateReloadFrom\|JoinsNamespaceOf\)=/ nextgroup=sdUnitList
syn match sdUnitKey contained /^\%(OnFailureIsolate\|IgnoreOnIsolate\|IgnoreOnSnapshot\|StopWhenUnneeded\|RefuseManualStart\|RefuseManualStop\|AllowIsolate\|DefaultDependencies\)=/ nextgroup=sdBool,sdErr
syn match sdUnitKey contained /^OnFailureJobMode=/ nextgroup=sdJobMode,sdErr
syn match sdUnitKey contained /^\%(StartLimitInterval\|StartLimitIntervalSec\|JobTimeoutSec\)=/ nextgroup=sdDuration,sdErr
syn match sdUnitKey contained /^\%(StartLimitAction\|JobTimeoutAction\)=/ nextgroup=sdEmergencyAction,sdErr
syn match sdUnitKey contained /^StartLimitBurst=/ nextgroup=sdUInt,sdErr
syn match sdUnitKey contained /^\%(FailureAction\|SuccessAction\)=/ nextgroup=sdEmergencyAction,sdErr
syn match sdUnitKey contained /^\%(FailureAction\|SuccessAction\)ExitStatus=/ nextgroup=sdExitStatusNum,sdErr
syn match sdUnitKey contained /^\%(RebootArgument\|JobTimeoutRebootArgument\)=/
syn match sdUnitKey contained /^RequiresMountsFor=/ nextgroup=sdFileList,sdErr
" ConditionXXX/AssertXXX. Note that they all have an optional '|' after the '='.
syn match sdUnitKey contained /^\%(Condition\|Assert\)\(PathExists\|PathExistsGlob\|PathIsDirectory\|PathIsMountPoint\|PathIsReadWrite\|PathIsSymbolicLink\|DirectoryNotEmpty\|FileNotEmpty\|FileIsExecutable\)=|\=!\=/ contains=sdConditionFlag nextgroup=sdFilename,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Virtualization=|\=!\=/ contains=sdConditionFlag nextgroup=sdVirtType,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Security=|\=!\=/ contains=sdConditionFlag nextgroup=sdSecurityType,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Capability=|\=!\=/ contains=sdConditionFlag nextgroup=sdAnyCapName,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)\%(KernelCommandLine\|Host\)=|\=!\=/ contains=sdConditionFlag
syn match sdUnitKey contained /^\%(Condition\|Assert\)\%(ACPower\|Null\|FirstBoot\)=|\=/ contains=sdConditionFlag nextgroup=sdBool,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)NeedsUpdate=|\=!\=/ contains=sdConditionFlag nextgroup=sdCondUpdateDir,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Architecture=|\=!\=/ contains=sdConditionFlag nextgroup=sdArch,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)User=|\=/ contains=sdConditionFlag nextgroup=sdUser,sdUserGroup,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Group=|\=/ contains=sdConditionFlag nextgroup=sdUser,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)ControlGroupController=|\=/ contains=sdConditionFlag nextgroup=sdCgroupVer,sdControllerList,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)KernelVersion=|\=/ contains=sdConditionFlag nextgroup=sdKernelVersion,sdErr

" --- [Unit] value types ---
" Source: src/shared/condition.c — condition_test_control_group_controller()
syn keyword sdCgroupVer       contained nextgroup=sdErr v1 v2
syn match sdCondUpdateDir     contained nextgroup=sdErr /\/\%(etc\|var\)\/\=/
syn keyword sdJobMode         contained nextgroup=sdErr fail lenient replace replace-irreversibly isolate flush ignore-dependencies ignore-requirements triggering restart-dependencies
syn keyword sdEmergencyAction contained nextgroup=sdErr none exit exit-force reboot reboot-force reboot-immediate poweroff poweroff-force poweroff-immediate soft-reboot soft-reboot-force kexec kexec-force halt halt-force halt-immediate
" Source: src/core/unit.h — CollectMode
syn keyword sdCollectMode     contained nextgroup=sdErr inactive inactive-or-failed

" --- [Install] ---
" see systemd.unit(5)
syn region sdInstallBlock matchgroup=sdHeader start=/^\[Install\]/ end=/^\[/me=e-2 contains=sdInstallKey
syn match sdInstallKey contained /^\%(WantedBy\|Alias\|Also\|RequiredBy\)=/ nextgroup=sdUnitList
syn match sdInstallKey contained /^DefaultInstance=/ nextgroup=sdInstance
" sdInstance: valid instance names are [A-Za-z0-9@:._\\-]+
syn match sdInstance   contained nextgroup=sdErr /[A-Za-z0-9@:._\\-]\+/ contains=sdFormatStr

" --- [Service] ---
syn region sdServiceBlock matchgroup=sdHeader start=/^\[Service\]/ end=/^\[/me=e-2 contains=sdServiceKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdServiceKey contained /^BusName=/
syn match sdServiceKey contained /^\%(RemainAfterExit\|GuessMainPID\|PermissionsStartOnly\|RootDirectoryStartOnly\|NonBlocking\|ControlGroupModify\)=/ nextgroup=sdBool,sdErr
syn match sdServiceKey contained /^\%(SysVStartPriority\|FsckPassNo\)=/ nextgroup=sdUInt,sdErr
syn match sdServiceKey contained /^\%(Restart\|Watchdog\|RuntimeMax\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdServiceKey contained /^Timeout\%(\|Start\|Stop\|Abort\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdServiceKey contained /^Sockets=/ nextgroup=sdUnitList
syn match sdServiceKey contained /^PIDFile=/ nextgroup=sdFilename,sdErr
syn match sdServiceKey contained /^Type=/ nextgroup=sdServiceType,sdErr
syn match sdServiceKey contained /^Restart=/ nextgroup=sdRestartType,sdErr
syn match sdServiceKey contained /^NotifyAccess=/ nextgroup=sdNotifyType,sdErr
syn match sdServiceKey contained /^StartLimitInterval=/ nextgroup=sdDuration,sdErr
syn match sdServiceKey contained /^StartLimitAction=/ nextgroup=sdEmergencyAction,sdErr
syn match sdServiceKey contained /^StartLimitBurst=/ nextgroup=sdUInt,sdErr
syn match sdServiceKey contained /^FailureAction=/ nextgroup=sdEmergencyAction,sdErr
syn match sdServiceKey contained /^\%(RestartPrevent\|RestartForce\)ExitStatus=/ nextgroup=sdSignalList
syn match sdServiceKey contained /^SuccessExitStatus=/ nextgroup=sdExitStatusList
syn match sdServiceKey contained /^RebootArgument=/

" --- [Service] value types ---
syn keyword sdServiceType  contained nextgroup=sdErr simple exec forking dbus oneshot notify notify-reload idle
syn keyword sdRestartType  contained nextgroup=sdErr no on-success on-failure on-abnormal on-watchdog on-abort always
syn keyword sdNotifyType   contained nextgroup=sdErr none all main exec
" Source: src/core/service.h — ServiceExitType
syn keyword sdExitType     contained nextgroup=sdErr main cgroup
" Source: src/core/service.h — ServiceRestartMode
syn keyword sdRestartMode  contained nextgroup=sdErr normal direct debug
" Source: src/core/service.h — ServiceTimeoutFailureMode
syn keyword sdTimeoutMode  contained nextgroup=sdErr terminate abort kill
" Source: src/core/unit.h — OOMPolicy
syn keyword sdOOMPolicy    contained nextgroup=sdErr continue stop kill

" --- [Socket] ---
syn region sdSocketBlock matchgroup=sdHeader start=/^\[Socket\]/ end=/^\[/me=e-2 contains=sdSocketKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdSocketKey contained /^Listen\%(Stream\|Datagram\|SequentialPacket\|FIFO\|Special\|Netlink\|MessageQueue\)=/
syn match sdSocketKey contained /^Listen\%(FIFO\|Special\)=/ nextgroup=sdFilename,sdErr
syn match sdSocketKey contained /^\%(Socket\|Directory\)Mode=/ nextgroup=sdOctal,sdErr
syn match sdSocketKey contained /^\%(Backlog\|MaxConnections\|Priority\|IPTTL\|Mark\|MessageQueueMaxMessages\|MessageQueueMessageSize\)=/ nextgroup=sdUInt,sdErr
syn match sdSocketKey contained /^\%(ReceiveBuffer\|SendBuffer\|PipeSize\)=/ nextgroup=sdDatasize,sdUInt,sdErr
syn match sdSocketKey contained /^\%(Accept\|KeepAlive\|FreeBind\|Transparent\|Broadcast\|Writable\|NoDelay\|PassCredentials\|PassSecurity\|ReusePort\|RemoveOnStop\|SELinuxContextFromNet\)=/ nextgroup=sdBool,sdErr
syn match sdSocketKey contained /^BindToDevice=/
syn match sdSocketKey contained /^Service=/ nextgroup=sdUnit
syn match sdSocketKey contained /^BindIPv6Only=/ nextgroup=sdBindIPv6,sdErr
syn match sdSocketKey contained /^IPTOS=/ nextgroup=sdIPTOS,sdUInt,sdErr
syn match sdSocketKey contained /^TCPCongestion=/ nextgroup=sdTCPCongest

" --- [Socket] value types ---
syn keyword sdBindIPv6   contained nextgroup=sdErr default both ipv6-only
syn keyword sdIPTOS      contained nextgroup=sdErr low-delay throughput reliability low-cost
syn keyword sdTCPCongest contained nextgroup=sdErr westwood veno cubic lp
" Source: src/core/socket.h — SocketTimestamping
syn keyword sdSocketTimestamping contained nextgroup=sdErr off us ns
" Source: src/core/socket.h — SocketDeferTrigger
syn keyword sdDeferTrigger contained nextgroup=sdErr patient

" --- [Timer] ---
syn region sdTimerBlock matchgroup=sdHeader start=/^\[Timer\]/ end=/^\[/me=e-2 contains=sdTimerKey
syn match sdTimerKey contained /^On\%(Active\|Boot\|Startup\|UnitActive\|UnitInactive\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdTimerKey contained /^\%(Accuracy\|RandomizedDelay\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdTimerKey contained /^\%(Persistent\|WakeSystem\|RemainAfterElapse\|OnClockChange\|OnTimezoneChange\)=/ nextgroup=sdBool,sdErr
" TODO: sdCalendar parsing is incomplete — the match is a rough approximation
syn match sdTimerKey contained /^OnCalendar=/ nextgroup=sdCalendar
syn match sdTimerKey contained /^Unit=/ nextgroup=sdUnitList

" --- [Automount] ---
syn region sdAutoMountBlock matchgroup=sdHeader start=/^\[Automount\]/ end=/^\[/me=e-2 contains=sdAutomountKey
syn match sdAutomountKey contained /^Where=/ nextgroup=sdFilename,sdErr
syn match sdAutomountKey contained /^DirectoryMode=/ nextgroup=sdOctal,sdErr

" --- [Mount] ---
syn region sdMountBlock matchgroup=sdHeader start=/^\[Mount\]/ end=/^\[/me=e-2 contains=sdMountKey,sdAutomountKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdMountKey contained /^\%(SloppyOptions\|LazyUnmount\|ForceUnmount\)=/ nextgroup=sdBool,sdErr
syn match sdMountKey contained /^\%(What\|Type\|Options\)=/

" --- [Swap] ---
syn region sdSwapBlock matchgroup=sdHeader start=/^\[Swap\]/ end=/^\[/me=e-2 contains=sdSwapKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdSwapKey contained /^What=/ nextgroup=sdFilename,sdErr
syn match sdSwapKey contained /^Priority=/ nextgroup=sdUInt,sdErr
syn match sdSwapKey contained /^Options=/

" --- [Path] ---
syn region sdPathBlock matchgroup=sdHeader start=/^\[Path\]/ end=/^\[/me=e-2 contains=sdPathKey
syn match sdPathKey contained /^\%(PathExists\|PathExistsGlob\|PathChanged\|PathModified\|DirectoryNotEmpty\)=/ nextgroup=sdFilename,sdErr
syn match sdPathKey contained /^MakeDirectory=/ nextgroup=sdBool,sdErr
syn match sdPathKey contained /^DirectoryMode=/ nextgroup=sdOctal,sdErr
syn match sdPathKey contained /^Unit=/ nextgroup=sdUnitList

" --- [Slice] ---
syn region sdSliceBlock matchgroup=sdHeader start=/^\[Slice\]/ end=/^\[/me=e-2 contains=sdSliceKey,sdResCtlKey,sdKillKey

" --- [Scope] ---
syn region sdScopeBlock matchgroup=sdHeader start=/^\[Scope\]/ end=/^\[/me=e-2 contains=sdScopeKey,sdResCtlKey,sdKillKey
syn match sdScopeKey contained /^TimeoutStopSec=/ nextgroup=sdDuration,sdErr

" === 9. Highlight definitions ===

" --- Base highlights ---
hi def link sdComment       Comment
hi def link sdTodo          Todo
hi def link sdInclude       PreProc
hi def link sdHeader        Type
hi def link sdEnvArg        PreProc
hi def link sdFormatStr     Special
hi def link sdErr           Error
hi def link sdEnvDef        Identifier
hi def link sdUnitName      PreProc
hi def link sdKey           Statement
hi def link sdValue         Constant
hi def link sdSymbol        Special

" --- Key links ---
" It'd be nice if this worked..
"hi def link sd.\+Key           sdKey
hi def link sdUnitKey           sdKey
hi def link sdInstallKey        sdKey
hi def link sdExecKey           sdKey
hi def link sdKillKey           sdKey
hi def link sdResCtlKey         sdKey
hi def link sdSocketKey         sdKey
hi def link sdServiceKey        sdKey
hi def link sdServiceCommonKey  sdKey
hi def link sdTimerKey          sdKey
hi def link sdMountKey          sdKey
hi def link sdAutomountKey      sdKey
hi def link sdSwapKey           sdKey
hi def link sdPathKey           sdKey
hi def link sdScopeKey          sdKey

" --- Value links ---
hi def link sdInt               sdValue
hi def link sdUInt              sdValue
hi def link sdBool              sdValue
hi def link sdOctal             sdValue
hi def link sdByteVal           sdValue
hi def link sdDuration          sdValue
hi def link sdPercent           sdValue
hi def link sdInfinity          sdValue
hi def link sdDatasize          sdValue
hi def link sdVirtType          sdValue
hi def link sdServiceType       sdValue
hi def link sdNotifyType        sdValue
hi def link sdSecurityType      sdValue
hi def link sdSecureBits        sdValue
hi def link sdMountFlags        sdValue
hi def link sdKillMode          sdValue
hi def link sdJobMode           sdValue
hi def link sdEmergencyAction   sdValue
hi def link sdRestartType       sdValue
hi def link sdSignalName        sdValue
hi def link sdExitStatusName    sdValue
hi def link sdStdin             sdValue
hi def link sdStdout            sdValue
hi def link sdSyslogFacil       sdValue
hi def link sdSyslogLevel       sdValue
hi def link sdIOSchedClass      sdValue
hi def link sdCPUSchedPol       sdValue
hi def link sdRlimit            sdValue
hi def link sdCapName           sdValue
hi def link sdDevPolicy         sdValue
hi def link sdDevAllowPerm      sdValue
hi def link sdIOSchedPrio       sdValue
hi def link sdCollectMode       sdValue
hi def link sdOOMPolicy         sdValue
hi def link sdExitType          sdValue
hi def link sdRestartMode       sdValue
hi def link sdTimeoutMode       sdValue
hi def link sdProtectSystem     sdValue
hi def link sdProtectHome       sdValue
hi def link sdProtectProc       sdValue
hi def link sdProcSubset        sdValue
hi def link sdKeyringMode       sdValue
hi def link sdPreserveMode      sdValue
hi def link sdProtectHostname   sdValue
hi def link sdProtectCG         sdValue
hi def link sdPrivateTmp        sdValue
hi def link sdPrivateUsers      sdValue
hi def link sdMemoryTHP         sdValue
hi def link sdNamespace         sdValue
hi def link sdManagedOOMMode    sdValue
hi def link sdManagedOOMPref    sdValue
hi def link sdPressureWatch     sdValue
hi def link sdControllerName    sdValue
hi def link sdCgroupVer         sdValue
hi def link sdCPUWeight         sdValue
hi def link sdSocketTimestamping sdValue
hi def link sdDeferTrigger      sdValue
hi def link sdArch              sdValue
hi def link sdUserGroup         sdValue
hi def link sdSystemCallGroup   sdValue
hi def link sdSystemCallName    sdValue

" --- Symbol/flag links ---
hi def link sdExecFlag          sdSymbol
hi def link sdConditionFlag     sdSymbol
hi def link sdEnvDashFlag       sdSymbol
hi def link sdInvertFlag        sdSymbol
hi def link sdCapOps            sdSymbol

hi def link sdDevAllowErr       Error
hi def link sdCapFlags          Identifier

" === Footer ===
let b:current_syntax = "systemd"
" vim: fdm=marker
