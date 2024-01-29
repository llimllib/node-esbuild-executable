import minimist from "npm:minimist";
import { sum } from "../sum.js";

console.log(sum(minimist(Deno.args)._));
