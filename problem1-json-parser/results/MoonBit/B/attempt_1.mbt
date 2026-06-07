///|
/// JSON value ADT.
pub(all) enum Json {
  Null
  Bool(Bool)
  Int(Int)
  Float(Double)
  Str(String)
  Arr(Array[Json])
  Obj(Array[(String, Json)])
} derive(Eq, Show)

///|
/// Parser state: input characters and a position cursor.
struct Parser {
  chars : Array[Char]
  mut pos : Int
}

///|
fn Parser::new(s : String) -> Parser {
  let chars = []
  for c in s {
    chars.push(c)
  }
  { chars, pos: 0 }
}

///|
fn Parser::peek(self : Parser) -> Char? {
  if self.pos < self.chars.length() {
    Some(self.chars[self.pos])
  } else {
    None
  }
}

///|
fn Parser::next(self : Parser) -> Char? {
  match self.peek() {
    Some(c) => {
      self.pos += 1
      Some(c)
    }
    None => None
  }
}

///|
fn Parser::skip_ws(self : Parser) -> Unit {
  while true {
    match self.peek() {
      Some(' ') | Some('\t') | Some('\n') | Some('\r') => self.pos += 1
      _ => break
    }
  }
}

///|
/// Parse error type.
type! ParseError String

///|
/// Top-level parse: skip whitespace, parse a value, ensure no trailing junk.
pub fn parse(s : String) -> Json!ParseError {
  let p = Parser::new(s)
  p.skip_ws()
  let v = p.parse_value!()
  p.skip_ws()
  if p.pos != p.chars.length() {
    raise ParseError("trailing characters")
  }
  v
}

///|
fn Parser::parse_value(self : Parser) -> Json!ParseError {
  self.skip_ws()
  match self.peek() {
    None => raise ParseError("unexpected end of input")
    Some(c) =>
      match c {
        'n' => self.parse_literal!("null", Null)
        't' => self.parse_literal!("true", Bool(true))
        'f' => self.parse_literal!("false", Bool(false))
        '"' => self.parse_string!()
        '[' => self.parse_array!()
        '{' => self.parse_object!()
        '-' => self.parse_number!()
        _ =>
          if c >= '0' && c <= '9' {
            self.parse_number!()
          } else {
            raise ParseError("unexpected character")
          }
      }
  }
}

///|
fn Parser::parse_literal(
  self : Parser,
  lit : String,
  value : Json
) -> Json!ParseError {
  for c in lit {
    match self.next() {
      Some(x) => if x != c { raise ParseError("invalid literal") }
      None => raise ParseError("invalid literal")
    }
  }
  value
}

///|
fn Parser::parse_string(self : Parser) -> Json!ParseError {
  let s = self.parse_raw_string!()
  Str(s)
}

///|
fn Parser::parse_raw_string(self : Parser) -> String!ParseError {
  // consume opening quote
  let _ = self.next()
  let buf = StringBuilder::new()
  while true {
    match self.next() {
      None => raise ParseError("unterminated string")
      Some('"') => return buf.to_string()
      Some('\\') =>
        match self.next() {
          Some('"') => buf.write_char('"')
          Some('\\') => buf.write_char('\\')
          Some('n') => buf.write_char('\n')
          Some(_) => raise ParseError("invalid escape")
          None => raise ParseError("unterminated escape")
        }
      Some(c) => buf.write_char(c)
    }
  }
  raise ParseError("unreachable")
}

///|
fn Parser::parse_number(self : Parser) -> Json!ParseError {
  let start = self.pos
  let mut is_float = false
  // optional leading minus
  if self.peek() == Some('-') {
    self.pos += 1
  }
  // integer part
  match self.peek() {
    Some('0') => {
      self.pos += 1
      // leading zero must not be followed by another digit (e.g. "01")
      match self.peek() {
        Some(d) =>
          if d >= '0' && d <= '9' {
            raise ParseError("leading zero")
          }
        None => ()
      }
    }
    Some(d) =>
      if d >= '1' && d <= '9' {
        self.pos += 1
        while true {
          match self.peek() {
            Some(x) => if x >= '0' && x <= '9' { self.pos += 1 } else { break }
            None => break
          }
        }
      } else {
        raise ParseError("invalid number")
      }
    None => raise ParseError("invalid number")
  }
  // fractional part
  if self.peek() == Some('.') {
    is_float = true
    self.pos += 1
    // must have at least one digit after the dot
    match self.peek() {
      Some(d) =>
        if d >= '0' && d <= '9' {
          self.pos += 1
          while true {
            match self.peek() {
              Some(x) =>
                if x >= '0' && x <= '9' { self.pos += 1 } else { break }
              None => break
            }
          }
        } else {
          raise ParseError("invalid fraction")
        }
      None => raise ParseError("invalid fraction")
    }
  }
  let text = String::from_array(self.chars[start:self.pos].to_array())
  if is_float {
    match (try? @strconv.parse_double(text)) {
      Ok(f) => Float(f)
      Err(_) => raise ParseError("bad float")
    }
  } else {
    match (try? @strconv.parse_int(text)) {
      Ok(i) => Int(i)
      Err(_) => raise ParseError("bad int")
    }
  }
}

///|
fn Parser::parse_array(self : Parser) -> Json!ParseError {
  let _ = self.next() // consume '['
  let items : Array[Json] = []
  self.skip_ws()
  if self.peek() == Some(']') {
    self.pos += 1
    return Arr(items)
  }
  while true {
    self.skip_ws()
    let v = self.parse_value!()
    items.push(v)
    self.skip_ws()
    match self.next() {
      Some(',') => continue
      Some(']') => return Arr(items)
      _ => raise ParseError("expected ',' or ']'")
    }
  }
  raise ParseError("unreachable")
}

///|
fn Parser::parse_object(self : Parser) -> Json!ParseError {
  let _ = self.next() // consume '{'
  let pairs : Array[(String, Json)] = []
  self.skip_ws()
  if self.peek() == Some('}') {
    self.pos += 1
    return Obj(pairs)
  }
  while true {
    self.skip_ws()
    if self.peek() != Some('"') {
      raise ParseError("expected string key")
    }
    let key = self.parse_raw_string!()
    self.skip_ws()
    if self.next() != Some(':') {
      raise ParseError("expected ':'")
    }
    self.skip_ws()
    let v = self.parse_value!()
    pairs.push((key, v))
    self.skip_ws()
    match self.next() {
      Some(',') => continue
      Some('}') => return Obj(pairs)
      _ => raise ParseError("expected ',' or '}'")
    }
  }
  raise ParseError("unreachable")
}
