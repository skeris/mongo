module client

import context
import rand

import options

// Client is a handle representing a pool of connections to a MongoDB deployment. It is safe for concurrent use by
// multiple goroutines.
//
// The Client type opens and closes connections automatically and maintains a pool of idle connections. For
// connection pool configuration options, see documentation for the ClientOptions type in the mongo/options package.

struct Client {
	// id              uuid.UUID
	// topologyOptions []topology.Option
	// deployment      driver.Deployment
	// connString      connstring.ConnString
	// localThreshold  time.Duration
	retryWrites     bool
	retryReads      bool
	// clock           *session.ClusterClock
	// readPreference  *readpref.ReadPref
	// readConcern     *readconcern.ReadConcern
	// writeConcern    *writeconcern.WriteConcern
	// registry        *bsoncodec.Registry
	// marshaller      BSONAppender
	// monitor         *event.CommandMonitor
	// serverAPI       *driver.ServerAPIOptions
	// serverMonitor   *event.ServerMonitor
	// sessionPool     *session.Pool

	// client-side encryption fields
	// keyVaultClientFLE *Client
	// keyVaultCollFLE   *Collection
	// mongocryptdFLE    *mcryptClient
	// cryptFLE          *driver.Crypt
	// metadataClientFLE *Client
	// internalClientFLE *Client
}

// Connect creates a new Client and then initializes it using the Connect method. This is equivalent to calling
// NewClient followed by Client.Connect.
//
// When creating an options.ClientOptions, the order the methods are called matters. Later Set*
// methods will overwrite the values from previous Set* method invocations. This includes the
// ApplyURI method. This allows callers to determine the order of precedence for option
// application. For instance, if ApplyURI is called before SetAuth, the Credential from
// SetAuth will overwrite the values from the connection string. If ApplyURI is called
// after SetAuth, then its values will overwrite those from SetAuth.
//
// The opts parameter is processed using options.MergeClientOptions, which will overwrite entire
// option fields of previous options, there is no partial overwriting. For example, if Username is
// set in the Auth field for the first option, and Password is set for the second but with no
// Username, after the merge the Username field will be empty.
//
// The NewClient function does not do any I/O and returns an error if the given options are invalid.
// The Client.Connect method starts background goroutines to monitor the state of the deployment and does not do
// any I/O in the main goroutine to prevent the main goroutine from blocking. Therefore, it will not error if the
// deployment is down.
//
// The Client.Ping method can be used to verify that the deployment is successfully connected and the
// Client was correctly configured.
fn connect(ctx context.Context, opts *options.ClientOptions) (*Client, error) {
	c, err := NewClient(opts)
	if err != nil {
		return nil, err
	}
	err = c.Connect(ctx)
	if err != nil {
		return nil, err
	}
	return c, nil
}

// NewClient creates a new client to connect to a deployment specified by the uri.
//
// When creating an options.ClientOptions, the order the methods are called matters. Later Set*
// methods will overwrite the values from previous Set* method invocations. This includes the
// ApplyURI method. This allows callers to determine the order of precedence for option
// application. For instance, if ApplyURI is called before SetAuth, the Credential from
// SetAuth will overwrite the values from the connection string. If ApplyURI is called
// after SetAuth, then its values will overwrite those from SetAuth.
//
// The opts parameter is processed using options.MergeClientOptions, which will overwrite entire
// option fields of previous options, there is no partial overwriting. For example, if Username is
// set in the Auth field for the first option, and Password is set for the second but with no
// Username, after the merge the Username field will be empty.
func NewClient(opts *options.ClientOptions) (*Client, error) {

	id := rand.uuid_v4()
	client := &Client{id: id}

	err = client.configure(opts)
	if err != nil {
		return nil, err
	}

	// if client.deployment == nil {
	// 	client.deployment, err = topology.New(client.topologyOptions...)
	// 	if err != nil {
	// 		return nil, replaceErrors(err)
	// 	}
	// }
	return client, nil
}

