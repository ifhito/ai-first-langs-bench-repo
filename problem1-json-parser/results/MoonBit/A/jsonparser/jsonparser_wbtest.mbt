// Test harness: run all 22 cases, report pass count and failing case numbers.

fn ok_case(num : Int, input : String, expected : Json, failed : Array[Int]) -> Unit {
  let got = try? parse(input)
  match got {
    Ok(v) => if v != expected { failed.push(num) }
    Err(_) => failed.push(num)
  }
}

fn err_case(num : Int, input : String, failed : Array[Int]) -> Unit {
  let got = try? parse(input)
  match got {
    Ok(_) => failed.push(num)
    Err(_) => ()
  }
}

test "all 22 cases" {
  let failed : Array[Int] = []

  // success cases 1-13
  ok_case(1, "null", Null, failed)
  ok_case(2, "true", Bool(true), failed)
  ok_case(3, "false", Bool(false), failed)
  ok_case(4, "42", Int(42), failed)
  ok_case(5, "3.14", Float(3.14), failed)
  ok_case(6, "\"hello\"", Str("hello"), failed)
  // case 7: JSON text is "a\"b" -> string a"b
  ok_case(7, "\"a\\\"b\"", Str("a\"b"), failed)
  ok_case(8, "[]", Arr([]), failed)
  ok_case(9, "{}", Obj([]), failed)
  ok_case(10, "[1, 2, 3]", Arr([Int(1), Int(2), Int(3)]), failed)
  ok_case(11, "{\"a\": 1, \"b\": true}", Obj([("a", Int(1)), ("b", Bool(true))]), failed)
  ok_case(
    12,
    "{\"a\": [1, {\"b\": null}]}",
    Obj([("a", Arr([Int(1), Obj([("b", Null)])]))]),
    failed,
  )
  ok_case(13, " 42 ", Int(42), failed)

  // error cases 14-22
  err_case(14, "", failed)
  err_case(15, "[1, 2, ]", failed)
  err_case(16, "[1, 2", failed)
  err_case(17, "{\"a\": 1", failed)
  err_case(18, "01", failed)
  err_case(19, "1.", failed)
  err_case(20, ".5", failed)
  err_case(21, "foo", failed)
  err_case(22, "\"abc", failed)

  let pass = 22 - failed.length()
  println("PASS_COUNT=" + pass.to_string() + "/22")
  if failed.length() > 0 {
    println("FAILED_CASES=" + failed.to_string())
  } else {
    println("FAILED_CASES=[]")
  }
}
