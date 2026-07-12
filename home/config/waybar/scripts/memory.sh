#!/bin/sh

awk '
/^MemTotal:/ { total=$2 }
/^MemFree:/  { free=$2 }
/^Buffers:/  { free+=$2 }
/^Cached:/   { free+=$2 }
END {
    used = (total-free)/1024/1024
    tot  = total/1024/1024
    pct  = 0
    if (tot > 0) pct = used/tot*100

    class = "normal"
    if (pct > 90)      class = "critical"
    else if (pct > 80) class = "high"
    else if (pct > 70) class = "warning"

    printf("{\"text\":\"%.1fG\",\"class\":\"%s\"}\n", used, tot, pct, class)
}
' /proc/meminfo
