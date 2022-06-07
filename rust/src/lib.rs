mod ledger_hid;
mod models;

use allo_isolate::{
    ffi::{DartCObject, DartPort},
    Isolate,
};
use lazy_static::lazy_static;
use std::{
    ffi::c_void,
    intrinsics::transmute,
    io,
    os::raw::{c_char, c_longlong, c_ulonglong},
};
use tokio::runtime::{Builder, Runtime};

use models::{ExecutionResult, ToStringFromPtr};

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread()
        .enable_all()
        .thread_name("flutter_ledger_lib")
        .build();
}

#[macro_export]
macro_rules! runtime {
    () => {
        RUNTIME.as_ref().unwrap()
    };
}

#[no_mangle]
pub unsafe extern "C" fn free_execution_result(ptr: *mut c_void) {
    Box::from_raw(ptr as *mut ExecutionResult);
}

#[no_mangle]
pub unsafe extern "C" fn free_cstring(ptr: *mut c_char) {
    ptr.to_string_from_ptr();
}

#[no_mangle]
pub unsafe extern "C" fn lb_store_dart_post_cobject(ptr: *mut c_void) {
    let ptr = transmute::<
        *mut c_void,
        unsafe extern "C" fn(port_id: DartPort, message: *mut DartCObject) -> bool,
    >(ptr);

    allo_isolate::store_dart_post_cobject(ptr);
}

fn send_to_result_port(port: c_longlong, result: *mut c_void) {
    Isolate::new(port).post(result as c_ulonglong);
}
