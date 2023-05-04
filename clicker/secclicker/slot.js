const slotValues = ["1", "2", "3", "4", "5", "6", "7"];

var spinInterval = null;
var slots = null;

function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

function spin() {
    slots.forEach((slot) => {
    const randomValue = slotValues[Math.floor(Math.random() * slotValues.length)];
    slot.textContent = randomValue;
    });
}

function stop() {
    clearInterval(spinInterval);
    // var uniqueResults = [...new Set(results)];
    // if (uniqueResults.length == 1) {
    //   $("#popup").show();
    // }
    spinning = false;
}


function start() {
    spinInterval = setInterval(spin, 100);
    setTimeout(stop, 2000);
}

function init() {
    slots = document.querySelectorAll(".slot");
    const spinButton = document.getElementById("spin-button");
    spinButton.addEventListener("click", start);
}

// on load of the window
window.onload = init;