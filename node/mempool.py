from .transaction import Transaction
from random import randint
from .util.kwarg_check import kwarg_check


class Mempool:
    def __init__(self):
        self.pool: list[Transaction] = []

    def pick_from_pool(self) -> list[Transaction]:
        txs: set = set()
        if len(self.pool) <= 10:
            txs = self.pool
            return list(txs)
        else:
            while len(txs) <= 10:
                index = randint(0, len(self.pool) - 1)
                txs.add(self.pool[index])
            return list(txs)

    def add_to_pool(self, tx: Transaction):
        self.pool.append(tx)
        return self.pool[-1]

    def remove_from_pool(self, targets: list[str]):
        for target in targets:
            for tx in self.pool:
                if tx.id == target:
                    self.pool.remove(tx)

    def drive(self, tx: Transaction | dict):
        if tx is dict:
            self.pool.append(Transaction(**tx))
        else:
            self.pool.append(tx)
        return self.pool[-1]

    def unmount(self, tx: str):
        _tx = [t for t in self.pool if t.id == tx]
        if _tx:
            for __tx in _tx:
                self.pool.remove(__tx)

    def sync(self, data: list[dict]):
        commands = {}
        for r in data:
            r = list(r)
            for rtx in r:
                _CHECKER = {"tx": dict, "command": str}
                kw = kwarg_check(_CHECKER, **rtx)
                _c: str = kw.get("command")
                tx: dict = kw.get("tx")
                id: str = tx.get("id")
                if id in commands:
                    commands[id] = {**commands[id], _c: commands[id][_c] + 1}
                else:
                    commands[id] = {"UMOUNT": 0, "DRIVE": 0, "tx": tx, **{_c: 1}}

        for k, v in commands.items():
            v = dict(v)
            if v.get("UMOUNT") > v.get("DRIVE"):
                self.unmount(tx=k)
            else:
                self.drive(tx=v.get("tx"))
