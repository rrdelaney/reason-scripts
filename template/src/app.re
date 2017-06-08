[%bs.raw {|require('./App.css')|}];

let logo: string = [%bs.raw "require('./logo.svg')"];

module App = {
  include ReactRe.Component;
  let name = "App";
  type props = {message: string};
  let render {props} =>
    <div className="App">
      <div className="App-header">
        <img src=logo className="App-logo" alt="logo" />
        <h2> (ReactRe.stringToElement props.message) </h2>
      </div>
      <p className="App-intro">
        (ReactRe.stringToElement "To get started, edit")
        <code> (ReactRe.stringToElement " src/App.re ") </code>
        (ReactRe.stringToElement "and save to reload.")
      </p>
    </div>;
};

include ReactRe.CreateComponent App;

let createElement ::message => wrapProps {message: message};
