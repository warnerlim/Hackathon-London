import discord
import aivm_client as aic
import os
import torch
from openai import OpenAI
from aivm_bot.env import TOKEN
from apikeys import apikey

# Create an instance of the bot
intents = discord.Intents.default()
intents.message_content = True  # Ensure that the bot can read message content
client = discord.Client(intents=intents)

# Set your OpenAI API key
client = OpenAI(api_key = apikey)

def gpt_text(user_message, sentiment_score, model="gpt-4o"): # Prompt for texting purposes
    """
    Panders to user based on the message and sentimental analysis of user.
    """
    response = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": 
                f"""
                User's Message: "{user_message}"

                Sentiment Score: {sentiment_score}
                
                Respond to the user message based on the sentiment score as follows:
                - If the score is less than 0.6, reply empathetically, offering support or understanding.
                - If the score is around 0.6 (neutral), reply helpfully and neutrally.
                - If the score is above 0.6 and up to 0.9, add a lighthearted or mildly positive tone.
                - If the score is above 0.9, add a bit of playful sarcasm.

                Provide the response here:
                """,
            }
        ],
        model=model,
        max_tokens=4096,
        temperature=0,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )
    return response.choices[0].message.content


MODEL_NAME = "bert-tiny-sentiment-analysis"
@client.event
async def on_ready():
    print(f'Bot is ready! Logged in as {client.user}')
    path = os.path.join(os.path.dirname(__file__), "twitter_bert_tiny.onnx")
    try:
        aic.upload_bert_tiny_model(path, MODEL_NAME)
    except:
        print("Model already exists")

@client.event
async def on_message(message):
    # Avoid the bot reacting to its own messages
    if message.author == client.user:
        return
    
    tokens = aic.tokenize(message.content)
    inputs = aic.BertTinyCryptensor(*tokens)
    result = aic.get_prediction(inputs, MODEL_NAME)
    sentiment = torch.argmax(result).item()
    gpt_text(message, sentiment)
    
def main():
    # Run the bot with your token
    client.run(TOKEN)

if __name__ == "__main__":
    main()