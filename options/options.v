module options

import connstring

// ClientOptions contains options to configure a Client instance. Each option can be set through setter functions. See
// documentation for each setter function for an explanation of the option.
struct ClientOptions {
	app_name                 *string
	auth                     *Credential
	// auto_encryption_options    *AutoEncryptionOptions
	// connect_timeout           *time.Duration
	compressors              []string
	// dialer                   ContextDialer
	direct                   *bool
	disable_ocsp_endpoint_check *bool
	// heartbeat_interval        *time.Duration
	hosts                    []string
	load_balanced             *bool
	// local_threshold           *time.Duration
	// max_conn_idle_time          *time.Duration
	// max_pool_size              *uint64
	// min_pool_size              *uint64
	// pool_monitor              *event.PoolMonitor
	// monitor                  *event.CommandMonitor
	// server_monitor            *event.ServerMonitor
	// read_concern              *readconcern.ReadConcern
	// read_preference           *readpref.ReadPref
	// registry                 *bsoncodec.Registry
	replica_set               *string
	retry_reads               *bool
	retry_writes              *bool
	server_api_options         *ServerAPIOptions
	// server_selection_timeout   *time.Duration
	// socket_timeout            *time.Duration
	// tls_config                *tls.Config
	// write_concern             *writeconcern.WriteConcern
	// zlib_level                *int
	// zstd_level                *int

	uri string
	cs  *connstring.ConnString

	// AuthenticateToAnything skips server type checks when deciding if authentication is possible.
	//
	// Deprecated: This option is for internal use only and should not be set. It may be changed or removed in any
	// release.
	// authenticate_to_anything *bool

	// Deployment specifies a custom deployment to use for the new Client.
	//
	// Deprecated: This option is for internal use only and should not be set. It may be changed or removed in any
	// release.
	// deployment driver.Deployment
	mut:
	err string
}

// ServerAPIOptions represents options used to configure the API version sent to the server
// when running commands.
//
// Sending a specified server API version causes the server to behave in a manner compatible with that
// API version. It also causes the driver to behave in a manner compatible with the driver’s behavior as
// of the release when the driver first started to support the specified server API version.
//
// The user must specify a ServerAPIVersion if including ServerAPIOptions in their client. That version
// must also be currently supported by the driver. This version of the driver supports API version "1".
struct ServerAPIOptions {
	// ServerAPIVersion  ServerAPIVersion
	strict            *bool
	deprecation_errors *bool
}

// Credential can be used to provide authentication options when configuring a Client.
//
// AuthMechanism: the mechanism to use for authentication. Supported values include "SCRAM-SHA-256", "SCRAM-SHA-1",
// "MONGODB-CR", "PLAIN", "GSSAPI", "MONGODB-X509", and "MONGODB-AWS". This can also be set through the "authMechanism"
// URI option. (e.g. "authMechanism=PLAIN"). For more information, see
// https://docs.mongodb.com/manual/core/authentication-mechanisms/.
//
// AuthMechanismProperties can be used to specify additional configuration options for certain mechanisms. They can also
// be set through the "authMechanismProperites" URI option
// (e.g. "authMechanismProperties=SERVICE_NAME:service,CANONICALIZE_HOST_NAME:true"). Supported properties are:
//
// 1. SERVICE_NAME: The service name to use for GSSAPI authentication. The default is "mongodb".
//
// 2. CANONICALIZE_HOST_NAME: If "true", the driver will canonicalize the host name for GSSAPI authentication. The default
// is "false".
//
// 3. SERVICE_REALM: The service realm for GSSAPI authentication.
//
// 4. SERVICE_HOST: The host name to use for GSSAPI authentication. This should be specified if the host name to use for
// authentication is different than the one given for Client construction.
//
// 4. AWS_SESSION_TOKEN: The AWS token for MONGODB-AWS authentication. This is optional and used for authentication with
// temporary credentials.
//
// The SERVICE_HOST and CANONICALIZE_HOST_NAME properties must not be used at the same time on Linux and Darwin
// systems.
//
// AuthSource: the name of the database to use for authentication. This defaults to "$external" for MONGODB-X509,
// GSSAPI, and PLAIN and "admin" for all other mechanisms. This can also be set through the "authSource" URI option
// (e.g. "authSource=otherDb").
//
// Username: the username for authentication. This can also be set through the URI as a username:password pair before
// the first @ character. For example, a URI for user "user", password "pwd", and host "localhost:27017" would be
// "mongodb://user:pwd@localhost:27017". This is optional for X509 authentication and will be extracted from the
// client certificate if not specified.
//
// Password: the password for authentication. This must not be specified for X509 and is optional for GSSAPI
// authentication.
//
// PasswordSet: For GSSAPI, this must be true if a password is specified, even if the password is the empty string, and
// false if no password is specified, indicating that the password should be taken from the context of the running
// process. For other mechanisms, this field is ignored.
struct Credential {
	auth_mechanism           string
	auth_mechanism_properties map[string]string
	auth_source              string
	username                string
	password                string
	password_set             bool
}

// Validate validates the client options. This method will return the first error found.

fn (c *ClientOptions) validate() {
	if c.err != "" {
		return error(c.err)
	}

	// Direct connections cannot be made if multiple hosts are specified or an SRV URI is used.
	if c.direct != 0 && *c.direct {
		if c.hosts.len > 1 {
			c.err = "a direct connection cannot be made if multiple hosts are specified"
			return error(c.err)
		}
		if c.cs != nil && c.cs.scheme == connstring.scheme_mongo_db_srv {
			c.err = "a direct connection cannot be made if an SRV URI is used"
			return error(c.err)
		}
	}

	// // verify server API version if ServerAPIOptions are passed in.
	if c.server_api_options != 0 {
		c.err = c.server_api_options.ServerAPIVersion.Validate()
	}

	// // Validation for load-balanced mode.
	// if c.LoadBalanced != nil && *c.LoadBalanced {
	// 	if len(c.Hosts) > 1 {
	// 		c.err = internal.ErrLoadBalancedWithMultipleHosts
	// 	}
	// 	if c.ReplicaSet != nil {
	// 		c.err = internal.ErrLoadBalancedWithReplicaSet
	// 	}
	// 	if c.Direct != nil {
	// 		c.err = internal.ErrLoadBalancedWithDirectConnection
	// 	}
	// }
}