#! /usr/bin/env python


import requests
import os

tmp = list(os.scandir('.'))
for i in tmp:
  if 'zip' in i.name:
      file ={"document": open(f'{i.name}', 'rb')}
      res = requests.post("https://api.telegram.org/bot{token}/sendDocument?chat_id='{chat_id}'", files=file)
      print(res.content)
