// JSON value representation
pub enum Json {
  Null
  Bool(Bool)
  Int(Int)
  Float(Double)
  Str(String)
  Arr(Array[Json])
  Obj(Array[(String, Json)])
} derive(Eq, Show)

priv struct Parser {
  chars : Array[Char]
  mut pos : Int
}

fn Parser::new(s : String) -> Parser {
  let chars = []
  for c in s {
    chars.push(c)
  }
  { chars, pos: 0 }
}

fn peek(self : Parser) -> Char? {
  if self.pos < self.chars.length() {
    Some(self.chars[self.pos])
  } else {
    None
  }
}

fn advance(self : Parser) -> Char? {
  match self.peek() {
    Some(c) => {
      self.pos += 1
      Some(c)
    }
    None => None
  }
}

fn skip_ws(self : Parser) -> Unit {
  while true {
    match self.peek() {
      Some(' ') | Some('\t') | Some('\n') | Some('\r') => self.pos += 1
      _ => break
    }
  }
}

// top-level parse: trim surrounding whitespace, parse a value, require EOF
pub fn parse(s : String) -> Json raise {
  let p = Parser::new(s)
  p.skip_ws()
  let v = p.parse_value()
  p.skip_ws()
  if p.pos != p.chars.length() {
    fail("trailing characters")
  }
  v
}

fn parse_value(self : Parser) -> Json raise {
  self.skip_ws()
  match self.peek() {
    None => fail("unexpected end of input")
    Some(c) =>
      if c == '{' {
        self.parse_object()
      } else if c == '[' {
        self.parse_array()
      } else if c == '"' {
        Str(self.parse_string())
      } else if c == 't' || c == 'f' {
        self.parse_bool()
      } else if c == 'n' {
        self.parse_null()
      } else if c == '-' || (c >= '0' && c <= '9') {
        self.parse_number()
      } else {
        fail("unexpected character")
      }
  }
}

fn expect_literal(self : Parser, lit : String) -> Unit raise {
  for c in lit {
    match self.advance() {
      Some(ch) => if ch != c { fail("invalid literal") }
      None => fail("unexpected end in literal")
    }
  }
}

fn parse_null(self : Parser) -> Json raise {
  self.expect_literal("null")
  Null
}

fn parse_bool(self : Parser) -> Json raise {
  match self.peek() {
    Some('t') => {
      self.expect_literal("true")
      Bool(true)
    }
    Some('f') => {
      self.expect_literal("false")
      Bool(false)
    }
    _ => fail("invalid bool")
  }
}

fn parse_string(self : Parser) -> String raise {
  // consume opening quote
  match self.advance() {
    Some('"') => ()
    _ => fail("expected string")
  }
  let buf = StringBuilder::new()
  while true {
    match self.advance() {
      None => fail("unterminated string")
      Some('"') => break
      Some('\\') =>
        match self.advance() {
          Some('"') => buf.write_char('"')
          Some('\\') => buf.write_char('\\')
          Some('n') => buf.write_char('\n')
          _ => fail("invalid escape")
        }
      Some(c) => buf.write_char(c)
    }
  }
  buf.to_string()
}

fn parse_number(self : Parser) -> Json raise {
  let start = self.pos
  // optional minus
  match self.peek() {
    Some('-') => self.pos += 1
    _ => ()
  }
  // integer part
  let int_start = self.pos
  match self.peek() {
    Some('0') => {
      self.pos += 1
      // after leading 0, no more digits allowed
      match self.peek() {
        Some(d) => if d >= '0' && d <= '9' { fail("leading zero") }
        None => ()
      }
    }
    Some(d) =>
      if d >= '1' && d <= '9' {
        while true {
          match self.peek() {
            Some(c) => if c >= '0' && c <= '9' { self.pos += 1 } else { break }
            None => break
          }
        }
      } else {
        fail("invalid number")
      }
    None => fail("invalid number")
  }
  if self.pos == int_start {
    fail("missing integer part")
  }
  let mut is_float = false
  // fractional part
  match self.peek() {
    Some('.') => {
      is_float = true
      self.pos += 1
      let frac_start = self.pos
      while true {
        match self.peek() {
          Some(c) => if c >= '0' && c <= '9' { self.pos += 1 } else { break }
          None => break
        }
      }
      if self.pos == frac_start {
        fail("digit expected after decimal point")
      }
    }
    _ => ()
  }
  let mut text = ""
  for i in start..<self.pos {
    text = text + self.chars[i].to_string()
  }
  if is_float {
    Float(parse_double(text))
  } else {
    Int(parse_int_str(text))
  }
}

fn parse_int_str(s : String) -> Int {
  let mut neg = false
  let mut acc = 0
  let mut i = 0
  let chars = []
  for c in s {
    chars.push(c)
  }
  if chars.length() > 0 && chars[0] == '-' {
    neg = true
    i = 1
  }
  while i < chars.length() {
    acc = acc * 10 + (chars[i].to_int() - '0'.to_int())
    i += 1
  }
  if neg {
    -acc
  } else {
    acc
  }
}

fn parse_double(s : String) -> Double {
  let chars = []
  for c in s {
    chars.push(c)
  }
  let mut neg = false
  let mut i = 0
  if chars.length() > 0 && chars[0] == '-' {
    neg = true
    i = 1
  }
  let mut int_part = 0.0
  while i < chars.length() && chars[i] != '.' {
    int_part = int_part * 10.0 +
      (chars[i].to_int() - '0'.to_int()).to_double()
    i += 1
  }
  let mut result = int_part
  if i < chars.length() && chars[i] == '.' {
    i += 1
    let mut scale = 0.1
    while i < chars.length() {
      result = result + (chars[i].to_int() - '0'.to_int()).to_double() * scale
      scale = scale / 10.0
      i += 1
    }
  }
  if neg {
    -result
  } else {
    result
  }
}

fn parse_array(self : Parser) -> Json raise {
  // consume [
  self.pos += 1
  let arr = []
  self.skip_ws()
  match self.peek() {
    Some(']') => {
      self.pos += 1
      return Arr(arr)
    }
    _ => ()
  }
  while true {
    let v = self.parse_value()
    arr.push(v)
    self.skip_ws()
    match self.advance() {
      Some(',') => self.skip_ws()
      Some(']') => break
      _ => fail("expected , or ] in array")
    }
  }
  Arr(arr)
}

fn parse_object(self : Parser) -> Json raise {
  // consume {
  self.pos += 1
  let obj = []
  self.skip_ws()
  match self.peek() {
    Some('}') => {
      self.pos += 1
      return Obj(obj)
    }
    _ => ()
  }
  while true {
    self.skip_ws()
    match self.peek() {
      Some('"') => ()
      _ => fail("expected string key")
    }
    let key = self.parse_string()
    self.skip_ws()
    match self.advance() {
      Some(':') => ()
      _ => fail("expected : in object")
    }
    let v = self.parse_value()
    obj.push((key, v))
    self.skip_ws()
    match self.advance() {
      Some(',') => ()
      Some('}') => break
      _ => fail("expected , or } in object")
    }
  }
  Obj(obj)
}
