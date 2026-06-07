'use strict';

// JSON parser implemented by hand (no built-in JSON.parse).
// Throws an Error on invalid input.

function parseJSON(text) {
  let i = 0;
  const n = text.length;

  function error(msg) {
    throw new Error(msg + ' at position ' + i);
  }

  function skipWhitespace() {
    while (i < n) {
      const c = text[i];
      if (c === ' ' || c === '\t' || c === '\n' || c === '\r') {
        i++;
      } else {
        break;
      }
    }
  }

  function parseValue() {
    skipWhitespace();
    if (i >= n) error('Unexpected end of input');
    const c = text[i];
    if (c === '{') return parseObject();
    if (c === '[') return parseArray();
    if (c === '"') return parseString();
    if (c === 't' || c === 'f') return parseBoolean();
    if (c === 'n') return parseNull();
    if (c === '-' || (c >= '0' && c <= '9')) return parseNumber();
    error('Unexpected token');
  }

  function parseObject() {
    i++; // consume '{'
    const obj = {};
    skipWhitespace();
    if (i < n && text[i] === '}') {
      i++;
      return obj;
    }
    while (true) {
      skipWhitespace();
      if (i >= n || text[i] !== '"') error('Expected string key');
      const key = parseString();
      skipWhitespace();
      if (i >= n || text[i] !== ':') error('Expected colon');
      i++; // consume ':'
      const value = parseValue();
      obj[key] = value;
      skipWhitespace();
      if (i >= n) error('Unexpected end of input in object');
      if (text[i] === ',') {
        i++;
        continue;
      }
      if (text[i] === '}') {
        i++;
        return obj;
      }
      error('Expected comma or closing brace');
    }
  }

  function parseArray() {
    i++; // consume '['
    const arr = [];
    skipWhitespace();
    if (i < n && text[i] === ']') {
      i++;
      return arr;
    }
    while (true) {
      const value = parseValue();
      arr.push(value);
      skipWhitespace();
      if (i >= n) error('Unexpected end of input in array');
      if (text[i] === ',') {
        i++;
        continue;
      }
      if (text[i] === ']') {
        i++;
        return arr;
      }
      error('Expected comma or closing bracket');
    }
  }

  function parseString() {
    i++; // consume opening '"'
    let result = '';
    while (i < n) {
      const c = text[i];
      if (c === '"') {
        i++;
        return result;
      }
      if (c === '\\') {
        i++;
        if (i >= n) error('Unexpected end of input in string');
        const esc = text[i];
        if (esc === '"') result += '"';
        else if (esc === '\\') result += '\\';
        else if (esc === 'n') result += '\n';
        else error('Invalid escape sequence');
        i++;
      } else {
        result += c;
        i++;
      }
    }
    error('Unterminated string');
  }

  function parseBoolean() {
    if (text.slice(i, i + 4) === 'true') {
      i += 4;
      return true;
    }
    if (text.slice(i, i + 5) === 'false') {
      i += 5;
      return false;
    }
    error('Invalid token');
  }

  function parseNull() {
    if (text.slice(i, i + 4) === 'null') {
      i += 4;
      return null;
    }
    error('Invalid token');
  }

  function parseNumber() {
    const start = i;
    if (text[i] === '-') i++;
    // integer part
    if (i >= n || text[i] < '0' || text[i] > '9') error('Invalid number');
    if (text[i] === '0') {
      i++;
      // leading zero must not be followed by another digit (e.g. "01")
      if (i < n && text[i] >= '0' && text[i] <= '9') error('Invalid number: leading zero');
    } else {
      while (i < n && text[i] >= '0' && text[i] <= '9') i++;
    }
    // fractional part
    if (i < n && text[i] === '.') {
      i++;
      if (i >= n || text[i] < '0' || text[i] > '9') error('Invalid number: missing fraction digits');
      while (i < n && text[i] >= '0' && text[i] <= '9') i++;
    }
    const numStr = text.slice(start, i);
    return Number(numStr);
  }

  // top-level
  skipWhitespace();
  if (i >= n) error('Empty input');
  const value = parseValue();
  skipWhitespace();
  if (i < n) error('Unexpected trailing characters');
  return value;
}

module.exports = { parseJSON };
