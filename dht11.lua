pin = 4
Humidity = 0
HumidityDec=0
Temperature = 0
TemperatureDec=0
Checksum = 0
ChecksumTest=0


function getTemp()
    Humidity = 0
    HumidityDec=0
    Temperature = 0
    TemperatureDec=0
    Checksum = 0
    ChecksumTest=0
    
	bitStream = {}
    for j = 1, 40, 1 do
        bitStream[j]=0
    end
    bitlength=0

    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin, gpio.LOW)
    tmr.delay(20000)
    gpio_read=gpio.read
    gpio_write=gpio.write

    gpio.mode(pin, gpio.INPUT)

    while (gpio_read(pin)==0 ) do end

    c=0
    while (gpio_read(pin)==1 and c<100) do c=c+1 end

    while (gpio_read(pin)==0 ) do end

    c=0
    while (gpio_read(pin)==1 and c<100) do c=c+1 end

    for j = 1, 40, 1 do
        while (gpio_read(pin)==1 and bitlength<10 ) do
            bitlength=bitlength+1
        end
        bitStream[j]=bitlength
        bitlength=0
        while (gpio_read(pin)==0) do end
    end

    for i = 1, 8, 1 do
        if (bitStream[i+0] > 2) then
            Humidity = Humidity+2^(8-i)
        end
    end
    for i = 1, 8, 1 do
        if (bitStream[i+8] > 2) then
            HumidityDec = HumidityDec+2^(8-i)
        end
    end
    for i = 1, 8, 1 do
        if (bitStream[i+16] > 2) then
            Temperature = Temperature+2^(8-i)
        end
    end
    for i = 1, 8, 1 do
        if (bitStream[i+24] > 2) then
            TemperatureDec = TemperatureDec+2^(8-i)
        end
    end
    for i = 1, 8, 1 do
        if (bitStream[i+32] > 2) then
            Checksum = Checksum+2^(8-i)
        end
    end
    ChecksumTest=(Humidity+HumidityDec+Temperature+TemperatureDec) % 0xFF

    print ("Temperature: "..Temperature.."."..TemperatureDec)
    print ("Humidity: "..Humidity.."."..HumidityDec)
    print ("ChecksumReceived: "..Checksum)
    print ("ChecksumTest: "..ChecksumTest)
end

function sendData()
    getTemp()
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end)

    conn:connect(80,'191.236.80.12') 
    conn:send("POST /tables/humidity " .. "HTTP/1.1\r\n") 
    conn:send("Accept: application/json\r\n") 
    conn:send("X-ZUMO-APPLICATION: AQUIVAIASUACHAVE\r\n") 
    conn:send("Host: plantuniville.azure-mobile.net\r\n")
    conn:send("Content-Length: 18\r\n")
    conn:send("\r\n")
    conn:send("{ \"value\":\"" .. Humidity.."."..HumidityDec.."\" }")
    conn:on("sent",function(conn)
        print("Closing connection")
        conn:close()
    end)
    conn:on("disconnection", function(conn)
        print("Got disconnection...")
    end)
end

tmr.alarm(2, 60000, 1, function() sendData() end )
