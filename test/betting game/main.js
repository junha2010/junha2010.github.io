function Plant() {
    var betAmount = document.getElementById("betAmount").value;
    var bank = document.getElementById("bank").innerText;
    document.getElementById('bank').innerText = bank - betAmount;
}
bank.value = bank.value - betAmount;
