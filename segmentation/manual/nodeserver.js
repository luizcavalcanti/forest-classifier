var http = require("http");
var url = require("url");
var fs = require("fs");
var btoa = require("btoa");
var querystring = require('querystring');

var port = 8080;
var imagesPath = "/Users/luiz/Workspace/geoma-database/ptv-mao/";


var server = http.createServer(callback);
server.listen(port);
console.log("Server Running on "+port);

/* CALLBACKS */
function callback(request, response) {
    console.log('['+request.method+']'+request.url);
    if (request.method == 'POST') {
        var fullBody = '';
        request.on('data', function(chunk) {
            fullBody += chunk.toString();
        });
        request.on('end', function() {
            var parsedURL = url.parse(request.url, true);
            var operation = parsedURL.pathname;
            var params = querystring.parse(fullBody);
            response.end(processOperation(operation, params, response));
        });
    } else if (request.method == 'GET') {
        var parsedURL = url.parse(request.url, true);
        var content = parsedURL.pathname;
        response.end(returnStaticContent(content));
    }
};

function returnStaticContent(content) {
    return fs.readFileSync('src/'+content);
}

function processOperation(operation, parameters, response) {
    switch (operation) {
        case '/getNewImage':
            processNewImage(parameters, response);
            break;
        case '/saveData':
            processSaveData(parameters, response);
            break;
        default:
            processInvalidOperation(operation, response);
    }
}

function processNewImage(params, response) {
    var uid = params.uid;
    var number = Math.ceil(Math.random()*100);
    var fileContent = fs.readFileSync(imagesPath+'/000'+number+'.jpg');
    console.log("TODO: get actually relevant image");
    response.writeHeader(200, {"Content-Type": "image/jpeg"});
    response.write(btoa(fileContent));
}

function processSaveData(params, response) {
    var uid = params.uid;
    var segments = params.segments;
    console.log(segments);
    response.writeHeader(200, {"Content-Type": "text/plain"});
    console.log("TODO: save data");
    response.write("ok");
}

function processInvalidOperation(operation, response) {
    var msg = "Operation "+operation+" is not valid";
    console.log(msg);
    response.writeHeader(200, {"Content-Type": "text/plain"});
    response.write(msg);
}

function endsWith(text, ending) {
    return text.indexOf(ending, text.length - ending.length) !== -1;
};