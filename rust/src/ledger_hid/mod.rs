mod ledger_hid_transport;

use std::{
    ffi::c_void,
    os::raw::{c_char, c_int, c_longlong},
    sync::Arc,
};

use crate::{
    models::{HandleError, MatchResult, ToCStringPtr, ToStringFromPtr},
    runtime, send_to_result_port, RUNTIME,
};

use self::ledger_hid_transport::LedgerHidTransport;

#[no_mangle]
pub unsafe extern "C" fn create_ledger_transport() -> *mut c_void {
    fn internal_fn() -> Result<u64, String> {
        let transport = LedgerHidTransport::new().handle_error()?;

        let ptr = Box::into_raw(Box::new(Arc::new(transport))) as u64;

        Ok(ptr)
    }

    internal_fn().match_result()
}

#[no_mangle]
pub unsafe extern "C" fn ledger_transport_clone_ptr(ptr: *mut c_void) -> *mut c_void {
    Arc::into_raw(Arc::clone(&*(ptr as *mut Arc<LedgerHidTransport>))) as *mut c_void
}

#[no_mangle]
pub unsafe extern "C" fn ledger_transport_free_ptr(ptr: *mut c_void) {
    Box::from_raw(ptr as *mut Arc<LedgerHidTransport>);
}

#[no_mangle]
pub unsafe extern "C" fn ledger_exchange(
    result_port: c_longlong,
    transport: *mut c_void,
    cla: c_int,
    ins: c_int,
    p1: c_int,
    p2: c_int,
    data: *mut c_char,
) {
    let transport = Arc::from_raw(transport as *mut LedgerHidTransport);
    let data = data.to_string_from_ptr();

    runtime!().spawn(async move {
        fn internal_fn(
            transport: Arc<LedgerHidTransport>,
            cla: c_int,
            ins: c_int,
            p1: c_int,
            p2: c_int,
            data: String,
        ) -> Result<u64, String> {
            let data = serde_json::from_str::<Vec<u8>>(&data)
                .handle_error()?
                .into_iter()
                .collect::<Vec<_>>();

            let result = transport
                .exchange(cla as u8, ins as u8, p1 as u8, p2 as u8, data)
                .handle_error()?;

            let result = serde_json::to_string(&result)
                .handle_error()?
                .to_cstring_ptr() as u64;

            Ok(result)
        }

        let result = internal_fn(transport, cla, ins, p1, p2, data).match_result();

        send_to_result_port(result_port, result);
    });
}
