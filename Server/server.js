var http    = require('http');
var url     = require('url');
var qs      = require('querystring');
var fs      = require('fs');
var crypto  = require('crypto');

var serverAddresss = "127.0.0.1";
var serverPort = 8080;

// Create HTTP Server
var server = http.createServer(function (req, res) {
    try {
        // Parse request URL
        var uri = url.parse(req.url);
        var path = uri.pathname;

        // If POST request, wait till' all data is received.
        if (req.method === "POST") {
            var data = "";

            req.on("data", function(chunk) {
                data += chunk;
            });

            req.on("end", function() {
                handleRequest(path, qs.parse(data), res);
            });
        } else {
            handleRequest(path, qs.parse(uri.query), res);
        }
    } catch (err) {
        // In case of any exceptions, just output a 500 Internal Server Error status code
        res.writeHead(500, {"Content-Type": "text/plain"});
        res.end("Internal Server Error");
    }  
});

// Start listening to port
server.listen(serverPort, serverAddresss, function() {
    console.log("Server now running at http://" + serverAddresss + ":" + serverPort + "/");
});

// Handle HTTP request regardless of method
function handleRequest(path, data, res) {
    switch (path) {
        // Register a new device
        case '/register': {
            if (!data.uuid) { // Make sure that a device uuid is specified
                res.writeHead(400, {"Content-Type": "text/json"});
                res.end(JSON.stringify({
                    error: "Missing uuid parameter"
                }));
            } else {
                // Generate a random key that the device can use to encrypt data
                var key = generateKey();

                // Store key and device uuid here in full implementation
                res.writeHead(200, {"Content-Type": "application/json"});
                res.end(JSON.stringify({
                    key: key
                }));
            }
            break;
        }

        // Get current config
        case '/config': {
            fs.readFile('config.json', 'utf8', function (err, data) {
              if (err) {
                console.log('Config file does not exist');
                res.writeHead(500, {"Content-Type": "text/plain"});
                res.end("Internal Server Error");
              } else {
                res.writeHead(200, {"Content-Type": "application/json"});
                res.end(data);
              }
            });
            break;
        }

        default:
            res.writeHead(404, {"Content-Type": "text/plain"});
            res.end("File Not Found");
            break;
    }
}

function generateKey() {
    var buf = crypto.randomBytes(48);
    return buf.toString('hex');
}