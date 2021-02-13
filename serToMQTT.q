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
            class:`temperature`humidity``pressure;
            unit:("ºC";"%";"/1023";"hPa");
            icon:("";"";"white-balance-sunny";""))

clientID:`$ssr[;"-";""] string first 1?0Ng

.mqtt.disconn:{0N!(`disconn;x);conn::0b}

connect:{.mqtt.conn[`$broker_address,":",string port;clientID;()!()];conn::1b}
connect[]

ser:hopen`$":fifo://",COM

configure:{[s]
  msg:(!). flip (
   (`name;room,@[;0;upper] string s`name);
   (`state_topic;"homeassistant/sensor/",room,"/state");
   (`unit_of_measurement;s`unit);
   (`value_template;"{{ value_json.",string[s`name],"}}"));
   if[not null s`class;msg[`device_class]:s`class];
   if[not ""~s`icon;msg[`icon]:"mdi:",s`icon];
   topic:`$"homeassistant/sensor/",room,msg[`name],"/config";
   .mqtt.pubx[topic;;1;1b] .j.j msg;
 }

configure each sensors;

pub:{[]
 rawdata:last read0 ser;
 if[any rawdata~/:("";());:(::)];
 @[{
    qCRC:crc16 #[;x] last where x=",";
    data:"," vs x;
    arduinoCRC:"J"$last data;
    if[not qCRC=arduinoCRC;'"Failed checksum check"];
    .mqtt.pub[`$"homeassistant/sensor/",room,"/state"] .j.j sensors[`name]!"F"$4#data;
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

