fn main() {
    println!("cargo:rustc-link-search=native=C:\\Users\\GG\\.sdk\\OpenBLAS\\lib");
    println!("cargo:rustc-link-lib=dylib=blas");
}