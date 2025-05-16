#include <stdint.h>

typedef uint8_t Unit;
const uint8_t SAIL_UNIT = 0;

// NOTE: march_bits should be update for each Sail implementation
typedef uint64_t MarchBits;

Unit zstep(Unit zunit);
void model_init(void);
MarchBits zset_pc(MarchBits pc);

MarchBits zPC;

MarchBits zread_GPR(MarchBits register_index);
