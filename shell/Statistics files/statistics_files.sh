方法1：
size_sum=0
sum=0

for file in /tmp/*.mp3; do
  if [[ -f "$file" ]]; then
    size=$(du -sb "$file" | cut -f1)
    size_sum=$((size_sum + size))
    ((sum++))
  fi
done

echo "Total size (in bytes): $size_sum"
echo "Total number of files: $sum"


方法2：
size_sum=0
sum=0

while read -r size _; do
  size_sum=$((size_sum + size))
  ((sum++))
done < <(find /tmp -type f -name "*.mp3" -exec du -sb {} + 2>/dev/null)

echo  $size_sum
echo  $sum


如果你使用 while read 循环还是输出 0，可能是由于 find 命令和 while 循环的配合问题。为了确保在 while 循环中正确处理数据，你可以尝试如下方法，将命令的输出通过管道传递给 while 循环时，将其与子进程隔离的问题解决：

< <(command) 语法称为 process substitution（进程替代），它将 find 命令的输出作为 while read 循环的输入，而不使用管道，这样变量的作用域就不会被子进程限制。
du -sb 的输出会逐行被 while read 循环读取并处理。

