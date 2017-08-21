[%bs.raw {|require('./index.css')|}];

external register_service_worker : unit => unit = "default" [@@bs.module "./registerServiceWorker"];

ReactDOMRe.renderToElementWithId <App message="Welcome to React and Reason" /> "root";

register_service_worker ();
