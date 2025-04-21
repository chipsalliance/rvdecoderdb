use crate::sail_impl::{MarchBits, SailImpl, SailUnit, SAIL_UNIT};
use hex;
use std::ffi::{c_char, CStr};
use std::io::Read;
use std::sync::Mutex;
use xmas_elf::program::{ProgramHeader, Type};
use xmas_elf::{header, ElfFile};

pub struct Simulator {
    memory: Vec<u8>,
    instruction_count: u64,
    fetch_count: u64,
    step_count: u64,
    is_reset: bool,
    finished: bool,
}

impl Simulator {
    // TODO: replace this with a builder
    pub fn new(memory_size: usize, elf_path: &str) -> Self {
        let mut sim = Self {
            memory: vec![0u8; memory_size],
            instruction_count: 0,
            step_count: 0,
            fetch_count: 0,
            is_reset: true,
            finished: false,
        };

        println!("[sail] init module");

        unsafe {
            crate::ffi::model_init();
        }

        println!("[sail] load elf");
        let entry = Self::load_elf(elf_path, &mut sim.memory).unwrap();

        println!("[sail] reset vector to {:#x}", entry);
        crate::ffi::reset_vector(entry);

        sim
    }

    pub fn check_step(&mut self) -> Result<(), ()> {
        if self.finished {
            // TODO: concrete error
            return Err(());
        }

        self.instruction_count += 1;
        self.step_count += 1;

        Ok(())
    }

    // TODO: Eliminate all the unwrap
    fn load_elf(fname: &str, mem: &mut [u8]) -> Result<u64, ()> {
        let mut file = std::fs::File::open(fname).unwrap();
        let mut buffer = Vec::new();
        file.read_to_end(&mut buffer).unwrap();

        let elf_file = ElfFile::new(&buffer).unwrap();

        let header = elf_file.header;
        assert_eq!(header.pt2.machine().as_machine(), header::Machine::RISC_V);

        // TODO: multi arch support?
        for ph in elf_file.program_iter() {
            if let ProgramHeader::Ph64(ph) = ph {
                if ph.get_type() == Ok(Type::Load) {
                    let offset = ph.offset as usize;
                    let size = ph.file_size as usize;
                    let addr = ph.virtual_addr as usize;

                    let slice = &buffer[offset..offset + size];

                    let dst: &mut _ = &mut mem[addr..addr + size];
                    for (i, byte) in slice.iter().enumerate() {
                        dst[i] = *byte;
                    }
                }
            }
        }

        Ok(header.pt2.entry_point())
    }
}

impl SailImpl for Simulator {
    fn inst_fetch(&mut self, pc: MarchBits) -> MarchBits {
        let idx: usize = pc.try_into().unwrap();
        // TODO: user friendly bound check
        let mut inst = [0u8; 4];
        inst.copy_from_slice(&self.memory[idx..idx + 4]);
        self.fetch_count += 1;
        // TODO: use trace logging to control output verbosity
        println!(
            "[sail] current PC {:#x}, x1: {:#x} x2: {:#x} s0: {:#x}",
            unsafe { crate::ffi::zPC },
            unsafe { crate::ffi::zx1 },
            unsafe { crate::ffi::zx2 },
            unsafe { crate::ffi::zx8 }
        );
        println!(
            "[sail] returning instruction {}",
            hex::encode(inst.into_iter().rev().collect::<Vec<u8>>())
        );
        // TODO: optional enable debug trace
        // std::thread::sleep(std::time::Duration::from_millis(300));
        let inst: MarchBits = u32::from_le_bytes(inst).into();
        // TODO: instruction valid should be determine at Sail side.
        if inst == 0 {
            panic!("[sail] instruction fetch fail with zero data")
        }
        inst
    }

    ///! [`readmem`] will always read a whole word. The result will be masked at Sail side.
    //
    // TODO:
    // * this simulator doesn't support TLB yet, so we left SATP unhandle.
    // * we should not always run lw here, Sail side should give us mask and length info
    fn readmem(&self, address: u64, _satp: u64) -> u64 {
        let idx: usize = address.try_into().unwrap();
        // TODO: user friendly bound check
        let mut data = [0u8; 8];
        data.copy_from_slice(&self.memory[idx..idx + 8]);
        u64::from_le_bytes(data)
    }

    // NOTE! no-op for now, but we can add functionality for tracing fence
    fn fence_i(&self, _: u16, _: u16) -> SailUnit {
        SAIL_UNIT
    }

    // TODO: no TLB support yet
    fn writemem(&mut self, address: u64, src: u64, bytes: u64, _satp: u64) -> SailUnit {
        const EXIT_ADDR: u64 = 0x10000000;
        const EXIT_CODE: u64 = 0xdeadbeef;

        if address == EXIT_ADDR && src == EXIT_CODE {
            println!("Exit address got written, exit simulator");
            self.finished = true;
            return SAIL_UNIT;
        }

        let idx: usize = address.try_into().unwrap();
        let data = src.to_le_bytes();
        let bytes_count: usize = bytes.try_into().unwrap();
        for i in 0..bytes_count {
            self.memory[idx + i] = data[i];
        }

        SAIL_UNIT
    }

