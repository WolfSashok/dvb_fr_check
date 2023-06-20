#!/bin/bash

AUTH="admin:admin"
ADDR="127.0.0.1:8080"
PWD=`/bin/pwd`

min=474
max=858
step=8

adapter=1103

> DVB_list

$PWD/astra-latest -p 8080 -c $PWD/astra.conf --daemon

sleep 5

for((i=$min;i<=$max;i=i+$step)) do

    /usr/bin/curl -X POST -d '{
        "cmd": "set-adapter", 	
        "id": "test", 
        "adapter": {
            "enable": true, 
            "type":"T2", 
            "name": "test", 
            "id": "test", 
            "adapter": 1103, 
            "device": 0, 
            "frequency": "'$i'"}}' http://$AUTH@$ADDR/control/
    sleep 5
    LOCK=`/usr/bin/curl -s http://$AUTH@$ADDR/api/adapter-status/test?t=0 | grep lock | tr ',' ' ' | awk '{print $2}'` # Проверяем стату адаптера
    
    [[ -f $PWD/FRs/$i ]] || /bin/echo $LOCK > $PWD/FRs/$i                # Провреяем наличие файла и создаём новый со статусом адаптера
    status=`/bin/cat $PWD/FRs/$i`                                   # Статус адаптера перед проверкой
    if [[ $LOCK != $status  ]]; then                             # Проверяем есть ли изменения с последней проверки
        echo $LOCK > $PWD/FRs/$i
    fi

    if [ "$LOCK" == "true" ]; then 
        echo FR=$i Status: $LOCK >> DVB_list
    fi
done

/usr/bin/pkill -f astra.*8080
