use std::env;
use std::path::PathBuf;

fn main() {
    println!(
        "cargo::rustc-link-search=native={}",
        env::var("RVMODEL_LIB_DIR").expect("RVMODEL_LIB_DIR should be set")
    );
    println!("cargo:rustc-link-lib=static=rv_model");
    println!("cargo::rerun-if-env-changed=RVMODEL_LIB_DIR");

    println!(
        "cargo::rustc-link-search=native={}",
        env::var("GMP_LIB_DIR").expect("GMP_LIB_DIR should be set")
    );
    println!("cargo:rustc-link-lib=gmp");
    println!("cargo::rerun-if-env-changed=GMP_LIB_DIR");

    let bindings = bindgen::Builder::default()
        .header("sail_expose.h")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        .generate()
        .expect("Unable to generate bindings for file sail_expose.h");

    // Write the bindings to the $OUT_DIR/bindings.rs file.
    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("sail_expose.rs"))
        .expect("Couldn't write bindings!");
    println!("cargo::rerun-if-changed=sail_expose.h");
}
