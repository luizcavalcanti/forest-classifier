var http = require("http");
var url = require("url");
var fs = require("fs");
var btoa = require("btoa");
var querystring = require('querystring');

var port = 8080;
var imagesPath = "/Users/luiz/Workspace/geoma-database/ptv-mao/";
var datDir = imagesPath+"/dat";


var server = http.createServer(callback);
server.listen(port);

if (!fs.existsSync(datDir)) {
    fs.mkdirSync(datDir);
}
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
    var nextFile = ("00000" + getCurrentImageNumber(uid)).slice(-5);
    var fileContent = fs.readFileSync(imagesPath+'/'+nextFile+'.jpg');

    response.writeHeader(200, {"Content-Type": "image/jpeg"});
    response.write(btoa(fileContent));
}

function processSaveData(params, response) {
    var uid = params.uid;
    var regionCount = params.regionCount;
    var regions = params['regions[]'];
    var types = params['types[]'];

    var userDir = datDir+"/"+params.uid;
    var nextFile = ("00000" + getCurrentImageNumber(uid)).slice(-5);

    var fileData = createDatFileContent(regions, types, regionCount);
    fs.writeFileSync(userDir+'/'+nextFile+'.dat', fileData);

    response.writeHeader(200, {"Content-Type": "text/plain"});
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
}

function getCurrentImageNumber(userID) {
    var userDir = datDir+"/"+userID;
    if (!fs.existsSync(userDir)) fs.mkdirSync(userDir);
    var files = fs.readdirSync(userDir);
    files = files.filter(datFileFilter);
    return files.length+1;
}

function datFileFilter(value) {
  return endsWith(value, ".dat");
}

function createDatFileContent(regions, types, regionCount) {
    var fileContent = regionCount+"\n";
    if (regionCount > 1) {
        for (var i=0; i<regionCount; i++) {
            fileContent += types[i]+"\n";
            var coords = regions[i].split(",");
            var points = coords.length/2;
            for (var j=0; j<points; j++) {
                fileContent += '['+coords[j]+','+coords[j+points]+']';
            }
            fileContent += '\n';
        }
    } else if (regionCount == 1) {
        fileContent += types+"\n";
        var coords = regions.split(",");
        var points = coords.length/2;
        for (var j=0; j<points; j++) {
            fileContent += '['+coords[j]+','+coords[j+points]+']';
        }
        fileContent += '\n';
    }
    return fileContent;
}