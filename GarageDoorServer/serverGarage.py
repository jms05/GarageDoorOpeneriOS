#!/usr/bin/env python
import threading
import thread
import socket#, ssl
import random, string
import RPi.GPIO as GPIO
import time
import datetime
import os
GPIO.setmode(GPIO.BCM)

DoorOpen = 1
DoorUnknown = 0
DoorClosed = -1

validKeys = {}

PORT =10001
remoteControl = 17 # gpio pin on relay
GPIO.setup(remoteControl,GPIO.OUT)

on = False
off = True

GPIO.output(remoteControl, off)

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
    return DoorUnknown
    return random.randint(-1, 1)

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
            cTread.run()


s = Server(PORT)
s.runServer()
