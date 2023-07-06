from datetime import datetime


def stamp():
    return datetime.now().timestamp() * 100
