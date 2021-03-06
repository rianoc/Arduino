\l mqtt.q
.mqtt.msgsent:{}

rs:{0b sv y xprev 0b vs x}
ls:{0b sv neg[y] xprev 0b vs x}
xor:{0b sv (<>/)vs[0b] each(x;y)}
land:{0b sv (.q.and). vs[0b] each(x;y)}

crc16:{
 crc:0;
 {x:xor[x;y];
  {[x;y] $[(land[x;1])>0;xor[rs[x;1];40961];rs[x;1]]} over x,til 8
 } over crc,`long$x
 };

port:1883
broker_address:.z.x[0]
COM:.z.x[1]
room:.z.x[2]

sensors:([] name:`temperature`humidity`light`pressure;
            lastPub:4#0Np;
            lastVal:4#0Nf;
            opts:(``device_class`unit_of_measurement!(::;`temperature;"ºC");
                  ``device_class`unit_of_measurement!(::;`humidity;"%");
                  ``unit_of_measurement`icon!(::;"/100";"white-balance-sunny");
                  ``device_class`unit_of_measurement!(::;`pressure;"hPa"))
 )

clientID:`$ssr[;"-";""] string first 1?0Ng

.mqtt.disconn:{0N!(`disconn;x);conn::0b}

createTemplate:{
  "{% if value_json.",x," %}{{ value_json.",x," }}{% else %}{{ states('sensor.",room,x,"') }}{% endif %}"
 }

configure:{[s]
  msg:(!). flip (
   (`name;room,string s`name);
   (`state_topic;"homeassistant/sensor/",room,"/state");
   (`value_template;createTemplate string[s`name]));
   msg,:`_ s`opts;
   topic:`$"homeassistant/sensor/",msg[`name],"/config";
   .mqtt.pubx[topic;;1;1b] .j.j msg;
 }

connect:{
 .mqtt.conn[`$broker_address,":",string port;clientID;()!()];
 conn::1b;
 configure each sensors;
 }

connect[]

ser:hopen`$":fifo://",COM

filterPub:{[newVals]
 newVals:@[newVals;2;{`float$floor x%10.23}];
 now:.z.p;
 toPub:exec (lastPub<.z.p-0D00:10) or (not lastVal=newVals) from sensors;
 if[count where toPub;
    update lastPub:now,lastVal:newVals[where toPub] from `sensors where toPub;
    msg:.j.j exec name!lastVal from sensors where toPub;
    .mqtt.pub[`$"homeassistant/sensor/",room,"/state";msg];
  ];
 }

pub:{[]
 rawdata:last read0 ser;
 if[any rawdata~/:("";());:(::)];
 @[{
    qCRC:crc16 #[;x] last where x=",";
    data:"," vs x;
    arduinoCRC:"J"$last data;
    if[not qCRC=arduinoCRC;'"Failed checksum check"];
    filterPub "F"$4#data;
   };
   rawdata;
   {-1 "Error with data: \"",x,"\" '",y}[rawdata]
  ];
 }

.z.ts:{
 if[not conn;connect[]];
 pub[]
 }

\t 1000

