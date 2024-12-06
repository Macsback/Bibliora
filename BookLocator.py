import RPi.GPIO as GPIO
import time
 
SENSOR_PIN = 23
LED_pin = 18
Buzzer_pin = 17
 
GPIO.setmode(GPIO.BCM)
GPIO.setup(SENSOR_PIN, GPIO.IN)
GPIO.setup(LED_pin, GPIO.OUT)
GPIO.setup(Buzzer_pin, GPIO.OUT)
 
def my_callback(channel):
    GPIO.output(LED_pin, True)
    time.sleep(0.5)
    GPIO.output(LED_pin, False)
    beep(6)
    
    print('There was a movement!')
    
def beep(repeat):
	for i in range(0, repeat):
		for pulse in range(60):
			GPIO.output(Buzzer_pin, True)
			time.sleep(0.001)
			GPIO.output(Buzzer_pin, False)
 
try:
    GPIO.add_event_detect(SENSOR_PIN , GPIO.RISING, callback=my_callback)
    while True:
        time.sleep(10)
        
        


        
except KeyboardInterrupt:
    print ("Finish...")
    
    
    
GPIO.cleanup()
