const elements = [
    { number: 1, symbol: "H", name: "Hydrogen", row: 1, column: 1 },
    { number: 2, symbol: "He", name: "Helium", row: 1, column: 18 },
    { number: 3, symbol: "Li", name: "Lithium", row: 2, column: 1 },
    { number: 4, symbol: "Be", name: "Beryllium", row: 2, column: 2 },
    { number: 5, symbol: "B", name: "Boron", row: 2, column: 13 },
    { number: 6, symbol: "C", name: "Carbon", row: 2, column: 14 },
    { number: 7, symbol: "N", name: "Nitrogen", row: 2, column: 15 },
    { number: 8, symbol: "O", name: "Oxygen", row: 2, column: 16 },
    { number: 9, symbol: "F", name: "Fluorine", row: 2, column: 17 },
    { number: 10, symbol: "Ne", name: "Neon", row: 2, column: 18 },
    { number: 11, symbol: "Na", name: "Sodium", row: 3, column: 1 },
    { number: 12, symbol: "Mg", name: "Magnesium", row: 3, column: 2 },
    { number: 13, symbol: "Al", name: "Aluminum", row: 3, column: 13 },
    { number: 14, symbol: "Si", name: "Silicon", row: 3, column: 14 },
    { number: 15, symbol: "P", name: "Phosphorus", row: 3, column: 15 },
    { number: 16, symbol: "S", name: "Sulfur", row: 3, column: 16 },
    { number: 17, symbol: "Cl", name: "Chlorine", row: 3, column: 17 },
    { number: 18, symbol: "Ar", name: "Argon", row: 3, column: 18 },
    { number: 19, symbol: "K", name: "Potassium", row: 4, column: 1 },
    { number: 20, symbol: "Ca", name: "Calcium", row: 4, column: 2 },
    { number: 21, symbol: "Sc", name: "Scandium", row: 4, column: 3 },
    { number: 22, symbol: "Ti", name: "Titanium", row: 4, column: 4 },
    { number: 23, symbol: "V", name: "Vanadium", row: 4, column: 5 },
    { number: 24, symbol: "Cr", name: "Chromium", row: 4, column: 6 },
    { number: 25, symbol: "Mn", name: "Manganese", row: 4, column: 7 },
    { number: 26, symbol: "Fe", name: "Iron", row: 4, column: 8 },
    { number: 27, symbol: "Co", name: "Cobalt", row: 4, column: 9 },
    { number: 28, symbol: "Ni", name: "Nickel", row: 4, column: 10 },
    { number: 29, symbol: "Cu", name: "Copper", row: 4, column: 11 },
    { number: 30, symbol: "Zn", name: "Zinc", row: 4, column: 12 },
    { number: 31, symbol: "Ga", name: "Gallium", row: 4, column: 13 },
    { number: 32, symbol: "Ge", name: "Germanium", row: 4, column: 14 },
    { number: 33, symbol: "As", name: "Arsenic", row: 4, column: 15 },
    { number: 34, symbol: "Se", name: "Selenium", row: 4, column: 16 },
    { number: 35, symbol: "Br", name: "Bromine", row: 4, column: 17 },
    { number: 36, symbol: "Kr", name: "Krypton", row: 4, column: 18 },
    { number: 37, symbol: "Rb", name: "Rubidium", row: 5, column: 1 },
    { number: 38, symbol: "Sr", name: "Strontium", row: 5, column: 2 },
    { number: 39, symbol: "Y", name: "Yttrium", row: 5, column: 3 },
    { number: 40, symbol: "Zr", name: "Zirconium", row: 5, column: 4 },
    { number: 41, symbol: "Nb", name: "Niobium", row: 5, column: 5 },
    { number: 42, symbol: "Mo", name: "Molybdenum", row: 5, column: 6 },
    { number: 43, symbol: "Tc", name: "Technetium", row: 5, column: 7 },
    { number: 44, symbol: "Ru", name: "Ruthenium", row: 5, column: 8 },
    { number: 45, symbol: "Rh", name: "Rhodium", row: 5, column: 9 },
    { number: 46, symbol: "Pd", name: "Palladium", row: 5, column: 10 },
    { number: 47, symbol: "Ag", name: "Silver", row: 5, column: 11 },
    { number: 48, symbol: "Cd", name: "Cadmium", row: 5, column: 12 },
    { number: 49, symbol: "In", name: "Indium", row: 5, column: 13 },
    { number: 50, symbol: "Sn", name: "Tin", row: 5, column: 14 },
    { number: 51, symbol: "Sb", name: "Antimony", row: 5, column: 15 },
    { number: 52, symbol: "Te", name: "Tellurium", row: 5, column: 16 },
    { number: 53, symbol: "I", name: "Iodine", row: 5, column: 17 },
    { number: 54, symbol: "Xe", name: "Xenon", row: 5, column: 18 },
    { number: 55, symbol: "Cs", name: "Cesium", row: 6, column: 1 },
    { number: 56, symbol: "Ba", name: "Barium", row: 6, column: 2 },
    { number: 57, symbol: "La", name: "Lanthanum", row: 6, column: 3 },
    { number: 72, symbol: "Hf", name: "Hafnium", row: 6, column: 4 },
    { number: 73, symbol: "Ta", name: "Tantalum", row: 6, column: 5 },
    { number: 74, symbol: "W", name: "Tungsten", row: 6, column: 6 },
    { number: 75, symbol: "Re", name: "Rhenium", row: 6, column: 7 },
    { number: 76, symbol: "Os", name: "Osmium", row: 6, column: 8 },
    { number: 77, symbol: "Ir", name: "Iridium", row: 6, column: 9 },
    { number: 78, symbol: "Pt", name: "Platinum", row: 6, column: 10 },
    { number: 79, symbol: "Au", name: "Gold", row: 6, column: 11 },
    { number: 80, symbol: "Hg", name: "Mercury", row: 6, column: 12 },
    { number: 81, symbol: "Tl", name: "Thallium", row: 6, column: 13 },
    { number: 82, symbol: "Pb", name: "Lead", row: 6, column: 14 },
    { number: 83, symbol: "Bi", name: "Bismuth", row: 6, column: 15 },
    { number: 84, symbol: "Po", name: "Polonium", row: 6, column: 16 },
    { number: 85, symbol: "At", name: "Astatine", row: 6, column: 17 },
    { number: 86, symbol: "Rn", name: "Radon", row: 6, column: 18 },
    { number: 87, symbol: "Fr", name: "Francium", row: 7, column: 1 },
    { number: 88, symbol: "Ra", name: "Radium", row: 7, column: 2 },
    { number: 89, symbol: "Ac", name: "Actinium", row: 7, column: 3 },
    { number: 104, symbol: "Rf", name: "Rutherfordium", row: 7, column: 4 },
    { number: 105, symbol: "Db", name: "Dubnium", row: 7, column: 5 },
    { number: 106, symbol: "Sg", name: "Seaborgium", row: 7, column: 6 },
    { number: 107, symbol: "Bh", name: "Bohrium", row: 7, column: 7 },
    { number: 108, symbol: "Hs", name: "Hassium", row: 7, column: 8 },
    { number: 109, symbol: "Mt", name: "Meitnerium", row: 7, column: 9 },
    { number: 110, symbol: "Ds", name: "Darmstadtium", row: 7, column: 10 },
    { number: 111, symbol: "Rg", name: "Roentgenium", row: 7, column: 11 },
    { number: 112, symbol: "Cn", name: "Copernicium", row: 7, column: 12 },
    { number: 113, symbol: "Nh", name: "Nihonium", row: 7, column: 13 },
    { number: 114, symbol: "Fl", name: "Flerovium", row: 7, column: 14 },
    { number: 115, symbol: "Mc", name: "Moscovium", row: 7, column: 15 },
    { number: 116, symbol: "Lv", name: "Livermorium", row: 7, column: 16 },
    { number: 117, symbol: "Ts", name: "Tennessine", row: 7, column: 17 },
    { number: 118, symbol: "Og", name: "Oganesson", row: 7, column: 18 },
    { number: 58, symbol: "Ce", name: "Cerium", row: 9, column: 4 },
    { number: 59, symbol: "Pr", name: "Praseodymium", row: 9, column: 5 },
    { number: 60, symbol: "Nd", name: "Neodymium", row: 9, column: 6 },
    { number: 61, symbol: "Pm", name: "Promethium", row: 9, column: 7 },
    { number: 62, symbol: "Sm", name: "Samarium", row: 9, column: 8 },
    { number: 63, symbol: "Eu", name: "Europium", row: 9, column: 9 },
    { number: 64, symbol: "Gd", name: "Gadolinium", row: 9, column: 10 },
    { number: 65, symbol: "Tb", name: "Terbium", row: 9, column: 11 },
    { number: 66, symbol: "Dy", name: "Dysprosium", row: 9, column: 12 },
    { number: 67, symbol: "Ho", name: "Holmium", row: 9, column: 13 },
    { number: 68, symbol: "Er", name: "Erbium", row: 9, column: 14 },
    { number: 69, symbol: "Tm", name: "Thulium", row: 9, column: 15 },
    { number: 70, symbol: "Yb", name: "Ytterbium", row: 9, column: 16 },
    { number: 71, symbol: "Lu", name: "Lutetium", row: 9, column: 17 },
    { number: 90, symbol: "Th", name: "Thorium", row: 10, column: 4 },
    { number: 91, symbol: "Pa", name: "Protactinium", row: 10, column: 5 },
    { number: 92, symbol: "U", name: "Uranium", row: 10, column: 6 },
    { number: 93, symbol: "Np", name: "Neptunium", row: 10, column: 7 },
    { number: 94, symbol: "Pu", name: "Plutonium", row: 10, column: 8 },
    { number: 95, symbol: "Am", name: "Americium", row: 10, column: 9 },
    { number: 96, symbol: "Cm", name: "Curium", row: 10, column: 10 },
    { number: 97, symbol: "Bk", name: "Berkelium", row: 10, column: 11 },
    { number: 98, symbol: "Cf", name: "Californium", row: 10, column: 12 },
    { number: 99, symbol: "Es", name: "Einsteinium", row: 10, column: 13 },
    { number: 100, symbol: "Fm", name: "Fermium", row: 10, column: 14 },
    { number: 101, symbol: "Md", name: "Mendelevium", row: 10, column: 15 },
    { number: 102, symbol: "No", name: "Nobelium", row: 10, column: 16 },
    { number: 103, symbol: "Lr", name: "Lawrencium", row: 10, column: 17 }
];

