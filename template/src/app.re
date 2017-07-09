[%bs.raw {|require('./app.css')|}];

external logo : string = "./logo.svg" [@@bs.module];

let component = ReasonReact.statelessComponent "App";

let make ::message _children => {
  ...component,
  render: fun _self =>
    <div className="App">
      <div className="App-header">
        <img src=logo className="App-logo" alt="logo" />
        <h2> (ReasonReact.stringToElement message) </h2>
      </div>
      <p className="App-intro">
        (ReasonReact.stringToElement "To get started, edit")
        <code> (ReasonReact.stringToElement " src/App.re ") </code>
        (ReasonReact.stringToElement "and save to reload.")
      </p>
    </div>
};
