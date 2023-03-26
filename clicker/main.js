var score = 0;
var plusScore = 0;

function add() {
    score = score + 1 + plusScore;
    update()
}

function update() {
    document.getElementById("countNum").value = score;
    document.getElementById("nowPlusScore").innerHTML = "Plus Score: " + plusScore;
    document.querySelector("#nowNeedScore").innerHTML = "you need" + (20*(1+plusScore)) + "score.";
}

function store() {
    if(score >= (20 * (1 + plusScore))) {
        score = score - (20*(1+plusScore)) ;
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