const grid = document.getElementById("periodic-grid");
const elementName = document.getElementById("element-name");
const elementInfo = document.getElementById("element-info");
const elementSymbol = document.getElementById("element-symbol");
const elementMass = document.getElementById("element-mass");
const elementCharges = document.getElementById("element-charges");
const elementPreview = document.getElementById("element-preview");
const previewNumber = document.getElementById("preview-number");
const previewSymbol = document.getElementById("preview-symbol");
const previewName = document.getElementById("preview-name");
const previewMass = document.getElementById("preview-mass");
const previewCharge = document.getElementById("preview-charge");
const legendFilters = Array.from(document.querySelectorAll(".legend-filter"));
const searchForm = document.getElementById("element-search-form");
const searchInput = document.getElementById("element-search");

const groupNumberRows = {
    1: 1,
    2: 2,
    3: 4,
    4: 4,
    5: 4,
    6: 4,
    7: 4,
    8: 4,
    9: 4,
    10: 4,
    11: 4,
    12: 4,
    13: 2,
    14: 2,
    15: 2,
    16: 2,
    17: 2,
    18: 1
};

const detailsByNumber = new Map((window.elementDetails || []).map((element) => [element.atomicNumber, element]));

function normalizeMass(value) {
    if (!value) {
        return "";
    }

    return String(value).replace(/\(([^)]+)\)/g, "($1)");
}

