\l mqtt.q
.mqtt.msgsent:{}

rs:{0b sv y xprev 0b vs x}
ls:{0b sv neg[y] xprev 0b vs x}
xor:{0b sv (<>/)vs[0b] each(x;y)}
land:{0b sv (.q.and). vs[0b] each(x;y)}

crc16:{
 crc:0;
 {
  x:xor[x;y];
  {[x;y]
   $[(land[x;1])>0;
     xor[rs[x;1];40961];
	 rs[x;1]
	]
  } over x,til 8 
 } over crc,`long$x
 };

port:1883
broker_address:.z.x[0]
COM:.z.x[1]
room:.z.x[2]

.mqtt.conn[`$broker_address,":",string port;`src;()!()]

ser:hopen`$":fifo://",COM

pub:{[]
 rawdata:last read0 ser;
 @[{
    qCRC:crc16 #[;x] last where x=",";
    data:"," vs x;
    arduinoCRC:"J"$last data;
    if[not qCRC=arduinoCRC;'"Failed checksum check"];
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

