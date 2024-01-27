import minimist from "minimist";
import { sum } from "./sum.js";
console.log(sum(minimist(process.argv.slice(2))._))