print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
wifi.sta.config("NOME_REDE_WIFI","senha_wifi")
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function() 
    if wifi.sta.getip()== nil then 
        print("IP unavaiable, Waiting...") 
    else 
        tmr.stop(1)
    print("Config done, IP is "..wifi.sta.getip())
    dofile("dht11.lua")
    end 
end)
