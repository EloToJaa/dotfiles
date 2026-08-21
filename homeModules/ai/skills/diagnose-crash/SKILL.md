---
name: diagnose-crash
description: >
  Diagnose why a program crashed on this machine, from a systemd-coredump core dump.
  Use when a process has segfaulted, aborted, or otherwise dumped core, or when
  asked why an application crashed. Triggers: crash, segfault, SIGSEGV, SIGABRT,
  core dump, coredumpctl, backtrace symbolization.
---

# Diagnosing a Crash

Work from evidence. The goal is an honest account of what happened, not a
plausible-sounding story.

## Establish the facts

Start with `coredumpctl info <pid>`. Note the command line, which often reveals
what the program was doing when it died. Use `coredumpctl list` to determine
whether this is a one-off or a recurring crash.

## Rule out resource exhaustion

Check `free -h` and the journal around the crash for OOM kills. An OOM kill is
not a bug in the killed process.

## Correlate the timeline

Compare the crash timestamp against filesystem mtimes, the journal, and recent
package updates. A crash beginning immediately after an update points at that
update.

## Read the whole core

Inspect all thread stacks, not only frame 0. Other threads can show in-flight
thumbnailers, image loaders, IPC readers, or GPU work. Flag third-party code in
the address space, but do not assign blame without evidence.

## Symbolize when possible

Use a private temporary file and always remove it when finished:

```bash
core=$(mktemp -t crash-XXXXXX.core)
trap 'rm -f "$core"' EXIT
coredumpctl dump <pid> --output="$core"
DEBUGINFOD_URLS="https://debuginfod.archlinux.org" \
  gdb -q <executable> "$core" \
  -batch -ex 'set debuginfod enabled on' -ex 'bt'
```

A core dump is a copy of process memory and may contain passwords, tokens, and
private documents. Never leave an extracted core in `/tmp`. Do not invent
function names when debug symbols are unavailable.

## Report

1. What crashed and what it was doing.
2. The likely mechanism, separating proven facts from inference.
3. Whether user data was lost and where it can be recovered.
4. Whether it is likely to recur and what would fix or avoid it.

Diagnosis reads system state; it does not fix, tidy, or reconfigure it. Be clear
when the evidence is ambiguous.
