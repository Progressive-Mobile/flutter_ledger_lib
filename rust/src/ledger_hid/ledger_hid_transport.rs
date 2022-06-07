use ledger_transport::APDUCommand;
use ledger_transport_hid::{hidapi::HidApi, TransportNativeHID};

pub struct LedgerHidTransport {
    transport: TransportNativeHID,
    _hid_api: HidApi,
}

impl LedgerHidTransport {
    pub fn new() -> Result<Self, String> {
        let hid_api = HidApi::new().unwrap();
        let transport = TransportNativeHID::new(&hid_api).unwrap();

        Ok(Self {
            transport: transport,
            _hid_api: hid_api,
        })
    }

    pub fn exchange(
        &self,
        cla: u8,
        ins: u8,
        p1: u8,
        p2: u8,
        data: Vec<u8>,
    ) -> Result<Vec<u8>, String> {
        let command = APDUCommand {
            cla: cla,
            ins: ins,
            p1: p1,
            p2: p2,
            data: data,
        };

        let result = self.transport.exchange(&command);
        match result {
            Ok(answer) => Ok(answer.apdu_data().to_vec()),
            Err(err) => Err(err.to_string()),
        }
    }
}
