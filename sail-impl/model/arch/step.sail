// model-internal exceptions 
function step(unit) : unit -> unit = {
  if (is_reset()) then {
    reset()
  };
  let inst = inst_fetch(PC);
  let ast = ext_decode(inst);
  execute(ast);
}

// Useless, just to make sail happy
function main() : unit -> unit = {
  step();
}
