#! /usr/bin/env python


import requests

def send_to_telegram(document):

    apiToken = '{token}'
    chatID = '{chat_id}'
    apiURL = f'https://api.telegram.org/bot{apiToken}/sendDocument'

    try:
        response = requests.post(apiURL, json={'{chat_id}': chatID, 'document': zip})
        print(response.text)
    except Exception as e:
        print(e)

send_to_telegram /tmp/cirrus-ci-build/upload/$ZIPNAME
