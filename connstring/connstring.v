module connstring

// Scheme constants
const (
	scheme_mongo_db    = "mongodb"
	scheme_mongo_db_srv = "mongodb+srv"
)

struct ConnString  {
	original                           string
	app_name                            string
	auth_mechanism                      string
	auth_mechanism_properties            map[string]string
	auth_mechanism_properties_set         bool
	auth_source                         string
	auth_source_set                      bool
	compressors                        []string
	// Connect                            ConnectMode
	connect_set                         bool
	direct_connection                   bool
	direct_connection_set                bool
	// ConnectTimeout                     time.Duration
	connect_timeout_set                  bool
	database                           string
	// heartbeat_interval                  time.Duration
	heartbeat_interval_set               bool
	hosts                              []string
	j                                  bool
	j_set                               bool
	load_balanced                       bool
	load_balanced_set                    bool
	// local_threshold                     time.Duration
	local_threshold_set                  bool
	// max_conn_idle_time                    time.Duration
	max_conn_idle_time_set                 bool
	max_pool_size                        u64
	max_pool_size_set                     bool
	min_pool_size                        u64
	min_pool_size_set                     bool
	password                           string
	password_set                        bool
	read_concern_level                   string
	read_preference                     string
	read_preference_tag_sets              []map[string]string
	retry_writes                        bool
	retry_writes_set                     bool
	retry_reads                         bool
	retry_reads_set                      bool
	// max_staleness                       time.Duration
	max_staleness_set                    bool
	replica_set                         string
	scheme                             string
	// server_selection_timeout             time.Duration
	server_selection_timeout_set          bool
	// socketTimeout                      time.Duration
	socket_timeout_set                   bool
	ssl                                bool
	ssl_set                             bool
	ssl_client_certificate_key_file        string
	ssl_client_certificate_key_file_set     bool
	// SSLClientCertificateKeyPassword    func() string
	ssl_client_certificate_key_password_set bool
	ssl_certificate_file                 string
	ssl_certificate_file_set              bool
	ssl_private_key_file                  string
	ssl_private_key_file_set               bool
	ssl_insecure                        bool
	ssl_insecure_set                     bool
	ssl_ca_file                          string
	ssl_ca_file_set                       bool
	ssl_disable_ocsp_endpoint_check        bool
	ssl_disable_ocsp_endpoint_check_set     bool
	w_string                            string
	w_number                            int
	w_number_set                         bool
	username                           string
	username_set                        bool
	zlib_level                          int
	zlib_level_set                       bool
	zstd_level                          int
	zstd_level_set                       bool

	// WTimeout              time.Duration
	w_timeout_set           bool
	w_timeout_set_from_option bool

	options        map[string][]string
	unknown_options map[string][]string
}