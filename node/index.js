const http = require('http');
const port = process.env.PORT || 8080;

const requestHandler = (request, response) => {
  console.log(request.url);
  response.end("Hello GO Open Source 2018!!");
}

const server = http.createServer(requestHandler);

server.listen(port, (err) => {
  if (err) {
    return console.log(err);
  }

  console.log(`server is listening on ${port}`);
})
