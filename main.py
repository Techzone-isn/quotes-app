from fastapi import FastAPI
import random
from typing import Optional

# Create an instance of the FastAPI application
app = FastAPI()

# Function to generate a random quote
def generate_quote():
    # List of quotes
    quotes = [
        "The only way to do great work is to love what you do. - Steve Jobs",
        "Innovation distinguishes between a leader and a follower. - Steve Jobs",
        "The only limit to our realization of tomorrow will be our doubts of today. - Franklin D. Roosevelt",
        "The best way to predict the future is to invent it. - Alan Kay"
    ]
    # Return a random quote from the list
    return random.choice(quotes)

# Define a route for the API that returns a random quote
@app.get("/quote/")
def get_quote():
    # Return the quote in a JSON format
    return {"quote": generate_quote()}
