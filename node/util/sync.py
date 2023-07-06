import asyncio
from node.node import Node


def get_sync_data(nodes: list[Node], endpoint: str):
    async def _sync_details(node: Node) -> dict:
        from requests import post

        LOCATION = f"https://{node.address}/{endpoint}"
        res = post(LOCATION)
        if res.status_code == 200:
            return res.json()
        else:
            return None

    async def _gather():
        return await asyncio.gather(*[_sync_details(node) for node in nodes])

    return asyncio.run(_gather())
