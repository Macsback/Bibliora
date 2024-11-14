from flask import Flask, render_template, jsonify
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
LED_pin = 18
GPIO.setup(LED_pin, GPIO.OUT)

app = Flask(__name__)

alive=0
data = {}

	

@app.route("/")
def index():
	return render_template("index.html")


@app.route("/Scanned", methods=['POST'])
def mark_Scanned():
	print("Scan Succesful")
	GPIO.output(LED_pin, GPIO.HIGH)
	time.sleep(0.5)
	GPIO.output(LED_pin, GPIO.LOW)
	return jsonify(message="Success")
	
	
if __name__ == '__main__':
	app.run (host="172.20.10.2", port="5000")
	
