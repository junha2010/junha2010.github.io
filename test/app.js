let scoreValue = 0;

function score() {
    scoreValue += 1;

    const scoreNode = document.querySelector(".score");
    if (scoreNode) {
        scoreNode.textContent = scoreValue;
    }
}