function formatChargeDisplay(charges) {
    if (!charges) {
        return "0";
    }

    return charges
        .split(",")
        .map((item) => item.trim())
        .slice(-2)
        .map((item) => {
            if (item.startsWith("-")) {
                return `${item.slice(1)}-`;
            }
            return `${item}+`;
        })
        .join("<br>");
}

function classifyMaterial(detail) {
    const block = (detail?.groupBlock || "").toLowerCase();

    if (block.includes("metalloid")) {
        return "material-metalloid";
    }

    if (
        block.includes("nonmetal") ||
        block.includes("noble gas") ||
        block.includes("halogen")
    ) {
        return "material-nonmetal";
    }

    return "material-metal";
}

function isSynthetic(number) {
    return number === 43 || number === 61 || number >= 93;
}

function updateDetails(element) {
    const detail = detailsByNumber.get(element.number);
    const mass = normalizeMass(detail?.atomicMass) || "Unknown";
    const chargeText = detail?.ionCharges || "0";
    const chargeDisplay = formatChargeDisplay(chargeText);
    const material = classifyMaterial(detail);
    const syntheticClass = isSynthetic(element.number) ? "synthetic" : "";

    elementName.textContent = element.name;
    elementInfo.textContent = `Atomic Number ${element.number} - ${material.replace("material-", "").replace("-", " ")}`;
    elementSymbol.textContent = element.symbol;
    elementMass.textContent = mass;
    elementCharges.textContent = chargeText || "0";

    previewNumber.textContent = element.number;
    previewSymbol.textContent = element.symbol;
    previewName.textContent = element.name;
    previewMass.textContent = mass;
    previewCharge.innerHTML = chargeDisplay;
    elementPreview.className = `element element-preview ${material} ${syntheticClass}`.trim();
}

