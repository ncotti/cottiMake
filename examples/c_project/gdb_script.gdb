set debuginfod enabled off
set logging file build/debug_log.txt
set logging overwrite on

break src/main.c:12
    commands
    printf "Value retrieved from gdb: %d\n", a
end

set logging enabled on
run
set logging enabled off
quit
