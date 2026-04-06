#!/system/bin/sh

echo "热重启中..."
PID_MAX=$(cat /proc/sys/kernel/pid_max)
last_pid=$(sh -c 'echo $PPID')

wrapped=0
while true; do
    : &
    current_pid=$!
    if [ "$current_pid" -lt "$last_pid" ]; then
        wrapped=1
    fi

    if [ "$wrapped" -eq 1 ] && [ "$current_pid" -ge 1700 ]; then
        break
    fi
    last_pid=$current_pid
done

echo "Done. Restarting zygote..."
setprop ctl.restart zygote
