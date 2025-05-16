// model-internal exceptions 
function step(unit) : unit -> unit = {
  if (is_reset()) then {
    reset()
  };
  let inst = inst_fetch(PC);
  if (inst[1 .. 0] != 0b11) then {
    //let ast = ext_decode_compressed(inst[15 .. 0]);
    tick_pc_with(2);
    //execute(ast);
  } else {
    let ast = ext_decode(inst);
    execute(ast);
  };
}

// Useless, just to make sail happy
function main() : unit -> unit = {
  step();
}
