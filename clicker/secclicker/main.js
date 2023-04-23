money = 0;
moneyup = 1;
msec = 0;
upcost = 15;
catcost = 25;
workercost = 250;
buildingcost = 50000;
towercost = 100000;
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
company = 0;
companyadd = 50000;
companyown = 0;
companycost = 1000000000;
band = 0;
bandadd = 100000;
bandcost = 10000000000000000000000;
bandown = 0;
plusClick = 0;
plusClickadd = 10;
plusClickcost = 1000;
plusClickown = 0;

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
  document.getElementById("pc").innerHTML = "PC: " + addcomma(plusClickown) + " | + " + addcomma(plusClickadd) + "/sec";
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
  localStorage.setItem("tower", tower);
  localStorage.setItem("towerown", towerown);
  localStorage.setItem("towercost", towercost);
  localStorage.setItem("companyadd", companyadd);
  localStorage.setItem("company", company);
  localStorage.setItem("companyown", companyown);
  localStorage.setItem("companycost", companycost);
  localStorage.setItem("bandadd", bandadd);
  localStorage.setItem("band", band);
  localStorage.setItem("bandown", bandown);
  localStorage.setItem("bandcost", bandcost);
  localStorage.setItem("plusClickadd", plusClickadd);
  localStorage.setItem("plusClick", plusClick);
  localStorage.setItem("plusClickown", plusClickown);
  localStorage.setItem("plusClickcost", plusClickcost);
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
  buildingadd = parseInt(localStorage.getItem("buildingadd"));
  buildingcost = parseInt(localStorage.getItem("buildingcost"));
  buildingown = parseInt(localStorage.getItem("buildingown"));
  towerown = parseInt(localStorage.getItem("towerown"));
  toweradd = parseInt(localStorage.getItem("toweradd"));
  towercost = parseInt(localStorage.getItem("towercost"));
  tower = parseInt(localStorage.getItem("tower"));
  companyown = parseInt(localStorage.getItem("companyown"));
  companycost = parseInt(localStorage.getItem("companycost"));
  companyadd = parseInt(localStorage.getItem("companyadd"));
  company = parseInt(localStorage.getItem("company"));
  band = parseInt(localStorage.getItem("band"));
  bandcost = parseInt(localStorage.getItem("bandcost"));
  bandadd = parseInt(localStorage.getItem("bandadd"));
  bandown = parseInt(localStorage.getItem("bandown"));
  plusClick = parseInt(localStorage.getItem("plusClick"));
  plusClickcost = parseInt(localStorage.getItem("plusClickcost"));
  plusClickadd = parseInt(localStorage.getItem("plusClickadd"));
  plusClickown = parseInt(localStorage.getItem("plusClickown"));
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
    buildingcost = 50000;
    towercost = 100000;
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
    company = 0;
    companyadd = 50000;
    companyown = 0;
    companycost = 1000000000;
    band = 0;
    bandadd = 100000;
    bandcost = 10000000000000000000000;
    bandown = 0;
    plusClick = 0;
    plusClickadd = 10;
    plusClickcost = 1000;
    plusClickown = 0;
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
        msec += 20 * buildingadd;
        buildingadd++;
        wboost = 200;
      } else if (buildingown == 24) {
        msec += 200 * buildingadd;
        buildingadd++;
        wboost = 5000;
      } else if (buildingown <= 48) {
        msec += 500 * buildingadd;
        buildingadd++;
        wboost = 5000;
      } else if (buildingown == 49) {
        msec += 5000 * buildingadd;
        buildingadd++;
        wboost = 1500;
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
        msec += 200 * toweradd;
        toweradd++;
        wboost = 200;
      } else if (towerown == 24) {
        msec += 2000 * toweradd;
        toweradd++;
        wboost = 5000;
      } else if (towerown <= 48) {
        msec += 500000 * toweradd;
        toweradd++;
        wboost = 50100;
      } else if (towerown == 49) {
        msec += 5000 * toweradd;
        toweradd++;
        wboost = 15000;
      } else {
        msec += 15000 * toweradd;
        toweradd++;
        wboost = 150000;
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
  if (name == "company") {
    if (money >= companycost) {
      
      if (companyown <= 13) {
        msec += companyadd;
        companyadd++;
        wboost = 1;
      } else if (companyown == 14) {
        msec += companyadd;
        companyadd++;
        wboost = 200;
      } else if (companyown <= 23) {
        msec += 2000 * companyadd;
        companyadd++;
        wboost = 200;
      } else if (companyown == 24) {
        msec += 2000 * companyadd;
        companyadd++;
        wboost = 50000;
      } else if (companyown <= 48) {
        msec += 500000 * companyown;
        companyadd++;
        wboost = 50000;
      } else if (companyown == 49) {
        msec += 5000 * companyadd;
        companyadd++;
        wboost = 15000;
      } else {
        msec += 1500 * companyadd;
        companyadd++;
        wboost = 1500000;
      }
      companyown += 1;

      if (companycost != Infinity) {
         money -= companycost;
      }

      companycost = companycost * 1000000000000000;
      document.getElementById("company").innerHTML = 
        companyown + "-company: " + addcomma(companycost) + " | +" + addcomma(companyadd * wboost) + "/sec";
    } else if (companyown == 50) {
      document.getElementById("company").innerHTML =
        companyown + "-company: MAX | +5000000000000000000000% click/sec";
    }
  }
  if (name == "band") {
    if (money >= bandcost) {
      
      if (bandown <= 13) {
        msec += bandadd;
        bandadd++;
        wboost = 1;
      } else if (bandown == 14) {
        msec += bandadd;
        bandadd++;
        wboost = 200;
      } else if (bandown <= 23) {
        msec += 2000000000 * bandadd;
        bandadd++;
        wboost = 200;
      } else if (bandown == 24) {
        msec += 200000 * bandadd;
        bandadd++;
        wboost = 500000;
      } else if (bandown <= 48) {
        msec += 500000 * bandown;
        bandadd++;
        wboost = 500000;
      } else if (bandown == 49) {
        msec += 5000000000 * bandadd;
        bandadd++;
        wboost = 1500000000;
      } else {
        msec += 150000000 * bandadd;
        bandadd++;
        wboost = 1500000000;
      }
      bandown += 1;

      if (bandcost != Infinity) {
         money -= bandcost;
      }

      bandcost = bandcost * 100000000000000000000000;
      document.getElementById("band").innerHTML = 
        bandown + "-band: " + addcomma(bandcost) + " | +" + addcomma(bandadd * wboost) + "/sec";
    } else if (bandown == 50) {
      document.getElementById("band").innerHTML =
        bandown + "-band: MAX | +500000000000000000000000000000% click/sec";
    }
  }
  if (name == "plusClick") {
    if (money >= plusClickcost) {
      
      if (plusClickown <= 13) {
        msec += plusClickadd;
        plusClickadd++;
        wboost = 1;
      } else if (plusClickown == 14) {
        msec += plusClickadd;
        plusClickadd++;
        wboost = 200;
      } else if (plusClickown <= 23) {
        msec += 20000 * plusClickadd;
        plusClickadd++;
        wboost = 200;
      } else if (plusClickown == 24) {
        msec += 200000 * plusClickadd;
        plusClickadd++;
        wboost = 500000;
      } else if (plusClickown <= 48) {
        msec += 500000 * plusClickown;
        plusClickadd++;
        wboost = 5000000;
      } else if (plusClickown == 49) {
        msec += 5000000 * plusClickadd;
        plusClickadd++;
        wboost = 150000000;
      } else {
        msec += 1500000000 * plusClickadd;
        plusClickadd++;
        wboost = 1500000;
      }
      plusClickown += 1;

      if (plusClickcost != Infinity) {
         money -= plusClickcost;
      }

      plusClickcost = plusClickcost * 100000000;
      document.getElementById("plusClick").innerHTML = 
      plusClickown + "PC: " + addcomma(plusClickown) + " | +" + addcomma(plusClickadd * wboost) + "/sec";
    } else if (plusClickown == 50) {
      document.getElementById("plusClick").innerHTML =
      plusClickown + "-plusClick: MAX | +500000% click/sec";
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

function copyright() {
  document.getElementById("copyright").innerHTML = "©copyright you dumb dum";
  alert("copyright you dumb dum");
}
