#!/usr/bin/env python
import threading
import thread
import socket#, ssl
import random, string
import RPi.GPIO as GPIO
import time
import datetime
import os
import sys
GPIO.setmode(GPIO.BCM)

DoorOpen = 1
DoorUnknown = 0
DoorClosed = -1

validKeys = {}

PORT =10001
remoteControl = 17 # gpio pin on relay
GPIO.setup(remoteControl,GPIO.OUT)
openSinalPin=22
GPIO.setup(openSinalPin,GPIO.IN,pull_up_down=GPIO.PUD_UP)
closeSinalPin=27
GPIO.setup(closeSinalPin,GPIO.IN,pull_up_down=GPIO.PUD_UP)


on = False
off = True

GPIO.output(remoteControl, off)

def logE(e, filename):
    f = open(filename, 'a')
    f.write(("-"*50)+"\n")
    now =datetime.datetime.now()
    f.write(str(now)+"\n")
    f.write(str(e)+"\n")
    f.write(("-"*50)+"\n")
    f.close()
#    sys.exit(str(e))
    os.system("reboot")



def readSingalFromPin(pin):
    if GPIO.input(pin):
        return on
    else:
        return off


def isOpen(pin=openSinalPin):
    return readSingalFromPin(pin)

def isClose(pin=closeSinalPin):
    return readSingalFromPin(pin)



def randomword(length):
   return ''.join(random.choice(string.lowercase+ string.uppercase+string.digits) for i in range(length))



def updateKeys():
    now = datetime.datetime.now()
    print str(now)
    for key in validKeys.keys():
        val = validKeys[key]
        if(now > val):
            validKeys.pop(key, None)

def validkey(key):
    updateKeys()
    now = datetime.datetime.now()
    print str(validKeys)
    if key in validKeys.keys():
        validKeys.pop(key, None)
        return True
    return False

def sendSignalToDoor(key):
    print "OPEN: " + key
    updateKeys()
    result= validkey(key)
    if result:
        print "VALIDA"
        try:
            GPIO.output(remoteControl, on)
            time.sleep(.75)
            GPIO.output(remoteControl, off)

        except Exception as e:
            print str(e)
            return 1
    else:
        print "IVALIDA"
        return 1 

    return 0

def genKey(length=35,validTIME=30):
    print "CODE"
    res = randomword(length)
    now = datetime.datetime.now()
    validade = now + datetime.timedelta(seconds=validTIME)
    validKeys[res] =validade
    return res

def checkstatus():
    print "CHECK"
    open = isOpen()
    close = isClose()
    if open == close:
    	return DoorUnknown
    elif open:
	return DoorOpen
    else:
	return DoorClosed

def isToend(data):
    return ("FIM" in data)

def handleData(data):
    print "RECIVED: " + data
    response="0"
    if "STATUS?" in data:
        response = checkstatus()
    elif "CLICK?" in data:
        response =sendSignalToDoor(data.split('?')[1])
    elif "CODE?" in data:
        response = genKey()

    return response,isToend(data)

class cliente_Thread (threading.Thread):
    def __init__(self, conn):
      threading.Thread.__init__(self)
      self.conn=conn

    def run(self):
        data = self.conn.recv(1024).decode()
        while data:
            response,end = handleData(data.strip())
            if end:
                print "END"
                break
            else:
                print "CONTINUE"
                print "response: " + str(response)
                self.conn.sendall(str(response))
                print "sent"
                data = self.conn.recv(1024).decode()
        time.sleep(2)
        self.conn.close()
        print "THREAD DONE"



class ping_Thread (threading.Thread):
    def __init__(self,time):
	self.time =time
      	threading.Thread.__init__(self)

    def check_ping(self,hostname):
        response = os.system("ping -c 1 " + hostname)
        return response==0

    def checkConnect(self):
        hostnames = ["192.168.1.1","8.8.8.8"]
        for hostname in hostnames:
            if self.check_ping(hostname) == False:
                return (False,hostname)
        return (True,"")

    def run(self):
	print "Ping Tread Will start in "+str(self.time*20)+" seconds"
	time.sleep(self.time*20)
	print "Ping Thread Started"
	while True:
		try: 
			result,host = self.checkConnect()
			print result
            	except Exception as e:
                	logE(e,"/home/pi/garageLog.log")

            	if result==False:
                	logE("PING FAIL TO " + host,"/home/pi/garageLog.log")
        	time.sleep(self.time)


class Server:
    def __init__(self, port):
        self.port=port

        self.bindsocket = socket.socket()
        self.bindsocket.bind(('', self.port))
        self.bindsocket.listen(5)
        print "Server created on port: " + str(self.port)


    def runServer(self):
        print "Server Running on port: " + str(self.port)
        while True:
            print "WHAIT CONNECTION"
            newsocket, fromaddr = self.bindsocket.accept()
            cTread = cliente_Thread(newsocket)
            cTread.start()






try:
    	pThread = ping_Thread(2)
    	pThread.start()
	s = Server(PORT)
	s.runServer()
except Exception as e:
	logE(e,"/home/pi/garageLog.log")
