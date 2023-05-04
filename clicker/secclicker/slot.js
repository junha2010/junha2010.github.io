const slotValues = ["1", "2", "3", "4", "5", "6", "7"];

const slots = document.querySelectorAll(".slot");
var spinInterval = null;

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

const spinButton = document.querySelector(".spin-button");
spinButton.addEventListener("click", start);