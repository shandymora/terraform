/*
	Retrieve secrets from keyvault and return back to terraform
*/
var https       = require('https');
var url         = require('url');

var defaultKeyVault = "example-keyvault"
var apiVersion = "2016-10-01"

var stdin = process.stdin,
    stdout = process.stdout,
    inputChunks = [];

var parsedData;
var creds = {};


// Check for Terraform environment variables

if ('TF_VAR_keyVaultSubscriptionId' in process.env) { 
    var subscriptionId = process.env.TF_VAR_keyVaultSubscriptionId;
} else {
    console.log('Subscription ID environment variable, TF_VAR_keyVaultSubscriptionId not set');
    process.exit(1);
}
if ('TF_VAR_keyVaultName' in process.env) { 
    var keyVaultName = process.env.TF_VAR_keyVaultName;
} else {
    var keyVaultName = defaultKeyVault;
}
if ('TF_VAR_clientId' in process.env) { 
    var clientId = process.env.TF_VAR_clientId;
} else {
    console.log('Client ID environment variable, TF_VAR_clientId not set');
    process.exit(1);
}
if ('TF_VAR_clientSecret' in process.env) { 
    var clientSecret = process.env.TF_VAR_clientSecret;
} else {
    console.log('Client Secret environment variable, TF_VAR_clientSecret not set');
    process.exit(1);
}
if ('TF_VAR_tenant' in process.env) { 
    var tenantId = process.env.TF_VAR_tenantId;
} else {
    console.log('Tenant environment variable, TF_VAR_tenant not set');
    process.exit(1);
}

// Read from stdin
stdin.resume();
stdin.setEncoding('utf8');

stdin.on('data', function (chunk) {
    inputChunks.push(chunk);
});

// Parse input as JSON
stdin.on('end', function () {
    var inputJSON = inputChunks.join();
    
    try {
        inputData = JSON.parse(inputJSON);
    } catch (e) {
        console.log('Invalid input JSON');
        process.exit(1);
    }
    getCreds( (error) => {
        if (error) { console.log('Unable to authenticate with Azure'); process.exit(1); }
        else {
            validate_input(inputData);
        }
    });
});

function validate_input(inputData) {
    var outputData = {};

    inputCount = 0;
    Object.keys(inputData).forEach(  (key) => {
        process_secret(inputData, key, () => {

            inputCount +=1;
            if (inputCount == Object.keys(inputData).length) {
                output_secret(JSON.stringify(outputData));
            }
        });
    });

	function process_secret(inputData, key, done) {

		var secret = inputData[key];
        get_secret_value(secret, (error, secretValue) => {
            if (error) {
                outputData[key] = {};
            }
            else {
                outputData[key] = secretValue;
                done();
            }
        });
	}
}


function get_secret_value(secret, done) {
    // Get secret value text
    httpsConn({
        hostname: keyVaultName+'.vault.azure.net',
        path: '/secrets/'+secret+'?api-version='+apiVersion,
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer "+creds.access_token
        }
    }, (err, status, data) => {
        if (err) {
            console.log('Get secret value HTTPS Request error', err, status, data);
            done(true);
        } else {
            try {
                var parsedData = JSON.parse(data);
            } catch (error) {
                console.log('Invald secret value JSON data'); 
                done(true, null);
            }
            if(parsedData) {
                done(false, parsedData.value);
            }
        }
    });
}

function output_secret(outputJSON) {
    // Output secret as JSON
    stdout.write(outputJSON);
    stdout.write('\n');
}


function getCreds(done) {
    // Get a new token
    var loginPath = "/"+tenantId+"/oauth2/token";
    var requestBody = "grant_type=client_credentials"+"&client_id="+clientId+"&client_secret="+clientSecret+"&resource=https://vault.azure.net";

    httpsConn({
        hostname: "login.windows.net",
        path: loginPath,
        method: 'POST',
        postData: requestBody,
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': Buffer.byteLength(requestBody)
        }
    }, (err, status, data) => {
        if (err) {
            console.log('Get Token HTTPS Request error', err, status, data);
            done(true);
        } else {

            try {
                creds = JSON.parse(data);
            } catch (e) {
                console.log('Invald Credentials token JSON data');
                done(true);
            }

            done(false);
        }
    });
}

function httpsConn (options, done) {

    var conn_options = {
        hostname: 'localhost',
        path: '/',
        method: 'GET',
        headers: {},
        setEncoding: 'utf8',
        queryString: '',
        showHeaders: false,
        connTimeout: 10000
    };

    conn_options = merge(conn_options, options);

    if (conn_options.queryString !== '') {
        conn_options.path = conn_options.path + conn_options.queryString;
    }

    try {
        var req = https.request(conn_options, function(res) {
            var data = '';

            res.setEncoding(conn_options.setEncoding);
            if (conn_options.showHeaders) {
                    console.log('RESPONSE-HEADERS: '+JSON.stringify(res.headers,undefined,2));
            }

            res.on('data', function (chunk) {
                    data += chunk;
            });

            res.on('end', function() {
            done(false, res.statusCode, data);
            });
        });

        req.on('socket', function (socket) {
            socket.setTimeout(conn_options.connTimeout);
            socket.on('timeout', function() {
                req.abort();
            });
        });

        req.on('error', function(e) {
            done(true, null, e);
        });

        if ('postData' in conn_options) {
            req.write(conn_options.postData);
        }
        req.end();

    } catch(error) {
        done(true, null, error);
    }
}

function merge() {
    var destination = {},
    sources = [].slice.call( arguments, 0 );
        sources.forEach(function( source ) {
        var prop;
        for ( prop in source ) {
            if ( prop in destination && Array.isArray( destination[ prop ] ) ) {
                // Concat Arrays
                destination[ prop ] = destination[ prop ].concat( source[ prop ] );
            } else if ( prop in destination && typeof destination[ prop ] === "object" ) {
                // Merge Objects
                destination[ prop ] = merge( destination[ prop ], source[ prop ] );
            } else {
                // Set new values
                destination[ prop ] = source[ prop ];
            }
        }
        });
    return destination;
}
