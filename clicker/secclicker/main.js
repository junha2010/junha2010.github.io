money = 0;
moneyup = 1;
msec = 0;
upcost = 15;
catcost = 25;
workercost = 250;
buildingcost = 5000;
towercost = 10000;
upown = 0;
catown = 0;
workerown = 0;
buildingown = 0;
towerown = 0;
catadd = 1;
workadd = 15;
buildingadd = 1000;
toweradd = 5000;
cboost = 1;
wboost = 1;
catmax = 0;
workmax = 0;
building = 0;
tower = 0;

//save before exiting
function closingCode() {
  if (confirm("You have closed the window, would you like to save?") === true) {
    save();
    return null;
  }
}

function addcomma(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
}
//updates all values
function reloadall() {
  document.getElementById("click").innerHTML =
    "LB/click: " + addcomma(moneyup) + " | LB/sec: " + addcomma(msec);
  document.getElementById("total").innerHTML = "LB: " + addcomma(money);
  document.getElementById("cat").innerHTML =
    catown + "-clicker cat: " + addcomma(catcost) + " | +" + addcomma(catadd) + "/sec";
  document.getElementById("worker").innerHTML =
    workerown + "-worker: " + addcomma(workercost) + " | +" + addcomma(workadd) + "/sec";
  document.getElementById("upgrade").innerHTML =
    building + "-building: " + addcomma(buildingcost) + " | +" + addcomma(buildingadd) + "/sec";
  document.getElementById("upgrade").innerHTML =
    addcomma(upown) + "-main upgrade: " + addcomma(upcost);
}
//overwrites save file
function save() {
  localStorage.setItem("money", money);
  localStorage.setItem("moneyup", moneyup);
  localStorage.setItem("msec", msec);
  localStorage.setItem("upcost", upcost);
  localStorage.setItem("catcost", catcost);
  localStorage.setItem("catadd", catadd);
  localStorage.setItem("workercost", workercost);
  localStorage.setItem("workadd", workadd);
  localStorage.setItem("catown", catown);
  localStorage.setItem("workerown", workerown);
  localStorage.setItem("upown", upown);
  localStorage.setItem("catadd", catadd);
  localStorage.setItem("workadd", workadd);
  localStorage.setItem("cboost", cboost);
  localStorage.setItem("wboost", wboost);
  localStorage.setItem("catmax", catmax);
  localStorage.setItem("workmax", workmax);
  localStorage.setItem("building", building);
  localStorage.setItem("buildingadd", buildingadd);
  localStorage.setItem("buildingcost", buildingcost);
  localStorage.setItem("buildingown", buildingown);
  localStorage.setItem("toweradd", toweradd);
  localStorage.setItem("towerown", towerown);
  localStorage.setItem("towercost", towercost);
}
//loads save file
function load() {
  money = parseInt(localStorage.getItem("money"));
  moneyup = parseInt(localStorage.getItem("moneyup"));
  msec = parseInt(localStorage.getItem("msec"));
  upcost = parseInt(localStorage.getItem("upcost"));
  catcost = parseInt(localStorage.getItem("catcost"));
  upown = parseInt(localStorage.getItem("catadd"));
  workercost = parseInt(localStorage.getItem("workercost"));
  upown = parseInt(localStorage.getItem("workadd"));
  catown = parseInt(localStorage.getItem("catown"));
  workerown = parseInt(localStorage.getItem("workerown"));
  upown = parseInt(localStorage.getItem("upown"));
  catadd = parseInt(localStorage.getItem("catadd"));
  workadd = parseInt(localStorage.getItem("workadd"));
  cboost = parseInt(localStorage.getItem("cboost"));
  wboost = parseInt(localStorage.getItem("wboost"));
  catmax = parseInt(localStorage.getItem("catmax"));
  workmax = parseInt(localStorage.getItem("workmax"));
  building = parseInt(localStorage.getItem("building"));
  building = parseInt(localStorage.getItem("buildingadd"));
  building = parseInt(localStorage.getItem("buildingcost"));
  building = parseInt(localStorage.getItem("buildingown"));
  tower = parseInt(localStorage.getItem("towerown"));
  tower = parseInt(localStorage.getItem("toweradd"));
  tower = parseInt(localStorage.getItem("towercost"));

  reloadall();
}
//resets all values
function reset() {
  if (confirm("Are you sure you want to reset?") === true) {
    money = 0;
    moneyup = 1;
    msec = 0;
    upcost = 15;
    catcost = 25;
    workercost = 250;
    catown = 0;
    workerown = 0;
    upown = 0;
    catadd = 1;
    workadd = 15;
    building = 0;
    buildingadd = 1000;
    buildingcost = 5000;
    toweradd = 5000;
    towercost = 10000;
    towerown = 0;
    reloadall();
  }
}
//timer
function myTimer() {
    money += msec;
  document.getElementById("total").innerHTML = "LB: " + addcomma(money);
}
setInterval(myTimer, 1000);

