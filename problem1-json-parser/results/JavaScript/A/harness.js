'use strict';

const { parseJSON } = require('./main.js');
const assert = require('assert');

function deepEqual(a, b) {
  try {
    assert.deepStrictEqual(a, b);
    return true;
  } catch (e) {
    return false;
  }
}

const successCases = [
  { n: 1, input: 'null', expected: null },
  { n: 2, input: 'true', expected: true },
  { n: 3, input: 'false', expected: false },
  { n: 4, input: '42', expected: 42 },
  { n: 5, input: '3.14', expected: 3.14 },
  { n: 6, input: '"hello"', expected: 'hello' },
  { n: 7, input: '"a\\"b"', expected: 'a"b' },
  { n: 8, input: '[]', expected: [] },
  { n: 9, input: '{}', expected: {} },
  { n: 10, input: '[1, 2, 3]', expected: [1, 2, 3] },
  { n: 11, input: '{"a": 1, "b": true}', expected: { a: 1, b: true } },
  { n: 12, input: '{"a": [1, {"b": null}]}', expected: { a: [1, { b: null }] } },
  { n: 13, input: ' 42 ', expected: 42 },
];

const errorCases = [
  { n: 14, input: '' },
  { n: 15, input: '[1, 2, ]' },
  { n: 16, input: '[1, 2' },
  { n: 17, input: '{"a": 1' },
  { n: 18, input: '01' },
  { n: 19, input: '1.' },
  { n: 20, input: '.5' },
  { n: 21, input: 'foo' },
  { n: 22, input: '"abc' },
];

const failed = [];
let pass = 0;

for (const tc of successCases) {
  try {
    const got = parseJSON(tc.input);
    if (deepEqual(got, tc.expected)) {
      pass++;
    } else {
      failed.push(tc.n);
      console.log(`Case ${tc.n} FAIL: got ${JSON.stringify(got)} expected ${JSON.stringify(tc.expected)}`);
    }
  } catch (e) {
    failed.push(tc.n);
    console.log(`Case ${tc.n} FAIL (threw): ${e.message}`);
  }
}

for (const tc of errorCases) {
  try {
    const got = parseJSON(tc.input);
    failed.push(tc.n);
    console.log(`Case ${tc.n} FAIL: expected error, got ${JSON.stringify(got)}`);
  } catch (e) {
    pass++;
  }
}

console.log(`\nPASS ${pass}/22`);
if (failed.length) console.log(`FAILED CASES: ${failed.join(', ')}`);
