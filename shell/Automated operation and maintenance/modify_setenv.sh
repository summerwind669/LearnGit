#!/bin/bash

# 备份并修改setenv.sh文件
for ((i=1; i<=4; i++))
do
    cp ~/ivrInterface/tomcat${i}/bin/setenv.sh ~/ivrInterface/tomcat${i}/bin/setenv.sh.bak
    sed -i 's/system.id=ivrInterface/system.id=ivrInterface.ybyw/' ~/ivrInterface/tomcat${i}/bin/setenv.sh
done


# 检查修改后的setenv.sh文件内容
for ((i=1; i<=4; i++))
do
    echo "===== Checking setenv.sh for tomcat${i} ====="
    cat ~/ivrInterface/tomcat${i}/bin/setenv.sh
    echo "===== End of setenv.sh for tomcat${i} ====="
done