//what happens when button is clicked
function clicked() {
  money += moneyup;
  document.getElementById("total").innerHTML = "LB: " + addcomma(money);
}
//upgrade function
function upgrade(name) {
  if (name == "clicker cat") {
    if (money >= catcost) {
      
      if (catown <= 13) {
        msec += catadd;
        catadd++;
        cboost = 1;
      } else if (catown == 14) {
        msec += catadd;
        catadd++;
        cboost = 200;
      } else if (catown <= 23) {
        msec += 200 * catadd;
        catadd++;
        cboost = 200;
      } else if (catown == 24) {
        msec += 200 * catadd;
        catadd++;
        cboost = 5000;
      } else if (catown <= 48) {
        msec += 5000 * catadd;
        catadd++;
        cboost = 5000;
      } else if (catown == 49) {
        msec += 5000 * catadd;
        catadd++;
        cboost = 15000;
      } else {
        msec += 15000 * catadd;
        catadd++;
        cboost = 15000;
      }
      catown += 1;
      if (catcost != Infinity)
        money -= catcost;

      catcost = catcost * 2;
      document.getElementById("cat").innerHTML =
        catown + "-clicker cat: " + addcomma(catcost) + " | +" + addcomma(catadd * cboost) + "/sec";
    } else if (catown == 50) {
      document.getElementById("cat").innerHTML =
        catown + "-clicker cat: MAX | +15% click/sec";
    }
  }

  if (name == "worker") {
    if (money >= workercost) {
      
      if (workerown <= 13) {
        msec += workadd;
        workadd++;
        wboost = 1;
      } else if (workerown == 14) {
        msec += workadd;
        workadd++;
        wboost = 200;
      } else if (workerown <= 23) {
        msec += 200 * workadd;
        workadd++;
        wboost = 200;
      } else if (workerown == 24) {
        msec += 200 * workadd;
        workadd++;
        wboost = 5000;
      } else if (workerown <= 48) {
        msec += 5000 * workadd;
        workadd++;
        wboost = 5000;
      } else if (workerown == 49) {
        msec += 5000 * workadd;
        workadd++;
        wboost = 15000;
      } else {
        msec += 15000 * workadd;
        workadd++;
        wboost = 15000;
      }
      workerown += 1;
      if (workercost != Infinity) {
        money -= workercost;
      }
      
      workercost = workercost * 3;
      document.getElementById("worker").innerHTML = 
        workerown + "-worker: " + addcomma(workercost) + " | +" + addcomma(workadd * wboost) + "/sec";
    } else if (workerown == 50) {
      document.getElementById("worker").innerHTML =
        workerown + "-worker: MAX | +35% click/sec";
    }
  }
  if (name == "building") {
    if (money >= buildingcost) {
      
      if (buildingown <= 13) {
        msec += buildingadd;
        buildingadd++;
        wboost = 1;
      } else if (buildingown == 14) {
        msec += buildingadd;
        buildingadd++;
        wboost = 200;
      } else if (buildingown <= 23) {
        msec += 200 * buildingadd;
        buildingadd++;
        wboost = 200;
      } else if (buildingown == 24) {
        msec += 200 * buildingadd;
        buildingadd++;
        wboost = 5000;
      } else if (buildingown <= 48) {
        msec += 5000 * buildingadd;
        buildingadd++;
        wboost = 5000;
      } else if (buildingown == 49) {
        msec += 5000 * buildingadd;
        buildingadd++;
        wboost = 15000;
      } else {
        msec += 15000 * buildingadd;
        buildingadd++;
        wboost = 15000;
      }
      buildingown += 1;

      if (buildingcost != Infinity) {
         money -= buildingcost;
      }

      buildingcost = buildingcost * 1000;
      document.getElementById("building").innerHTML = 
        buildingown + "-building: " + addcomma(buildingcost) + " | +" + addcomma(buildingadd * wboost) + "/sec";
    } else if (buildingown == 50) {
      document.getElementById("building").innerHTML =
        buildingown + "-builing: MAX | +500% click/sec";
    }
  }
  if (name == "tower") {
    if (money >= towercost) {
      
      if (towerown <= 13) {
        msec += toweradd;
        toweradd++;
        wboost = 1;
      } else if (towerown == 14) {
        msec += toweradd;
        toweradd++;
        wboost = 200;
      } else if (towerown <= 23) {
        msec += 2000 * toweradd;
        toweradd++;
        wboost = 200;
      } else if (towerown == 24) {
        msec += 2000 * toweradd;
        toweradd++;
        wboost = 50000;
      } else if (towerown <= 48) {
        msec += 50000000 * toweradd;
        toweradd++;
        wboost = 500000;
      } else if (towerown == 49) {
        msec += 5000 * toweradd;
        toweradd++;
        wboost = 15000;
      } else {
        msec += 15000 * toweradd;
        toweradd++;
        wboost = 15000000;
      }
      towerown += 1;

      if (towercost != Infinity) {
         money -= towercost;
      }

      towercost = towercost * 100000;
      document.getElementById("tower").innerHTML = 
        towerown + "-tower: " + addcomma(towercost) + " | +" + addcomma(toweradd * wboost) + "/sec";
    } else if (towerown == 50) {
      document.getElementById("tower").innerHTML =
        towerown + "-tower: MAX | +50000% click/sec";
    }
  }
  if (name == "upgrade") {
    if (money >= upcost) {
      moneyup += upcost / 15;
      if (upcost != Infinity)
        money -= upcost;
      upown += 1;
      upcost = upcost * 5;
      document.getElementById("upgrade").innerHTML =
        addcomma(upown) + "-main upgrade: " + addcomma(upcost);
      if (catown == 50) {
        msec -= catmax;
        catmax = Math.floor(moneyup * 0.15);
        msec += catmax;
      }
      if (workerown == 50) {
        msec -= workmax;
        workmax = Math.floor(moneyup * 0.35);
        msec += workmax;
      }
    }
  }

  document.getElementById("click").innerHTML =
    "LB/click: " + addcomma(moneyup) + " | LB/sec: " + addcomma(msec);
  document.getElementById("total").innerHTML = "LB: " + addcomma(money);
}
