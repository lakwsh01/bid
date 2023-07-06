import requests

netlog = "http://127.0.0.1"
from datetime import datetime

import random
from uuid import uuid4
import json


datas = []

for r in range(100):
    sender = uuid4().hex
    tsm = int(datetime.now().timestamp() * 1000)
    utxos_count: int = random.randint(1, 100)
    utxos = []
    for r in range(utxos_count):
        amo = random.randint(1, 10) + (random.randint(1, 100) / 100)
        utxos.append({"sender": sender, "receiver": uuid4().hex, "amount": amo})
    datas.append({"timestamp": tsm, "utxos": utxos, "public_key": "0x000000"})

with open("tx.json", "w") as f:
    f.write(json.dumps(datas, ))
