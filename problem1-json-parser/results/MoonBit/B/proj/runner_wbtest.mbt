///|
/// Test runner for the 22 benchmark cases. Reports "N/22".
test "json_22_cases" {
  let mut pass = 0
  let failed : Array[String] = []

  // helper for NORMAL cases: parse must succeed and equal expected.
  fn normal(name : String, input : String, expected : Json) -> Unit {
    match (try? parse(input)) {
      Ok(v) =>
        if v == expected {
          pass += 1
        } else {
          failed.push(name)
        }
      Err(_) => failed.push(name)
    }
  }

  // helper for ERROR cases: parse must fail (without crashing).
  fn err(name : String, input : String) -> Unit {
    match (try? parse(input)) {
      Ok(_) => failed.push(name)
      Err(_) => pass += 1
    }
  }

  // NORMAL
  normal("1_null", "null", Null)
  normal("2_true", "true", Bool(true))
  normal("3_false", "false", Bool(false))
  normal("4_int", "42", Int(42))
  normal("5_float", "3.14", Float(3.14))
  normal("6_string", "\"hello\"", Str("hello"))
  normal("7_escape", "\"a\\\"b\"", Str("a\"b"))
  normal("8_emptyarr", "[]", Arr([]))
  normal("9_emptyobj", "{}", Obj([]))
  normal("10_arr", "[1, 2, 3]", Arr([Int(1), Int(2), Int(3)]))
  normal("11_obj", "{\"a\": 1, \"b\": true}", Obj([
    ("a", Int(1)),
    ("b", Bool(true)),
  ]))
  normal("12_nested", "{\"a\": [1, {\"b\": null}]}", Obj([
    ("a", Arr([Int(1), Obj([("b", Null)])])),
  ]))
  normal("13_spaces", " 42 ", Int(42))

  // ERROR
  err("14_empty", "")
  err("15_trailing_comma", "[1, 2, ]")
  err("16_unclosed_arr", "[1, 2")
  err("17_unclosed_obj", "{\"a\": 1")
  err("18_leading_zero", "01")
  err("19_dot_no_frac", "1.")
  err("20_no_int", ".5")
  err("21_bareword", "foo")
  err("22_unterminated_str", "\"abc")

  println("RESULT: \{pass}/22")
  if failed.length() > 0 {
    let mut s = ""
    for name in failed {
      s = s + name + " "
    }
    println("FAILED: \{s}")
  }
  assert_eq(pass, 22)
}
