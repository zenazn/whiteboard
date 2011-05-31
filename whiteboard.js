var whiteboard_init = function(){
    // TODO: error checking that doesn't suck
    // I can has websocket?
    if (!"WebSocket" in window) {
        document.body.innerHTML = "<strong>Oops! Your browser doesn't support WebSockets</strong>";
        return;
    }
    var c = document.getElementById('c');
    // canvas?
    if (!c.getContext) {
        document.body.innerHTML = "<strong>Oops! Your browser doesn't support Canvas</strong>";
        return;
    }
    c.width = document.width;
    c.height = document.height;

    var g = c.getContext('2d');

    // Set up websocket
    var ws = new WebSocket("ws://avtok.com:8080/whiteboard");
    ws.onopen = function() {
        $(document.body).addClass("ready");
        console.log("open");
    }
    ws.onmessage = function(e) {
        var mesg = e.data.split(':');
        console.log(e.data);
        if (mesg[0] == 'line') {
            g.beginPath();
            g.moveTo(mesg[1], mesg[2]);
            g.lineTo(mesg[3], mesg[4]);
            g.stroke();
            if (down) {
                // We were interrupting something
                g.beginPath();
                g.moveTo(oldcoords[0], oldcoords[1]);
            }
        }
    }
    ws.onclose = function() {
        console.log("close");
    }

    // Let's draw!
    var down = false;
    var oldcoords = [0, 0];
    function mousedown(e) {
        down = true;
        g.beginPath();
        g.moveTo(e.pageX, e.pageY);
        oldcoords = [e.pageX, e.pageY];
    }
    function mousemove(e) {
        if (!down) return;
        g.lineTo(e.pageX, e.pageY);
        g.stroke();
        var newcoords = [e.pageX, e.pageY];
        var mesg = ["line", oldcoords[0], oldcoords[1], e.pageX, e.pageY];
        ws.send(mesg.join(':'));
        g.beginPath();
        g.moveTo(e.pageX, e.pageY);
        oldcoords = newcoords;
    }
    function mouseup(e) {
        down = false;
        g.lineTo(e.pageX, e.pageY);
        g.stroke();
    }
    $('#c').mousedown(mousedown);
    $('#c').mousemove(mousemove);
    $('#c').mouseup(mouseup);
}

$(whiteboard_init);
