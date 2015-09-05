// Global vars
var clickX = new Array();
var clickY = new Array();
var regionCount = 0;
var regionHistory = new Array();
var regionType = new Array();
var isClosedRegion = false;
var context;
var allowPaint;
var paint;
var image;

// HTML Elements
var btnStroke;
var btnClosedRegion;
var btnSaveRegion;
var btnDeleteLast;

// Create the canvas itself
function initCanvas(canvasDiv, width, height) {
    configureButtons();
    var canvasDiv = document.getElementById('canvasDiv');

    canvas = document.createElement('canvas');
    canvas.setAttribute('width', width);
    canvas.setAttribute('height', height);
    canvas.setAttribute('style', 'background-color: gray;')
    canvas.setAttribute('id', 'canvas');

    canvasDiv.appendChild(canvas);
    if(typeof G_vmlCanvasManager != 'undefined') {
        canvas = G_vmlCanvasManager.initElement(canvas);
    }

    context = canvas.getContext("2d");
    registerCanvasEvents();
    loadCanvasImage();
}

function configureButtons() {
    btnStroke = document.getElementById('btnStroke');
    btnStroke.disabled = false;

    btnClosedRegion = document.getElementById('btnClosedRegion');
    btnClosedRegion.disabled = false;
    
    btnSaveRegion = document.getElementById('btnSaveRegion');
    btnSaveRegion.disabled = true;
    
    btnDeleteLast = document.getElementById('btnDeleteLast');
    btnDeleteLast.disabled = true;

    registerButtonsEvents();
}

function registerButtonsEvents() {
    $('#btnStroke').mousedown(function(e) {
        isClosedRegion = false;
        btnStroke.disabled = true;
        btnClosedRegion.disabled = true;
        btnSaveRegion.disabled = false;
        allowPaint = true;
        btnStroke.setAttribute('class', 'btn-selected');
        btnClosedRegion.setAttribute('class', 'btn-unselected');
    });

    $('#btnClosedRegion').mousedown(function(e) {
        isClosedRegion = true;
        btnStroke.disabled = true;
        btnClosedRegion.disabled = true;
        btnSaveRegion.disabled = false;
        allowPaint = true;
        btnClosedRegion.setAttribute('class', 'btn-selected');
        btnStroke.setAttribute('class', 'btn-unselected');
    });

    $('#btnSaveRegion').mousedown(function(e) {
        saveCurrentRegion();
        redraw();
    });

    $('#btnDeleteLast').mousedown(function(e) {
        if (regionCount>0) {
            regionCount--;
            regionHistory.splice(regionHistory.length-1,1);
            regionType.splice(regionType.length-1,1);
            redraw();
            if (regionCount===0) {
                btnDeleteLast.disabled = true;
            }
        }
    });

    $('#btnDone').mousedown(function(e) {
        msg = 'Are you sure you finished segmenting the image?\nA new image will be given to you';
        reallyDone = confirm(msg);
        if (reallyDone) {
            if (clickX.length>0) {
                saveCurrentRegion();
                redraw();
            }
            console.log("TODO: Save region data on backend");
        }
    });
}

function registerCanvasEvents() {
    $('#canvas').mousedown(function(e){
        var mouseX = e.pageX - this.offsetLeft;
        var mouseY = e.pageY - this.offsetTop;
        paint = true;
        if (allowPaint) {
            addClick(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);
        }
        redraw();
    });

    $('#canvas').mousemove(function(e){
        if(paint && allowPaint){
            addClick(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);
            redraw();
        }
    });

    $('#canvas').mouseup(function(e){
        paint = false;
    });

    $('#canvas').mouseleave(function(e){
        paint = false;
    });
}

function loadCanvasImage() {
    image = new Image();
    image.onload = function() {
        context.drawImage(image, 0, 0);
    };
    image.src = '../../../../geoma-database/ptv-mao/00002.jpg';
}

function addClick(x, y) {
    clickX.push(x);
    clickY.push(y);
}

function saveCurrentRegion() {
    regionHistory.push([clickX, clickY]);
    console.log(isClosedRegion?'cr':'pt');
    regionType.push(isClosedRegion?'cr':'pt');
    clickX = new Array();
    clickY = new Array();
    regionCount++;
    btnClosedRegion.setAttribute('class', 'btn-unselected');
    btnStroke.setAttribute('class', 'btn-unselected');
    btnStroke.disabled = true;
    btnStroke.disabled = false;
    btnClosedRegion.disabled = true;
    btnClosedRegion.disabled = false;
    btnSaveRegion.disabled = true;
    btnDeleteLast.disabled = false;
    allowPaint = false;
}

function redraw() {
    context.clearRect(0, 0, context.canvas.width, context.canvas.height); // Clears the canvas
    context.drawImage(image, 0, 0);
    context.lineJoin = "round";
    context.lineWidth = 4;
    // Draw past regions
    historyColor = "rgba(0, 0, 0, 0.8)";
    context.strokeStyle = historyColor;
    context.fillStyle = historyColor;
    drawPreviousRegions();
    // Draw current region
    context.strokeStyle = "#FF0000";
    drawCurrentRegion();
}

function drawPreviousRegions() {
    for (var i=0; i<regionHistory.length; i++) {
        context.beginPath();
        var xPoints = regionHistory[i][0];
        var yPoints = regionHistory[i][1];
        for(var j=0; j < xPoints.length; j++) {
            context.lineTo(xPoints[j], yPoints[j]);
        }
        if (regionType[i]=='cr') {
            context.closePath();
            context.fill();
        } else {
            context.stroke();
        }
    }
}

function drawCurrentRegion() {
    context.beginPath();
    for(var i=0; i < clickX.length; i++) {
        context.lineTo(clickX[i], clickY[i]);
    }
    if (isClosedRegion) {
        context.closePath();
    }
    context.stroke();
}