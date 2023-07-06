from .block import Block
from .util.stamp import stamp

class BlockChain:
    def __init__(self, **kwargs):
        self.blocks: list[Block] = kwargs.get(
            "chain",
            [
                Block(
                    timestamp=stamp(),
                    transactions=[],
                    nonce=1,
                    previous="0",
                    index=0,
                )
            ],
        )

    def chain_at(self, index: int = 0):
        return self.blocks[index]

    def drive(self, b: Block):
        self.blocks.append(b)
        return self.blocks[-1]

    @property
    def len(self) -> int:
        return len(self.blocks)

    def valid(self, chain: list[Block] = None) -> bool:
        _chain = chain if chain else self.blocks
        previous_block: Block = _chain[0]
        checker_index = 1

        len = self.len
        while checker_index < (len - 1):
            checker_block: Block = _chain[checker_index]
            if checker_block.previous != previous_block.hash:
                return False
            c = checker_block.verify_of_work(previous_block.nonce)
            if not c:
                return False
            else:
                previous_block = checker_block
                checker_index += 1
        return True

    @property
    def __dict__(self):
        return [b.__dict__ for b in self.blocks]

    def sync(self, datas: list[dict]):
        targets = []
        chain_detail = {}
        longest_len = self.len
        longest_chain = None

        for d in datas:
            length = len(d)
            if d in targets:
                index = targets.index(d)
                chain_detail[index]["hit"] = chain_detail[index]["hit"] + 1

            else:
                targets.append(d)
                index = len(targets) - 1
                chain_detail = {**chain_detail, index: {"hit": 1, "len": length}}

                if length > longest_len:
                    longest_len = length
                    longest_chain = d
                elif length == longest_len:
                    longest_chain = None

            if longest_chain and longest_chain != self.__dict__:
                re = [Block(**b) for b in longest_chain]
                if self.valid(chain=re):
                    self.blocks = re
            else:
                highest_hit = None
                for i in chain_detail.keys():
                    if not highest_hit:
                        highest_hit = i
                    elif chain_detail[i]["hit"] > chain_detail[highest_hit]["hit"]:
                        highest_hit = i
                if highest_hit and targets[highest_hit] != self.__dict__:
                    re = [Block(**b) for b in targets[highest_hit]]
                    if self.valid(chain=re):
                        self.blocks = re