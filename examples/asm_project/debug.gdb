set architecture arm
target remote localhost:2159

set logging file build/debug_log.txt
set logging overwrite on

break src/main.c:7
    commands
    printf "Value retrieved from gdb: %d\n", a
end

set logging enabled on
c
set logging enabled off
quit
