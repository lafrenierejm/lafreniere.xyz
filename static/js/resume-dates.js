const dateOptions = {
  year: "numeric",
  month: "numeric",
};

const today = new Date();

const dates = {
  utd: {
    start: new Date(Date.UTC(2014, 8)),
    end: new Date(Date.UTC(2018, 5)),
  },
  ren: {
    start: new Date(Date.UTC(2021, 3)),
    3: new Date(Date.UTC(2022, 2)),
    end: today,
  },
  jcp: {
    start: new Date(Date.UTC(2018, 6)),
    jr: new Date(Date.UTC(2018, 8)),
    1: new Date(Date.UTC(2020, 1)),
    end: new Date(Date.UTC(2021, 2)),
  },
  ng: {
    start: new Date(Date.UTC(2016, 5)),
    end: new Date(Date.UTC(2016, 8)),
  },
};

function dateDiff(start, end) {
  const _MS_PER_DAY = 1000 * 60 * 60 * 24;

  // Discard the time and time-zone information.
  const utcStart = Date.UTC(
    start.getFullYear(),
    start.getMonth(),
    start.getDate()
  );
  const utcEnd = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate());

  var days = Math.floor((utcEnd - utcStart) / _MS_PER_DAY);
  const years = 365 < days ? Math.floor(days / 365) : 0;
  days -= years * 365;
  const months = 30 < days ? Math.floor(days / 30) : 0;

  var units = [];
  if (years == 1) {
    units.push("1 year");
  } else if (1 < years) {
    units.push(`${years} years`);
  }
  if (months == 1) {
    units.push("1 month");
  } else if (1 < months) {
    units.push(`${months} months`);
  }

  if (!units) {
    return "";
  }

  return ` (${units.join(", ")})`;
}

for (let [org, orgDates] of Object.entries(dates)) {
  for (let [event, date] of Object.entries(orgDates)) {
    var key = [org, event].join("-");
    for (let elem of document.getElementsByClassName(key)) {
      elem.innerText = date.toLocaleDateString(undefined, dateOptions);
    }
  }
  var element = document.getElementById(`${org}-total`);
  if (element) {
    element.innerText = dateDiff(orgDates.start, orgDates.end);
  }
}
