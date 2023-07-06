import hashlib
from json import dumps
from .transaction import Transaction
from .util.kwarg_check import kwarg_check

_CHECKER = {
    "nonce": int,
    "previous": str,
    "transactions": list,
    "timestamp": (float, int),
    "index": int,
}


class Block:
    def __init__(self, **kwargs):
        kwargs = kwarg_check(checker=_CHECKER, **kwargs)
        self.transactions = [Transaction(**r) for r in kwargs["transactions"]]
        self.previous = kwargs["previous"]
        self.timestamp = kwargs["timestamp"]
        self.index = kwargs["index"]
        self.nonce = kwargs["nonce"]

    @staticmethod
    def proof_of_work(previous_nonce: int):
        new_nonce = 1
        check_proof = False
        while check_proof is False:
            hash_operation = hashlib.sha256(
                str((new_nonce**2 - previous_nonce**2)).encode()
            ).hexdigest()
            if hash_operation[:4] == "0000":
                check_proof = True
            else:
                new_nonce += 1
        return new_nonce

    def verify_of_work(self, previous_nonce: int) -> bool:
        hash_operation = hashlib.sha256(
            str((self.nonce**2 - previous_nonce**2)).encode()
        ).hexdigest()
        if hash_operation[:4] == "0000":
            return True
        else:
            return False

    @property
    def hash(self):
        encoded_block = dumps(self.__dict__, sort_keys=True).encode()
        return hashlib.sha256(encoded_block).hexdigest()

    @property
    def __dict__(self):
        return {
            "transaction": [i.__dict__ for i in self.transactions],
            "previous": self.previous,
            "timestamp": self.timestamp,
            "index": self.index,
            "nonce": self.nonce,
        }