    fn is_reset(&mut self, _: SailUnit) -> bool {
        if self.is_reset {
            self.is_reset = false;
            true
        } else {
            false
        }
    }

    fn get_exception(&self, _: SailUnit) -> u64 {
        0x00000000
    }

    fn exception_raised(&self, _: SailUnit) -> bool {
        false
    }
}

pub struct SimulatorHandler<T>
where
    T: SailImpl,
{
    simulator: Mutex<Option<T>>,
}

impl<T: SailImpl> SimulatorHandler<T> {
    pub const fn new() -> Self {
        Self {
            simulator: Mutex::new(None),
        }
    }

    #[track_caller]
    pub fn init(&self, init_fn: impl FnOnce() -> T) {
        let mut sim = self.simulator.lock().unwrap();
        if sim.is_some() {
            panic!("simulator initialized twice!");
        }
        *sim = Some(init_fn());
    }

    #[track_caller]
    pub fn with<R>(&self, f: impl FnOnce(&mut T) -> R) -> R {
        let mut sim = self.simulator.lock().unwrap();
        let sim = sim.as_mut().expect("simulator is not initialized");
        f(sim)
    }

    #[track_caller]
    pub fn with_optional<R>(&self, f: impl FnOnce(Option<&mut T>) -> R) -> R {
        match self.simulator.lock() {
            Ok(mut sim) => f(sim.as_mut()),

            // treat poisoned mutex as non-initialized
            Err(_) => f(None),
        }
    }

    #[track_caller]
    pub fn dispose(&self) {
        let mut core = self.simulator.lock().unwrap();
        if core.is_none() {
            panic!("CoreHandle is not initialized");
        }
        *core = None;
    }
}

// For each function in [`SailImpl`], we must declare a C function as external function
pub static SIM_HANDLE: SimulatorHandler<Simulator> = SimulatorHandler::new();

#[unsafe(no_mangle)]
unsafe extern "C" fn inst_fetch(pc: MarchBits) -> MarchBits {
    SIM_HANDLE.with(|core| core.inst_fetch(pc))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn readmem(address: u64, satp: u64) -> u64 {
    SIM_HANDLE.with(|core| core.readmem(address, satp))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn writemem(address: u64, data: u64, bytes: u64, satp: u64) -> SailUnit {
    SIM_HANDLE.with(|core| core.writemem(address, data, bytes, satp))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn exception_raised(arg1: SailUnit) -> bool {
    SIM_HANDLE.with(|core| core.exception_raised(arg1))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_exception(arg1: SailUnit) -> u64 {
    SIM_HANDLE.with(|core| core.get_exception(arg1))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn fence_i(pred: u16, succ: u16) -> SailUnit {
    SIM_HANDLE.with(|core| core.fence_i(pred, succ))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn is_reset(arg1: SailUnit) -> bool {
    SIM_HANDLE.with(|core| core.is_reset(arg1))
}

#[unsafe(no_mangle)]
unsafe extern "C" fn print_instr(s: *const c_char) -> SailUnit {
    // TODO: We should use logging functionality here, to be able to disable log when unnecessary
    unsafe {
        let sail_str = CStr::from_ptr(s);
        eprintln!("{}", sail_str.to_string_lossy());
    };
    SAIL_UNIT
}

#[unsafe(no_mangle)]
unsafe extern "C" fn print_reg(s: *const c_char) -> SailUnit {
    // TODO: We should use logging functionality here, to be able to disable log when unnecessary
    unsafe {
        let sail_str = CStr::from_ptr(s);
        eprintln!("{}", sail_str.to_string_lossy());
    };
    SAIL_UNIT
}

#[unsafe(no_mangle)]
unsafe extern "C" fn print_platform(s: *const c_char) -> SailUnit {
    // TODO: We should use logging functionality here, to be able to disable log when unnecessary
    unsafe {
        let sail_str = CStr::from_ptr(s);
        eprintln!("{}", sail_str.to_string_lossy());
    };
    SAIL_UNIT
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x0(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x1(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x2(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x3(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x4(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x5(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x6(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x7(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x8(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x9(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x10(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x11(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x12(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x13(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x14(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x15(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x16(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x17(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x18(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x19(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x20(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x21(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x22(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x23(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x24(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x25(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x26(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x27(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x28(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x29(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x30(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_x31(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mie(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mip(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mideleg(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mstatus(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mtvec(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mcause(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_menvcfg(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_senvcfg(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_satp(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_misa(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mtval(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_mepc(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_stvec(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_sepc(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_scause(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_stval(_: SailUnit) -> u64 {
    0
}

#[unsafe(no_mangle)]
unsafe extern "C" fn get_resetval_medeleg(_: SailUnit) -> u64 {
    0
}
