
void ll_store_dart_post_cobject(void *ptr);

void *ll_cstring_to_void_ptr(char *ptr);

void ll_free_cstring(char *ptr);

void ll_get_ledger_devices(long long result_port);

char *ll_create_ledger_transport(const char *path);

void ll_ledger_transport_free_ptr(void *ptr);

void ll_ledger_exchange(long long result_port,
                        void *transport,
                        int cla,
                        int ins,
                        int p1,
                        int p2,
                        char *data);
