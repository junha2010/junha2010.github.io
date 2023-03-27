var score = 0;

function add() {
    score = score + 1;
    update()
}

function update() {
    document.getElementById("number").value = score;
    document.getElementById("number").innerHTML = score;
}


function save() {
    localStorage.setItem("score", score);
}

function Load() {
    score = parseInt(localStorage.getItem("score"));
    update()
}

function reset() {
    if (confirm("Are you sure you want to reset?") === true) {
        score = 0;
        update();
      }
}