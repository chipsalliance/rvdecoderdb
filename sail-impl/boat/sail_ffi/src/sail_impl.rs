pub type MarchBits = u64;
pub type SailUnit = i32;
pub const SAIL_UNIT: SailUnit = 0;

///! [`SailImpl`] define a list of functions that need to be implemented on emulator side.
pub trait SailImpl {
    fn inst_fetch(&mut self, pc: MarchBits) -> MarchBits;
    fn readmem(&self, address: u64, satp: u64) -> u64;
    fn writemem(&mut self, address: u64, data: u64, bytes: u64, satp: u64) -> SailUnit;
    fn exception_raised(&self, arg1: SailUnit) -> bool;
    fn get_exception(&self, arg1: SailUnit) -> u64;
    fn fence_i(&self, pred: u16, succ: u16) -> SailUnit;
    fn is_reset(&mut self, arg1: SailUnit) -> bool;
}
