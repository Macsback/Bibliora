from flask import Flask, render_template, jsonify
import RPi.GPIO as GPIO
import time
import os

GPIO.setmode(GPIO.BOARD)
LED_pin = 12
Buzzer_pin = 11
GPIO.setup(LED_pin, GPIO.OUT)
GPIO.setup(Buzzer_pin, GPIO.OUT)

app = Flask(__name__)

alive=0
data = {}

	

@app.route("/")
def index():
	return render_template("index.html")


@app.route("/Scanned", methods=['POST'])
def mark_Scanned():
	print("Scan Succesful")
	GPIO.output(LED_pin, True)
	time.sleep(0.5)
	GPIO.output(LED_pin, False)
	beep(6)
		
	return jsonify(message="Success")
	

def beep(repeat):
	for i in range(0, repeat):
		for pulse in range(60):
			GPIO.output(Buzzer_pin, True)
			time.sleep(0.001)
			GPIO.output(Buzzer_pin, False)

if __name__ == '__main__':
	app.run (host="172.20.10.2", port="5000")
	
