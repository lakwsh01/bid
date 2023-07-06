def kwarg_check(checker: dict[str, type], **kwargs):
    print(kwargs)
    for k, t in checker.items():
        assert isinstance(kwargs[k], t), Exception(
            400,
            "block_invaild",
            f"Key {k}, must not be null and should be {t}, but kwargs[k]({type(kwargs[k])}) was given",
        )
    return kwargs
