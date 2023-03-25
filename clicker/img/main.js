var score = 0;
var plusScore = 0;

function add() {
    score = score + 1 + plusScore;
    update()
}

function update() {
    document.querySelector("#countNum").value = score;
    document.querySelector("#nowPlusScore").innerHTML = "Plus Score: " + plusScore;
}

function store() {
    if(score >= (20 * (1 + plusScore))) {
        score = (20*(1+plusScore)) - score;
        plusScore = plusScore + 1;
        update()
    }
    else {
        alert("get the hall out of here!");
    }
}

function save() {
    localStorage.setItem("score", score);
    localStorage.setItem("plusScore", plusScore);
}


function load() {
    score = localStorage.getItem("score");
    score = parseInt(score);
    plusScore = localStorage.getItem("plusScore");
    plusScore = parseInt(plusScore);
    update()
}

function update() {
    document.querySelector("#nowNeedScore").innerHTML = "you need" + (20*(1+plusScore)) + "score.";
}