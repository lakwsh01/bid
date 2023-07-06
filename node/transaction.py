from uuid import uuid4

_CHECKER_TRANSACTION = {"timestamp": (float, int), "utxos": list, "public_key": str}


class Transaction:
    def __init__(self, **kwargs):
        for k, t in _CHECKER_TRANSACTION.items():
            assert isinstance(kwargs[k], t), Exception(
                400,
                "block_invaild",
                f"Key {k}, must not be null and should be {t}, but kwargs[k]({type(kwargs[k])}) was given",
            )
        self.timestamp: float = kwargs.get("timestamp")
        self.utxos: list[UTXO] = [UTXO(**i) for i in kwargs.get("utxos")]
        self.id: str = uuid4().hex
        self.public_key: str = kwargs.get("public_key")

    @property
    def __dict__(self):
        return {
            "timestamp": self.timestamp,
            "utxos": [i.__dict__ for i in self.utxos],
            "id": self.id,
            "public_key": self.public_key,
        }


_CHECKER_UTXO = {"sender": str, "receiver": str, "amount": float}


class UTXO:
    def __init__(self, **kwargs):
        for k, t in _CHECKER_UTXO.items():
            assert isinstance(kwargs[k], t), Exception(
                400,
                "block_invaild",
                f"Key {k}, must not be null and should be {t}, but kwargs[k]({type(kwargs[k])}) was given",
            )

        self.sender = kwargs.get("sender")
        self.receiver = kwargs.get("receiver")
        self.amount = kwargs.get("amount")

    @property
    def __dict__(self):
        return {"sender": self.sender, "receiver": self.receiver, "amount": self.amount}