func (c *Client) configure(opts *options.ClientOptions) {
	opts.validate() or {
		return err
	}

	// var connOpts []topology.ConnectionOption
	// var serverOpts []topology.ServerOption
	// var topologyOpts []topology.Option

	// // TODO(GODRIVER-814): Add tests for topology, server, and connection related options.

	// // ServerAPIOptions need to be handled early as other client and server options below reference
	// // c.serverAPI and serverOpts.serverAPI.
	// if opts.ServerAPIOptions != nil {
	// 	// convert passed in options to driver form for client.
	// 	c.serverAPI = convertToDriverAPIOptions(opts.ServerAPIOptions)

	// 	serverOpts = append(serverOpts, topology.WithServerAPI(func(*driver.ServerAPIOptions) *driver.ServerAPIOptions {
	// 		return c.serverAPI
	// 	}))
	// }

	// // ClusterClock
	// c.clock = new(session.ClusterClock)

	// // Pass down URI so topology can determine whether or not SRV polling is required
	// topologyOpts = append(topologyOpts, topology.WithURI(func(uri string) string {
	// 	return opts.GetURI()
	// }))

	// // AppName
	// var appName string
	// if opts.AppName != nil {
	// 	appName = *opts.AppName

	// 	serverOpts = append(serverOpts, topology.WithServerAppName(func(string) string {
	// 		return appName
	// 	}))
	// }
	// // Compressors & ZlibLevel
	// var comps []string
	// if len(opts.Compressors) > 0 {
	// 	comps = opts.Compressors

	// 	connOpts = append(connOpts, topology.WithCompressors(
	// 		func(compressors []string) []string {
	// 			return append(compressors, comps...)
	// 		},
	// 	))

	// 	for _, comp := range comps {
	// 		switch comp {
	// 		case "zlib":
	// 			connOpts = append(connOpts, topology.WithZlibLevel(func(level *int) *int {
	// 				return opts.ZlibLevel
	// 			}))
	// 		case "zstd":
	// 			connOpts = append(connOpts, topology.WithZstdLevel(func(level *int) *int {
	// 				return opts.ZstdLevel
	// 			}))
	// 		}
	// 	}

	// 	serverOpts = append(serverOpts, topology.WithCompressionOptions(
	// 		func(opts ...string) []string { return append(opts, comps...) },
	// 	))
	// }

	// var loadBalanced bool
	// if opts.LoadBalanced != nil {
	// 	loadBalanced = *opts.LoadBalanced
	// }

	// // Handshaker
	// var handshaker = func(driver.Handshaker) driver.Handshaker {
	// 	return operation.NewIsMaster().AppName(appName).Compressors(comps).ClusterClock(c.clock).
	// 		ServerAPI(c.serverAPI).LoadBalanced(loadBalanced)
	// }
	// // Auth & Database & Password & Username
	// if opts.Auth != nil {
	// 	cred := &auth.Cred{
	// 		Username:    opts.Auth.Username,
	// 		Password:    opts.Auth.Password,
	// 		PasswordSet: opts.Auth.PasswordSet,
	// 		Props:       opts.Auth.AuthMechanismProperties,
	// 		Source:      opts.Auth.AuthSource,
	// 	}
	// 	mechanism := opts.Auth.AuthMechanism

	// 	if len(cred.Source) == 0 {
	// 		switch strings.ToUpper(mechanism) {
	// 		case auth.MongoDBX509, auth.GSSAPI, auth.PLAIN:
	// 			cred.Source = "$external"
	// 		default:
	// 			cred.Source = "admin"
	// 		}
	// 	}

	// 	authenticator, err := auth.CreateAuthenticator(mechanism, cred)
	// 	if err != nil {
	// 		return err
	// 	}

	// 	handshakeOpts := &auth.HandshakeOptions{
	// 		AppName:       appName,
	// 		Authenticator: authenticator,
	// 		Compressors:   comps,
	// 		ClusterClock:  c.clock,
	// 		ServerAPI:     c.serverAPI,
	// 		LoadBalanced:  loadBalanced,
	// 	}
	// 	if mechanism == "" {
	// 		// Required for SASL mechanism negotiation during handshake
	// 		handshakeOpts.DBUser = cred.Source + "." + cred.Username
	// 	}
	// 	if opts.AuthenticateToAnything != nil && *opts.AuthenticateToAnything {
	// 		// Authenticate arbiters
	// 		handshakeOpts.PerformAuthentication = func(serv description.Server) bool {
	// 			return true
	// 		}
	// 	}

	// 	handshaker = func(driver.Handshaker) driver.Handshaker {
	// 		return auth.Handshaker(nil, handshakeOpts)
	// 	}
	// }
	// connOpts = append(connOpts, topology.WithHandshaker(handshaker))
	// // ConnectTimeout
	// if opts.ConnectTimeout != nil {
	// 	serverOpts = append(serverOpts, topology.WithHeartbeatTimeout(
	// 		func(time.Duration) time.Duration { return *opts.ConnectTimeout },
	// 	))
	// 	connOpts = append(connOpts, topology.WithConnectTimeout(
	// 		func(time.Duration) time.Duration { return *opts.ConnectTimeout },
	// 	))
	// }
	// // Dialer
	// if opts.Dialer != nil {
	// 	connOpts = append(connOpts, topology.WithDialer(
	// 		func(topology.Dialer) topology.Dialer { return opts.Dialer },
	// 	))
	// }
	// // Direct
	// if opts.Direct != nil && *opts.Direct {
	// 	topologyOpts = append(topologyOpts, topology.WithMode(
	// 		func(topology.MonitorMode) topology.MonitorMode { return topology.SingleMode },
	// 	))
	// }
	// // HeartbeatInterval
	// if opts.HeartbeatInterval != nil {
	// 	serverOpts = append(serverOpts, topology.WithHeartbeatInterval(
	// 		func(time.Duration) time.Duration { return *opts.HeartbeatInterval },
	// 	))
	// }
	// // Hosts
	// hosts := []string{"localhost:27017"} // default host
	// if len(opts.Hosts) > 0 {
	// 	hosts = opts.Hosts
	// }
	// topologyOpts = append(topologyOpts, topology.WithSeedList(
	// 	func(...string) []string { return hosts },
	// ))
	// // LocalThreshold
	// c.localThreshold = defaultLocalThreshold
	// if opts.LocalThreshold != nil {
	// 	c.localThreshold = *opts.LocalThreshold
	// }
	// // MaxConIdleTime
	// if opts.MaxConnIdleTime != nil {
	// 	connOpts = append(connOpts, topology.WithIdleTimeout(
	// 		func(time.Duration) time.Duration { return *opts.MaxConnIdleTime },
	// 	))
	// }
	// // MaxPoolSize
	// if opts.MaxPoolSize != nil {
	// 	serverOpts = append(
	// 		serverOpts,
	// 		topology.WithMaxConnections(func(uint64) uint64 { return *opts.MaxPoolSize }),
	// 	)
	// }
	// // MinPoolSize
	// if opts.MinPoolSize != nil {
	// 	serverOpts = append(
	// 		serverOpts,
	// 		topology.WithMinConnections(func(uint64) uint64 { return *opts.MinPoolSize }),
	// 	)
	// }
	// // PoolMonitor
	// if opts.PoolMonitor != nil {
	// 	serverOpts = append(
	// 		serverOpts,
	// 		topology.WithConnectionPoolMonitor(func(*event.PoolMonitor) *event.PoolMonitor { return opts.PoolMonitor }),
	// 	)
	// }
	// // Monitor
	// if opts.Monitor != nil {
	// 	c.monitor = opts.Monitor
	// 	connOpts = append(connOpts, topology.WithMonitor(
	// 		func(*event.CommandMonitor) *event.CommandMonitor { return opts.Monitor },
	// 	))
	// }
	// // ServerMonitor
	// if opts.ServerMonitor != nil {
	// 	c.serverMonitor = opts.ServerMonitor
	// 	serverOpts = append(
	// 		serverOpts,
	// 		topology.WithServerMonitor(func(*event.ServerMonitor) *event.ServerMonitor { return opts.ServerMonitor }),
	// 	)

	// 	topologyOpts = append(
	// 		topologyOpts,
	// 		topology.WithTopologyServerMonitor(func(*event.ServerMonitor) *event.ServerMonitor { return opts.ServerMonitor }),
	// 	)
	// }
	// // ReadConcern
	// c.readConcern = readconcern.New()
	// if opts.ReadConcern != nil {
	// 	c.readConcern = opts.ReadConcern
	// }
	// // ReadPreference
	// c.readPreference = readpref.Primary()
	// if opts.ReadPreference != nil {
	// 	c.readPreference = opts.ReadPreference
	// }
	// // Registry
	// c.registry = bson.DefaultRegistry
	// if opts.Registry != nil {
	// 	c.registry = opts.Registry
	// }
	// // ReplicaSet
	// if opts.ReplicaSet != nil {
	// 	topologyOpts = append(topologyOpts, topology.WithReplicaSetName(
	// 		func(string) string { return *opts.ReplicaSet },
	// 	))
	// }
	// // RetryWrites
	// c.retryWrites = true // retry writes on by default
	// if opts.RetryWrites != nil {
	// 	c.retryWrites = *opts.RetryWrites
	// }
	// c.retryReads = true
	// if opts.RetryReads != nil {
	// 	c.retryReads = *opts.RetryReads
	// }
	// // ServerSelectionTimeout
	// if opts.ServerSelectionTimeout != nil {
	// 	topologyOpts = append(topologyOpts, topology.WithServerSelectionTimeout(
	// 		func(time.Duration) time.Duration { return *opts.ServerSelectionTimeout },
	// 	))
	// }
	// // SocketTimeout
	// if opts.SocketTimeout != nil {
	// 	connOpts = append(
	// 		connOpts,
	// 		topology.WithReadTimeout(func(time.Duration) time.Duration { return *opts.SocketTimeout }),
	// 		topology.WithWriteTimeout(func(time.Duration) time.Duration { return *opts.SocketTimeout }),
	// 	)
	// }
	// // TLSConfig
	// if opts.TLSConfig != nil {
	// 	connOpts = append(connOpts, topology.WithTLSConfig(
	// 		func(*tls.Config) *tls.Config {
	// 			return opts.TLSConfig
	// 		},
	// 	))
	// }
	// // WriteConcern
	// if opts.WriteConcern != nil {
	// 	c.writeConcern = opts.WriteConcern
	// }
	// // AutoEncryptionOptions
	// if opts.AutoEncryptionOptions != nil {
	// 	if err := c.configureAutoEncryption(opts); err != nil {
	// 		return err
	// 	}
	// }

	// // OCSP cache
	// ocspCache := ocsp.NewCache()
	// connOpts = append(
	// 	connOpts,
	// 	topology.WithOCSPCache(func(ocsp.Cache) ocsp.Cache { return ocspCache }),
	// )

	// // Disable communication with external OCSP responders.
	// if opts.DisableOCSPEndpointCheck != nil {
	// 	connOpts = append(
	// 		connOpts,
	// 		topology.WithDisableOCSPEndpointCheck(func(bool) bool { return *opts.DisableOCSPEndpointCheck }),
	// 	)
	// }

	// // LoadBalanced
	// if opts.LoadBalanced != nil {
	// 	topologyOpts = append(
	// 		topologyOpts,
	// 		topology.WithLoadBalanced(func(bool) bool { return *opts.LoadBalanced }),
	// 	)
	// 	serverOpts = append(
	// 		serverOpts,
	// 		topology.WithServerLoadBalanced(func(bool) bool { return *opts.LoadBalanced }),
	// 	)
	// 	connOpts = append(
	// 		connOpts,
	// 		topology.WithConnectionLoadBalanced(func(bool) bool { return *opts.LoadBalanced }),
	// 	)
	// }

	// serverOpts = append(
	// 	serverOpts,
	// 	topology.WithClock(func(*session.ClusterClock) *session.ClusterClock { return c.clock }),
	// 	topology.WithConnectionOptions(func(...topology.ConnectionOption) []topology.ConnectionOption { return connOpts }),
	// )
	// c.topologyOptions = append(topologyOpts, topology.WithServerOptions(
	// 	func(...topology.ServerOption) []topology.ServerOption { return serverOpts },
	// ))

	// // Deployment
	// if opts.Deployment != nil {
	// 	// topology options: WithSeedlist and WithURI
	// 	// server options: WithClock and WithConnectionOptions
	// 	if len(serverOpts) > 2 || len(topologyOpts) > 2 {
	// 		return errors.New("cannot specify topology or server options with a deployment")
	// 	}
	// 	c.deployment = opts.Deployment
	// }

	// return nil
}