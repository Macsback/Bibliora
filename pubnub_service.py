from pubnub.pubnub import PubNub
from pubnub.pnconfiguration import PNConfiguration
import uuid
import os


# Initialize PubNub configuration and keys
def init_pubnub():
    pnconfig = PNConfiguration()
    pnconfig.subscribe_key = os.getenv("PUBNUB_SUBSCRIBE_KEY")
    pnconfig.publish_key = os.getenv("PUBNUB_PUBLISH_KEY")
    generated_uuid = str(uuid.uuid4())
    pnconfig.uuid = generated_uuid

    pubnub = PubNub(pnconfig)
    return pubnub


# Function to publish messages to a PubNub channel
def publish_message(pubnub, channel, message):
    try:
        pubnub.publish().channel(channel).message(message).sync()
    except Exception as e:
        print(f"Error publishing message to PubNub: {str(e)}")
