[%bs.raw {|require('./app.css')|}];

external logo : string = "./logo.svg" [@@bs.module];

let component = ReasonReact.statelessComponent "App";

let make ::message _children => {
  ...component,
  render: fun _self =>
    <div className="App">
      <div className="App-header">
        <img src=logo className="App-logo" alt="logo" />
        <h2> (ReactRe.stringToElement message) </h2>
      </div>
      <p className="App-intro">
        (ReactRe.stringToElement "To get started, edit")
        <code> (ReactRe.stringToElement " src/App.re ") </code>
        (ReactRe.stringToElement "and save to reload.")
      </p>
    </div>
};
