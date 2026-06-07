from main import parse_json, JSONParseError

OK = "OK"
ERR = "ERR"

# (case_number, input_text, kind, expected_value_or_None)
cases = [
    (1, 'null', OK, None),
    (2, 'true', OK, True),
    (3, 'false', OK, False),
    (4, '42', OK, 42),
    (5, '3.14', OK, 3.14),
    (6, '"hello"', OK, "hello"),
    (7, '"a\\"b"', OK, 'a"b'),
    (8, '[]', OK, []),
    (9, '{}', OK, {}),
    (10, '[1, 2, 3]', OK, [1, 2, 3]),
    (11, '{"a": 1, "b": true}', OK, {"a": 1, "b": True}),
    (12, '{"a": [1, {"b": null}]}', OK, {"a": [1, {"b": None}]}),
    (13, ' 42 ', OK, 42),
    (14, '', ERR, None),
    (15, '[1, 2, ]', ERR, None),
    (16, '[1, 2', ERR, None),
    (17, '{"a": 1', ERR, None),
    (18, '01', ERR, None),
    (19, '1.', ERR, None),
    (20, '.5', ERR, None),
    (21, 'foo', ERR, None),
    (22, '"abc', ERR, None),
]

failed = []
passed = 0
for num, inp, kind, expected in cases:
    try:
        result = parse_json(inp)
        if kind == ERR:
            failed.append(num)
            print("FAIL case %d: expected error, got %r" % (num, result))
        else:
            # deep equality with type strictness for bool/int
            if result == expected and type(result) == type(expected):
                passed += 1
            else:
                failed.append(num)
                print("FAIL case %d: expected %r got %r" % (num, expected, result))
    except JSONParseError as e:
        if kind == ERR:
            passed += 1
        else:
            failed.append(num)
            print("FAIL case %d: unexpected error %s" % (num, e))
    except Exception as e:
        # any non-crash-handled exception counts as crash/fail
        failed.append(num)
        print("FAIL case %d: crash %r: %s" % (num, type(e).__name__, e))

print("PASS %d/22" % passed)
print("FAILED: %s" % (failed if failed else "none"))
