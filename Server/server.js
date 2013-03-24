var http    = require('http');
var url     = require('url');
var qs      = require('querystring');
var fs      = require('fs');
var crypto  = require('crypto');
var mkdirp  = require('mkdirp');

var serverPort = 4000;

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
server.listen(serverPort, function() {
    console.log("Server now running at http://" + server.address().address + ":" + serverPort + "/");
});

// Handle HTTP request regardless of method
function handleRequest(path, data, res) {
    switch (path) {
        // Register a new device
        case '/register': {
            if (!data.device_id) { // Make sure that a device id is specified
                res.writeHead(400, {"Content-Type": "text/json"});
                res.end(JSON.stringify({
                    error: "Missing device_id parameter"
                }));
            } else {
                // Generate a random key that the device can use to encrypt data
                var key = generateKey();

                // Store key and device id here in full implementation
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

        // Upload probe data
        case '/upload': {
            if (!data.device_id) { // Make sure that a device id is specified
                res.writeHead(400, {"Content-Type": "text/json"});
                res.end(JSON.stringify({
                    error: "Missing device_id parameter"
                }));
            } else if (!data.file_hash) { // Make sure that the file hash is specified
                res.writeHead(400, {"Content-Type": "text/json"});
                res.end(JSON.stringify({
                    error: "Missing file_hash parameter"
                }));
            } else if (data.file_hash.length != 32) { // Make sure that the file hash has correct length
                res.writeHead(400, {"Content-Type": "text/json"});
                res.end(JSON.stringify({
                    error: "file_hash must be exactly 32 characters"
                }));
            } else if (!data.data) { // Make sure that the data is specified
                res.writeHead(400, {"Content-Type": "text/json"});
                res.end(JSON.stringify({
                    error: "Missing data parameter"
                }));
            } else {
                // Check integrity of uploaded data
                var hash = crypto.createHash('md5')
                    .update(data.data)
                    .digest("hex");

                if (hash != data.file_hash) {
                    res.writeHead(400, {"Content-Type": "text/json"});
                    res.end(JSON.stringify({
                        error: "Integrity check failed"
                    }));
                } else {
                    // Write status response
                    res.writeHead(200, {"Content-Type": "application/json"});
                    res.end(JSON.stringify({
                        status: 'ok'
                    }));

                    console.log('Data received for device: ' + data.device_id);

                    // Create data directory if necessary
                    mkdirp("data/" + data.device_id, function (err) {
                        if (err) {
                            console.log(err);
                        }
                        else
                        {
                            // Little hackish/quick way to get current datetime formatted for a filename
                            var filename = new Date().toISOString()
                                .replace(/T/, '-') // Replace 'T' with a dash
                                .replace(/\..+/, '') // Remove anything after the dot (We don't need timezone and second precision) 
                                .replace(/:\s*/g, '') + // Strip colons
                                ".json";

                            // Save data file
                            fs.writeFile("data/" + data.device_id + "/" + filename, data.data, function(err) {
                                if (err) {
                                    console.log(err);
                                } else {
                                    // Make file only readable and writeable by current user
                                    fs.chmodSync("data/" + data.device_id + "/" + filename, '700');
                                }
                            }); 
                        }
                    });
                }
            }
            break;
        }

        default:
            res.writeHead(404, {"Content-Type": "text/plain"});
            res.end("File Not Found");
            break;
    }
}

function generateKey() {
    var buf = crypto.randomBytes(20);
    return buf.toString('hex');
}