val inst_fetch = pure "inst_fetch" : XLENBITS -> bits(32)
val fence_i = pure "fence_i" : (bits(4), bits(4)) -> unit
val is_reset = pure "is_reset" : unit -> bool