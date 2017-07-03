<h1 align="center">
  <img height="300" src="https://github.com/rrdelaney/reason-scripts/blob/master/docs/cra.png">
  <br>
  Reason Scripts
 </h1>

<pre align="center">
  $ yarn create react-app my-app -- --scripts-version reason-scripts
</pre>

Reason Scripts provides a JS-like development environment for developing web apps with the
[Reason](https://facebook.github.io/reason) programming language and
[React](https://facebook.github.io/react). It bootstraps an environment to automatically
compile all Reason code to JS, provide features like reloading and bundling, and seamlessly
use JS code from Reason.

## Getting Started

To create a new app using Reason and React, run:

```
$ npm install -g bs-platform
$ yarn create react-app <app-name> -- --scripts-version reason-scripts
$ cd <app-name>
$ yarn start
```

This will create a new app the the `<app-name>` directory with the following layout:

```
<app-name>/
  README.md
  node_modules/
  package.json
  bsconfig.json
  .gitignore
  public/
    favicon.ico
    index.html
  src/
    index.re
    index.css
    app.re
    app.css
    logo.svg
```

## Features

### [Everything from Create React App](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md)

### Reason Entrypoint

The entry point to the app is `src/index.re`. From the start your new
app will be based on Reason, but can seamlessly interop with existing JS
files and projects!

### Automatic Compilation of Reason files

Any Reason file will be automatically compiled to a JS file. For example, a file called
`math_fns.re` can be required by a JS file:

```js
import { add } from './math_fns.re'

const sum = add(1, 4)
```

### Jest Integration

Reason Scripts will automatically configure a [Jest](https://facebook.github.io/jest) environment
to test Reason code. Any code found in a file ending with `_test.re` will be considered a test
and run with Jest. From these files, the normal Jest API can be used interacting with any
other modules defined in your app. For example:

```reason
/* math_fns.re */

let add x y => x + y;
```

```reason
/* math_fns_test.re */

open Jest;

test "addition" (fun () => {
  let num_1 = 10;
  let num_2 = 12;

  expect (Math_fns.add num_1 num_2) |> toBe 22;
});
```

For more documentation on the Jest API, see [bs-jest](https://github.com/BuckleTypes/bs-jest)

### Importing non-Reason files

You can require CSS files with:

```reason
[%bs.raw {|require('./App.css')|}];
```

or any other kind of file (like SVG's) with:

```reason
let logo : string = [%bs.raw {|require('./logo.svg')|}];
```

### FlowTyped Integration [WIP]

Reason Scripts automatically generates an interface to any library installed with npm and
[FlowTyped](https://github.com/flowtype/flow-typed)

### Importing JS files [WIP]

If you type the exports of a JS file with Flow types, you can use the file directly
in Reason. For example, in the file `math_fns.js`:

```js
// @flow
// math_fns.js

export function add(x: number, y: number): number {
  return x + y;
}
```

you will be able to access `add` in a Reason file with:

```reason
let run_func x y => Math_fns x y;
```
