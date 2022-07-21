
void free_cstring(char *ptr);

void lb_store_dart_post_cobject(void *ptr);

void *nt_cstring_to_void_ptr(char *ptr);

void nt_free_cstring(char *ptr);

void get_ledger_devices(long long result_port);

char *create_ledger_transport(const char *path);

void *ledger_transport_clone_ptr(void *ptr);

void ledger_transport_free_ptr(void *ptr);

void ledger_exchange(long long result_port,
                     void *transport,
                     int cla,
                     int ins,
                     int p1,
                     int p2,
                     char *data);
