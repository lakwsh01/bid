from flask import Flask
from flask import Flask, jsonify, request, Request
from node.node import Miner
from uuid import uuid4
from urllib.parse import urlparse

# from requests import request

app = Flask(__name__)
# app.config["JSONIFY_PRETTYPRINT_REGULAR"] = False

id = uuid4().hex[:6]
miner = Miner(
    id=id,
    name=f"miner_{id}",
    address="",
    peers=[],
)


@app.route("/mine", methods=["GET"])
def mine():
    b = miner.mine_block()
    return jsonify(b.__dict__), 200



@app.route("/tx", methods=["POST"])
def drive_tx():
    from node.transaction import Transaction

    tx = Transaction(**request.get_json())
    miner.mempool.drive(tx)
    return jsonify({"message": "success"}), 200


@app.route("/chain", methods=["GET"])
def chain():
    response = {
        "chain": [b.__dict__ for b in miner.chain.blocks],
        "length": miner.chain.len,
    }
    return jsonify(response), 200


# @app.route("/node_check", methods=["POST"])
# def node_check():
#     pass


@app.route("/node_profile", methods=["GET"])
def node_profile(request: Request):
    return jsonify({miner.node.__dict__}), 200


# A -> B,C,D
# B -> A,C,D
# A -> B,C,D
# B -> A,E,F
# C -> A,Z,G
# A get transaction from node B,C,D
#
@app.route("/mempool_sync", methods=["GET", "DELETE"])
def mempool_sync(request: Request):
    transaction = request.get_json()
    from node.transaction import Transaction

    tx = Transaction(**transaction)
    if tx:
        if request.method == "POST":
            miner.mempool.drive(tx)
        elif request.method == "DELETE":
            miner.mempool.unmount(tx)
    return jsonify({"message": "success"}), 200


@app.route("/vaildation", methods=["GET"])
def vaildation():
    is_valid = miner.chain.valid()
    if is_valid:
        response = {"message": "All good. The Blockchain is valid."}
    else:
        response = {
            "message": "Houston, we have a problem. The Blockchain is not valid."
        }
    return jsonify(response), 200


@app.route("/")
def index():
    miner.set_node_address(address=str(urlparse(request.base_url).hostname))
    from render import index

    return index()


app.run(host="0.0.0.0", port=5000)
