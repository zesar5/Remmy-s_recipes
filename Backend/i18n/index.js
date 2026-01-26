const es = require("./es");
const en = require("./en");

module.exports = function getMessages(req) {
  const lang = req.headers["accept-language"];

  if (lang && lang.startsWith("en")) return en;
  return es; // Español por defecto
};
