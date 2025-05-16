val inst_fetch = pure "inst_fetch" : XLENBITS -> bits(32)
val fence_i = pure "fence_i" : (bits(4), bits(4)) -> unit
val is_reset = pure "is_reset" : unit -> bool

// phy_read* API all have one argument `address` with `XLENBITS` width, return
// specific length value from that given address.
val phy_read_byte = pure "phy_read_byte" : XLENBITS -> bits(8)
val phy_read_half_word = pure "phy_read_half_word" : XLENBITS -> bits(16)
val phy_read_word = pure "phy_read_word" : XLENBITS -> bits(32)
val phy_read_double_word = pure "phy_read_double_word" : XLENBITS -> bits(64)

// phy_write* API accept two arguments, write specific length data from the
// second argument `value` to the first argument `address`.
val phy_write_byte = pure "phy_write_byte" : (XLENBITS, bits(8)) -> unit
val phy_write_half_word = pure "phy_write_half_word" : (XLENBITS, bits(16)) -> unit
val phy_write_word = pure "phy_write_word" : (XLENBITS, bits(32)) -> unit
val phy_write_double_word = pure "phy_write_double_word" : (XLENBITS, bits(64)) -> unit

val exception_raised = pure "exception_raised" : unit -> bool
