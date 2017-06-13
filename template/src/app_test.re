open Jest;

test "addition" (fun () => Expect.(expect (3 + 4) |> toBe 7));
