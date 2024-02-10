const dateOptions = {
  year: "numeric",
  month: "numeric",
};

const today = new Date();

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

var tenureDates = {};

for (let element of document.getElementsByClassName("date")) {
  var date;
  if (element.innerText == "Present") {
    date = today;
  } else {
    date = new Date(Date.UTC(...element.innerText.split("-")));
  }
  element.innerText = date.toLocaleDateString(undefined, dateOptions);
  tenureDates[element.id] = date;
}

for (let element of document.getElementsByClassName("tenure")) {
  id = element.id;
  if (id != undefined) {
    idPrefix = element.id.split("-")[0];
  }
  var dateStart = tenureDates[`${idPrefix}-start`];
  var dateEnd = tenureDates[`${idPrefix}-end`];
  element.innerText = dateDiff(dateStart, dateEnd);
}
