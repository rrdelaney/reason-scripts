open Jest;

test("addition", (_) =>
  Expect.(expect(3 + 4) |> toBe(7))
);
