\l mqtt.q
.mqtt.msgsent:{}

crc16:{x}

port:1883
broker_address:.z.x[0]
COM:.z.x[1]
room:.z.x[2]

.mqtt.conn[`$broker_address,":",string port;`src;()!()]

ser:hopen`$":fifo://",COM

pub:{[]
 rawdata:last read0 ser;
 @[{
    pyCRC:crc16 #[;x] 1+last where x=",";
    data:"," vs x;
    arduinoCRC:"I"$last data;
    /if[not pyCRC=arduinoCRC;'"Failed checksum check"];
    .mqtt.pub[`$"hassio/",room,"/temperature";data[0]];
    .mqtt.pub[`$"hassio/",room,"/humidity";data[1]];
    .mqtt.pub[`$"hassio/",room,"/light";data[2]];
    .mqtt.pub[`$"hassio/",room,"/pressure";data[3]]
   };
   rawdata;
   {
    show "Error with data";
    show x;
    show y
   }[rawdata]];
 };

.z.ts:{pub[]}

\t 5000

