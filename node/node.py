# from .chain import BlockChian
# import flask
from .util.kwarg_check import kwarg_check
from .util.stamp import stamp
from .mempool import Mempool
from .chain import BlockChain
from .block import Block


class Miner:
    def __init__(self, **kwargs):
        self.peers: list[Node] = []
        self.node: Node = Node(**kwargs)
        self.mempool: Mempool = Mempool()
        self.chain: BlockChain = BlockChain()

    def set_node_address(self, address: str):
        self.node.address = address

    def add_peer(self, **kwargs):
        node = Node(**kwargs)
        self.peers.append(node)

    def remove_peer(self, id: str):
        node = [r for r in self.peers if r.id == id]
        if node:
            self.peers.remove(id)

    def mine_block(self):
        prev = self.chain.blocks[-1]
        next_nounce = Block.proof_of_work(prev.nonce)
        transactions = [tx.__dict__ for tx in self.mempool.pick_from_pool()]
        next_block = Block(
            transactions=transactions,
            previous=prev.hash,
            timestamp=stamp(),
            index=prev.index + 1,
            nonce=next_nounce,
        )
        self.chain.drive(next_block)
        return next_block


_CHECKER_NODE = {"address": str, "id": str, "name": str}


class Node:
    def __init__(self, **kwargs):
        """id, name, address must not null"""
        kwargs = kwarg_check(checker=_CHECKER_NODE, **kwargs)

        self.address = kwargs.get("address")
        self.id = kwargs.get("id")
        self.name = kwargs.get("name", "")
        self.area = kwargs.get("area", "aisa_hk")
        self.type = kwargs.get("type", "miner")
        self.status = kwargs.get("status", "active")

    @property
    def __dict__(self):
        return {
            "address": self.address,
            "id": self.id,
            "area": self.area,
            "name": self.name,
            "type": self.type,
            "status": self.status,
        }
