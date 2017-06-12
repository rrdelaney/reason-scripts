<h1 align="center">Reason Scripts</h1>

<pre align="center">
  $ yarn create react-app my-app -- --scripts-version reason-scripts
</pre>

Reason Scripts provides a JS-like development environment for developing web apps with the
[Reason](https://facebook.github.io/reason) programming language and
[React](https://facebook.github.io/react). It bootstraps an environment to automatically
compile all Reason code to JS, provide features like reloading and bundling, and seamlessly
use JS code from Reason.

## Features

### Automatic Compilation of Reason files

Any Reason file will be automatically converted to a JS file. For example, a file called
`math_fns.re` can be required by a JS file:

```js
import { add } from './math_fns.re'

const sum = add(1, 4)
```

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

### Jest Integration [WIP]

Reason Scripts will automatically configure a [Jest](https://facebook.github.io/jest) environment
to test Reason code.

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
