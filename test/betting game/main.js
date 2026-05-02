function Plant() {
    const betAmountNode = document.getElementById("betAmount");
    const bankNode = document.getElementById("bank");

    if (!betAmountNode || !bankNode) {
        return;
    }

    const betAmount = Number(betAmountNode.value) || 0;
    const currentBank = Number(bankNode.textContent || bankNode.value) || 0;
    const nextBank = currentBank - betAmount;

    if ("value" in bankNode) {
        bankNode.value = nextBank;
    } else {
        bankNode.textContent = nextBank;
    }
}
