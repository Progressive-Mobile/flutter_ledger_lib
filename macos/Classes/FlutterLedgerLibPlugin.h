
void free_execution_result(void *ptr);

void free_cstring(char *ptr);

void lb_store_dart_post_cobject(void *ptr);

void *create_ledger_transport(void);

void *ledger_transport_clone_ptr(void *ptr);

void ledger_transport_free_ptr(void *ptr);

void ledger_exchange(long long result_port,
                     void *transport,
                     int cla,
                     int ins,
                     int p1,
                     int p2,
                     char *data);