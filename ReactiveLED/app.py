from pubnub import Pubnub
import RPi.GPIO as GPIO
import time

# PubNub Configuration (your keys)
pubnub = Pubnub(publish_key="your_publish_key", subscribe_key="your_subscribe_key")

# GPIO Setup
GPIO.setmode(GPIO.BOARD)
LED_pin = 12
Buzzer_pin = 11
GPIO.setup(LED_pin, GPIO.OUT)
GPIO.setup(Buzzer_pin, GPIO.OUT)


# Function to publish messages to PubNub channel
def publish_message(channel, message):
    pubnub.publish(channel=channel, message=message)


# Function to simulate a scan (turn LED on/off and beep)
def mark_scanned():
    print("Scan Successful")
    GPIO.output(LED_pin, True)
    time.sleep(0.5)
    GPIO.output(LED_pin, False)
    beep(6)

    # Send message to PubNub (notify Flask server)
    publish_message("scan_channel", {"status": "success", "message": "Scan Successful"})


def beep(repeat):
    for i in range(0, repeat):
        for pulse in range(60):
            GPIO.output(Buzzer_pin, True)
            time.sleep(0.001)
            GPIO.output(Buzzer_pin, False)


# Function to subscribe to the PubNub channel and trigger scan
def subscribe_to_channel():
    def message_callback(message, channel):
        print(f"Received message: {message}")
        if message.get("action") == "trigger_scan":
            mark_scanned()

    # Subscribe to channel and listen for the 'trigger_scan' action
    pubnub.subscribe(channels=["scan_channel"], message=message_callback)


# Start listening for messages
subscribe_to_channel()

# Run indefinitely to listen for PubNub messages
while True:
    pass
