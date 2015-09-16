var http = require("http");
var url = require("url");
var fs = require("fs");
var btoa = require("btoa");
var querystring = require('querystring');

var argc = process.argv.length;
var port = 80;
var imagesPath = "../../database/ptv-mao/";

// WORKAROUND TO FUNCTION PROPERLY ON PM2
if (argc>2) { // if there is more than 2 args, it's not on PM2
    if (argc !== 4) {
        console.log('Usage: node nodeserver.js <port number> <image database path>');
        process.exit(1);
    }
    port = process.argv[2];
    imagesPath = process.argv[3];
}

var datDir = imagesPath+"/dat";
var maxPerImage = 5;

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
            processOperation(operation, params, response);
            response.end();
        });
    } else if (request.method == 'GET') {
        var parsedURL = url.parse(request.url, true);
        var content = parsedURL.pathname;
        getStaticContent(content, response);
        response.end();
    }
};

function getStaticContent(content, response) {
    if (content === '/') {
        content = 'index.html';
    }
    var filepath = 'src/'+content;
    if (fs.existsSync(filepath)) {
        response.write(fs.readFileSync(filepath))
    } else {
        response.writeHeader(404);
    }
}

function processOperation(operation, parameters, response) {
    switch (operation) {
        case '/getNewImage':
            processNewImage(parameters, response);
            break;
        case '/saveData':
            processSaveData(parameters, response);
            break;
        case '/checkUserState':
            processCheckUserState(parameters, response);
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

function processCheckUserState(params, response) {
    var uid = params.uid;
    var userDir = datDir+"/"+params.uid;
    var userState = "old";
    if (!fs.existsSync(userDir)) userState = "new";
    response.writeHeader(200, {"Content-Type": "text/plain"});
    response.write(userState);
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

    files = files.sort();
    var last = 0;
    if (files.length > 0) {
        last = Number(files[files.length-1].split('.')[0]);
    }
    var fileIndex = last+1;
    while (countFileOccurrences(fileIndex) >= maxPerImage) {
        fileIndex += 1;
    }
    return fileIndex;
}

function countFileOccurrences(fileIndex) {
    var filename = ("00000" + fileIndex).slice(-5) + ".dat";
    return dirWalkCount(datDir, filename);
}

var dirWalkCount = function(dir, filename) {
    var count = 0;
    var files = fs.readdirSync(dir);
    files.forEach(function(file) {
        if (fs.statSync(dir +'/'+ file).isDirectory()) {
            count += dirWalkCount(dir +'/'+ file + '/', filename);
        } else if (file===filename){
            count += 1;
        }
    });
    return count;
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