function createElementCard(element) {
    const detail = detailsByNumber.get(element.number);
    const mass = normalizeMass(detail?.atomicMass);
    const chargeDisplay = formatChargeDisplay(detail?.ionCharges || "");
    const material = classifyMaterial(detail);
    const syntheticClass = isSynthetic(element.number) ? "synthetic" : "";

    const button = document.createElement("button");
    const number = document.createElement("span");
    const symbol = document.createElement("span");
    const name = document.createElement("span");
    const massText = document.createElement("span");
    const charges = document.createElement("span");

    button.type = "button";
    button.className = `element ${material} ${syntheticClass}`.trim();
    button.dataset.material = material;
    button.style.gridColumn = element.column;
    button.style.gridRow = element.row + 1;
    button.setAttribute("aria-label", `${element.name}, atomic number ${element.number}`);

    number.className = "cell-number";
    number.textContent = element.number;

    symbol.className = "cell-symbol";
    symbol.textContent = element.symbol;

    name.className = "cell-name";
    name.textContent = element.name;

    massText.className = "cell-mass";
    massText.textContent = mass;

    charges.className = "cell-charges";
    charges.innerHTML = chargeDisplay;

    button.append(number, symbol, name, massText, charges);
    button.addEventListener("click", () => updateDetails(element));
    return button;
}

function setMaterialFilter(material) {
    const cards = Array.from(grid.querySelectorAll(".element"));
    const activeButton = legendFilters.find((button) => button.dataset.material === material);
    const isAlreadyActive = activeButton?.classList.contains("is-active");

    legendFilters.forEach((button) => button.classList.remove("is-active"));
    cards.forEach((card) => card.classList.remove("is-match"));

    if (!material || isAlreadyActive) {
        grid.classList.remove("is-filtering");
        return;
    }

    grid.classList.add("is-filtering");
    activeButton.classList.add("is-active");

    cards.forEach((card) => {
        if (card.dataset.material === material) {
            card.classList.add("is-match");
        }
    });
}

function bindLegendFilters() {
    legendFilters.forEach((button) => {
        button.addEventListener("click", () => setMaterialFilter(button.dataset.material));
    });
}

function clearSearchHighlight() {
    const cards = Array.from(grid.querySelectorAll(".element"));
    cards.forEach((card) => card.classList.remove("is-search-match"));
}

function bindSearch() {
    if (!searchForm || !searchInput) {
        return;
    }

    searchForm.addEventListener("submit", (event) => {
        event.preventDefault();
        clearSearchHighlight();

        const query = searchInput.value.trim().toLowerCase();
        if (!query) {
            return;
        }

        const match = elements.find((element) => element.name.toLowerCase() === query);
        if (!match) {
            return;
        }

        const card = Array.from(grid.querySelectorAll(".element")).find(
            (item) => item.getAttribute("aria-label") === `${match.name}, atomic number ${match.number}`
        );

        if (!card) {
            return;
        }

        card.classList.add("is-search-match");
        updateDetails(match);
        card.scrollIntoView({ block: "nearest", inline: "nearest" });
    });
}

function renderGroupNumbers() {
    for (let number = 1; number <= 18; number += 1) {
        const item = document.createElement("div");
        item.className = "group-number";
        item.textContent = number;
        item.style.gridColumn = number;
        item.style.gridRow = groupNumberRows[number];
        grid.append(item);
    }
}

function renderPeriodicTable() {
    const cards = elements.map(createElementCard);
    grid.append(...cards);
}

renderGroupNumbers();
renderPeriodicTable();
updateDetails(elements.find((element) => element.number === 22) || elements[0]);
bindLegendFilters();
bindSearch();
