from flask import render_template


def render(route: str):
    if route == "/":
        return index()
    else:
        return "Template Not Found"


def index():
    return render_template("index.html", ddd="ssdgf h0sdg 0g0 0")
