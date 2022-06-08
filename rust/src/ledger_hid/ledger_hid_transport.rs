use ledger_transport::APDUCommand;
use ledger_transport_hid::{hidapi::HidApi, TransportNativeHID};
use serde::{Deserialize, Serialize};

#[derive(Clone, Default, Serialize, Deserialize)]
pub struct LedgerAnswer {
    data: Vec<u8>,
    status_word: u16,
}
pub struct LedgerHidTransport {
    transport: TransportNativeHID,
    _hid_api: HidApi,
}

impl LedgerHidTransport {
    pub fn new() -> Result<Self, String> {
        let hid_api = HidApi::new();

        match hid_api {
            Ok(hid_api) => {
                let transport = TransportNativeHID::new(&hid_api);
                match transport {
                    Ok(transport) => Ok(Self {
                        transport: transport,
                        _hid_api: hid_api,
                    }),
                    Err(err) => Err(err.to_string()),
                }
            }
            Err(err) => Err(err.to_string()),
        }
    }

    pub fn exchange(
        &self,
        cla: u8,
        ins: u8,
        p1: u8,
        p2: u8,
        data: Vec<u8>,
    ) -> Result<LedgerAnswer, String> {
        let command = APDUCommand {
            cla: cla,
            ins: ins,
            p1: p1,
            p2: p2,
            data: data,
        };

        let result = self.transport.exchange(&command);
        match result {
            Ok(answer) => Ok(LedgerAnswer {
                data: answer.apdu_data().to_vec(),
                status_word: answer.retcode(),
            }),
            Err(err) => Err(err.to_string()),
        }
    }
}
