const slotValues = ["1", "2", "3", "4", "5", "6", "7"];

var spinInterval = null;
var slots = null;

var spinInterval1= null;
var spinInterval2 = null;
var spinInterval3 = null;

var pos1 = 0;
var pos2 = 0;
var pos3 = 0;


function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

function spin() {
    slots.forEach((slot) => {
    const randomValue = slotValues[Math.floor(Math.random() * slotValues.length)];
    slot.textContent = randomValue;
    });
}

function spin1() {
    slots[0].textContent = slotValues[pos1];
    pos1++;
    pos1 %= slotValues.length;
}


function spin2() {
    slots[1].textContent = slotValues[pos2];
    pos2++;
    pos2 %= slotValues.length;
}

function spin3() {
    slots[2].textContent = slotValues[pos3];
    pos3++;
    pos3 %= slotValues.length;
}




function stop() {
    // clearInterval(spinInterval);
    clearInterval(spinInterval1);
    clearInterval(spinInterval2);
    clearInterval(spinInterval3);
    // var uniqueResults = [...new Set(results)];
    // if (uniqueResults.length == 1) {
    //   $("#popup").show();
    // }
    spinning = false;
}


function start() {
    // spinInterval = setInterval(spin, 100);
    spinInterval1 = setInterval(spin1, 80 + Math.random() * 73);
    spinInterval2 = setInterval(spin2, 99 + Math.random() * 67);
    spinInterval3 = setInterval(spin3, 85 + Math.random() * 71);

    setTimeout(stop, 2000);
}

function init() {
    slots = document.querySelectorAll(".slot");
    const spinButton = document.getElementById("spin-button");
    spinButton.addEventListener("click", start);
}

// on load of the window
window.onload = init;