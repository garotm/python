# This code creates a simple bot that will respond to messages it receives by echoing the message back to the user. You can modify the handle_message function to add additional functionality to your bot.
#
# To use this code, you will need to install the following dependencies:
#
# pip install flask
# pip install botbuilder
#
# You will also need to set the BOT_APP_ID and BOT_APP_PASSWORD environment variables to the values provided by the Microsoft Bot Framework when you register your bot.

import os
import sys

from flask import Flask, request

from botbuilder.core import (
    BotFrameworkAdapterSettings,
    TurnContext,
    BotFrameworkAdapter,
)
from botbuilder.schema import Activity

app = Flask(__name__)

# Read the BOT_APP_ID and BOT_APP_PASSWORD environment variables
# These values are used to authenticate your bot when connecting to the Bot Framework service
APP_ID = os.environ.get("BOT_APP_ID", "")
APP_PASSWORD = os.environ.get("BOT_APP_PASSWORD", "")

# Create the BotFrameworkAdapterSettings object, which is used to configure the adapter
# when it is created
BOT_SETTINGS = BotFrameworkAdapterSettings(APP_ID, APP_PASSWORD)

# Create the BotFrameworkAdapter object, which is used to process incoming messages and 
# send responses
bot_adapter = BotFrameworkAdapter(BOT_SETTINGS)

# Define a function that will be called when the bot receives a message
@bot_adapter.on_turn(TurnContext)
async def handle_message(context: TurnContext):
    # Print the message to the console
    print(f"Received message: {context.activity.text}")

    # Create a response message
    response = Activity(type="message", text=f"You said: {context.activity.text}")

    # Send the response message
    await context.send_activity(response)

# Define a route that will be used to receive incoming messages from the Bot Framework service
@app.route("/api/messages", methods=["POST"])
def messages():
    # Deserialize the incoming request body
    body = request.json()

    # Create a TurnContext object, which is used to process the request
    turn_context = TurnContext(bot_adapter, body)

    # Call the handle_message function
    bot_adapter.run_on_turn(turn_context, handle_message)

    return ""

if __name__ == "__main__":
    app.run(debug=True)

