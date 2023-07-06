from flask import Flask
from server.block.block import TransactionBlock
from server.block.blockchain import BlockChian
from flask import Flask, jsonify
from node.node import Node
from node.mempool import Mempool
from uuid import uuid4

app = Flask(__name__)
# app.config["JSONIFY_PRETTYPRINT_REGULAR"] = False
miner = Node()


_C = BlockChian()


@app.route("/mine", methods=["GET"])
def mine():
    from uuid import uuid4

    b: TransactionBlock = _C.mine({"id": str(uuid4())})
    return jsonify(b.json), 200


@app.route("/chain", methods=["GET"])
def chain():
    response = {"chain": [b.json for b in _C.chain], "length": _C.len}
    return jsonify(response), 200


@app.route("/vaildation", methods=["GET"])
def vaildation():
    is_valid = _C.chain_valid
    if is_valid:
        response = {"message": "All good. The Blockchain is valid."}
    else:
        response = {
            "message": "Houston, we have a problem. The Blockchain is not valid."
        }
    return jsonify(response), 200


@app.route("/")
def index():
    from render import index

    return index()


app.run(host="0.0.0.0", port=5000)
