# Домашнее задание 8
[psax.sh](psax.sh)
## Процессы
* написать свою реализацию ps ax используя анализ /proc
* Результат ДЗ - рабочий скрипт который можно запустить
## Процесс решения
Получаю количество "тиков" в секунду, и список процессов
```bash
hz=$(getconf CLK_TCK)
proc=$(ls /proc/ | grep [0-9] | sort -g)
```
в цикле перебираю все пути с id процессов внутри /proc
при наличии текста в cmdline беру его для будущего вывода, при отстутствии использую имя из второй колонки stat
```bash
for process in $proc
do
path="/proc/$process"
if [[ $(cat $path/cmdline 2>/dev/null | wc -c) -eq 0 ]]
        then
        cmd=$(cat $path/stat 2>/dev/null | awk '{print $2}')
        else
        cmd=$(cat $path/cmdline 2>/dev/null)
fi
```
если существует какой либо вывод в консоль сохраняю его для вывода, при отстутствии использую "?"
```bash
if [[ $(ls -l $path/fd 2>/dev/null | grep -E 'tty|pts' | wc -c) -eq 0 ]]
        then
        tty='?'
        else
        tty=$(ls -l $path/fd 2>/dev/null | grep -E 'tty|pts' | head -1 | cut -d\/ -f3,4)
fi
```
состояние процесса из 3 колонки stat и количество тиков процесса и его чайлдов для user, kernel
```bash
state=$(cat $path/stat 2>/dev/null | awk '{print $3}')
ut=$(cat $path/stat 2>/dev/null | awk '{print $14}')
st=$(cat $path/stat 2>/dev/null | awk '{print $15}')
cut=$(cat $path/stat 2>/dev/null | awk '{print $16}')
cst=$(cat $path/stat 2>/dev/null | awk '{print $17}')
```
суммирую тики и перевожу в читаемый вид
```bash
total=$((ut+st+cut+cst))
total_sec=$((total/hz))
proc_time=$(date -d@$total_sec -u +%H:%M:%S)
```
итоговый вывод
```bash
printf "%-5s  %-1s  %-10s  %-5s %s\n" $process $state $proc_time $tty $cmd
done
```

пример вывода скрипта
```bash
[root@centos7 linux-dz-8]# ./psax.sh
1      S  01:34:37    ?     /usr/lib/systemd/systemd--system--deserialize15
2      S  00:00:01    ?     (kthreadd)
4      S  00:00:00    ?     (kworker/0:0H)
6      S  00:00:01    ?     (ksoftirqd/0)
7      S  00:00:01    ?     (migration/0)
8      S  00:00:00    ?     (rcu_bh)
9      S  00:11:49    ?     (rcu_sched)
10     S  00:00:00    ?     (lru-add-drain)
11     S  00:00:14    ?     (watchdog/0)
12     S  00:00:14    ?     (watchdog/1)
```

