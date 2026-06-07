class JSONParseError(Exception):
    pass


class _Parser:
    def __init__(self, text):
        self.text = text
        self.pos = 0
        self.n = len(text)

    def parse(self):
        self._skip_ws()
        value = self._parse_value()
        self._skip_ws()
        if self.pos != self.n:
            raise JSONParseError("trailing characters at %d" % self.pos)
        return value

    def _skip_ws(self):
        while self.pos < self.n and self.text[self.pos] in " \t\n\r":
            self.pos += 1

    def _peek(self):
        if self.pos < self.n:
            return self.text[self.pos]
        return None

    def _parse_value(self):
        c = self._peek()
        if c is None:
            raise JSONParseError("unexpected end of input")
        if c == '"':
            return self._parse_string()
        if c == '{':
            return self._parse_object()
        if c == '[':
            return self._parse_array()
        if c == 't' or c == 'f':
            return self._parse_bool()
        if c == 'n':
            return self._parse_null()
        if c == '-' or c.isdigit():
            return self._parse_number()
        raise JSONParseError("unexpected token %r at %d" % (c, self.pos))

    def _expect_literal(self, literal, result):
        if self.text[self.pos:self.pos + len(literal)] == literal:
            self.pos += len(literal)
            return result
        raise JSONParseError("invalid literal at %d" % self.pos)

    def _parse_null(self):
        return self._expect_literal("null", None)

    def _parse_bool(self):
        if self._peek() == 't':
            return self._expect_literal("true", True)
        return self._expect_literal("false", False)

    def _parse_string(self):
        # assumes current char is opening quote
        self.pos += 1
        chars = []
        while True:
            if self.pos >= self.n:
                raise JSONParseError("unterminated string")
            c = self.text[self.pos]
            if c == '"':
                self.pos += 1
                return "".join(chars)
            if c == '\\':
                self.pos += 1
                if self.pos >= self.n:
                    raise JSONParseError("unterminated escape")
                e = self.text[self.pos]
                if e == '"':
                    chars.append('"')
                elif e == '\\':
                    chars.append('\\')
                elif e == 'n':
                    chars.append('\n')
                else:
                    raise JSONParseError("invalid escape %r" % e)
                self.pos += 1
            else:
                chars.append(c)
                self.pos += 1

    def _parse_number(self):
        start = self.pos
        if self._peek() == '-':
            self.pos += 1
        # integer part
        if self.pos >= self.n or not self.text[self.pos].isdigit():
            raise JSONParseError("invalid number at %d" % start)
        if self.text[self.pos] == '0':
            self.pos += 1
            # leading zero must not be followed by more digits
            if self.pos < self.n and self.text[self.pos].isdigit():
                raise JSONParseError("invalid number (leading zero) at %d" % start)
        else:
            while self.pos < self.n and self.text[self.pos].isdigit():
                self.pos += 1
        is_float = False
        # fractional part
        if self.pos < self.n and self.text[self.pos] == '.':
            is_float = True
            self.pos += 1
            if self.pos >= self.n or not self.text[self.pos].isdigit():
                raise JSONParseError("invalid number (trailing dot) at %d" % start)
            while self.pos < self.n and self.text[self.pos].isdigit():
                self.pos += 1
        raw = self.text[start:self.pos]
        if is_float:
            return float(raw)
        return int(raw)

    def _parse_array(self):
        self.pos += 1  # consume [
        result = []
        self._skip_ws()
        if self._peek() == ']':
            self.pos += 1
            return result
        while True:
            self._skip_ws()
            result.append(self._parse_value())
            self._skip_ws()
            c = self._peek()
            if c == ',':
                self.pos += 1
                continue
            if c == ']':
                self.pos += 1
                return result
            raise JSONParseError("expected ',' or ']' at %d" % self.pos)

    def _parse_object(self):
        self.pos += 1  # consume {
        result = {}
        self._skip_ws()
        if self._peek() == '}':
            self.pos += 1
            return result
        while True:
            self._skip_ws()
            if self._peek() != '"':
                raise JSONParseError("expected string key at %d" % self.pos)
            key = self._parse_string()
            self._skip_ws()
            if self._peek() != ':':
                raise JSONParseError("expected ':' at %d" % self.pos)
            self.pos += 1
            self._skip_ws()
            value = self._parse_value()
            result[key] = value
            self._skip_ws()
            c = self._peek()
            if c == ',':
                self.pos += 1
                continue
            if c == '}':
                self.pos += 1
                return result
            raise JSONParseError("expected ',' or '}' at %d" % self.pos)


def parse_json(text):
    return _Parser(text).parse()
