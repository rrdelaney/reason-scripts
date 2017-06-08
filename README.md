# reason-scripts

This package provides a `react-scripts` fork for using ReasonML. To bootstrap a new app
using React and Reason, run:

```
$ yarn create react-app <app name> -- --scripts-version reason-scripts
```


This creates a new app using Reason and React in the directory `<app-name>`.
From there, you can run the app with `yarn start` and edit the Reason files
(`index.re` and `app.re`). The app will reload on changes.

# Importing JS files [WIP]

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


# Importing non-Reason files

You can require CSS files with:

```reason
[%bs.raw {|require('./App.css')|}];
```

or any other kind of file (like SVG's) with:

```reason
let logo : string = [%bs.raw {|require('./logo.svg')|}];
```
