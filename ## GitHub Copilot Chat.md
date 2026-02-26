## GitHub Copilot Chat

- Extension: 0.37.1 (prod)
- VS Code: 1.109.0 (bdd88df003631aaa0bcbe057cb0a940b80a476fa)
- OS: win32 10.0.19045 x64
- GitHub Account: RayMatews

## Network

User Settings:
```json
  "http.systemCertificatesNode": true,
  "github.copilot.advanced.debug.useElectronFetcher": true,
  "github.copilot.advanced.debug.useNodeFetcher": false,
  "github.copilot.advanced.debug.useNodeFetchFetcher": true
```

Connecting to https://api.github.com:
- DNS ipv4 Lookup: 140.82.114.5 (34 ms)
- DNS ipv6 Lookup: Error (28 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (3 ms)
- Electron fetch (configured): Error (2147 ms): Error: net::ERR_CONNECTION_REFUSED
	at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
	at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (2223 ms): Error: connect ECONNREFUSED 140.82.112.5:443
	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (2738 ms): TypeError: fetch failed
	at node:internal/deps/undici/undici:14900:13
	at process.processTicksAndRejections (node:internal/process/task_queues:105:5)
	at async n._fetch (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4753:26157)
	at async n.fetch (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4753:25805)
	at async d (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4785:190)
	at async vA.h (file:///c:/Users/Client/AppData/Local/Programs/Microsoft%20VS%20Code/bdd88df003/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect ECONNREFUSED 140.82.112.5:443
  	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://api.githubcopilot.com/_ping:
- DNS ipv4 Lookup: 140.82.113.22 (32 ms)
- DNS ipv6 Lookup: Error (82 ms): getaddrinfo ENOTFOUND api.githubcopilot.com
- Proxy URL: None (105 ms)
- Electron fetch (configured): Error (2171 ms): Error: net::ERR_CONNECTION_REFUSED
	at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
	at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (2229 ms): Error: connect ECONNREFUSED 140.82.113.22:443
	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (2254 ms): TypeError: fetch failed
	at node:internal/deps/undici/undici:14900:13
	at process.processTicksAndRejections (node:internal/process/task_queues:105:5)
	at async n._fetch (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4753:26157)
	at async n.fetch (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4753:25805)
	at async d (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4785:190)
	at async vA.h (file:///c:/Users/Client/AppData/Local/Programs/Microsoft%20VS%20Code/bdd88df003/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect ECONNREFUSED 140.82.113.22:443
  	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://copilot-proxy.githubusercontent.com/_ping:
- DNS ipv4 Lookup: 4.249.131.160 (45 ms)
- DNS ipv6 Lookup: Error (35 ms): getaddrinfo ENOTFOUND copilot-proxy.githubusercontent.com
- Proxy URL: None (30 ms)
- Electron fetch (configured): Error (2173 ms): Error: net::ERR_CONNECTION_REFUSED
	at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
	at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (2236 ms): Error: connect ECONNREFUSED 4.249.131.160:443
	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (2256 ms): TypeError: fetch failed
	at node:internal/deps/undici/undici:14900:13
	at process.processTicksAndRejections (node:internal/process/task_queues:105:5)
	at async n._fetch (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4753:26157)
	at async n.fetch (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4753:25805)
	at async d (c:\Users\Client\.vscode\extensions\github.copilot-chat-0.37.1\dist\extension.js:4785:190)
	at async vA.h (file:///c:/Users/Client/AppData/Local/Programs/Microsoft%20VS%20Code/bdd88df003/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect ECONNREFUSED 4.249.131.160:443
  	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://mobile.events.data.microsoft.com: Error (2168 ms): Error: net::ERR_CONNECTION_REFUSED
	at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
	at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
Connecting to https://dc.services.visualstudio.com: Error (2216 ms): Error: net::ERR_CONNECTION_REFUSED
	at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
	at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
Connecting to https://copilot-telemetry.githubusercontent.com/_ping: Error (2283 ms): Error: connect ECONNREFUSED 140.82.114.21:443
	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
Connecting to https://copilot-telemetry.githubusercontent.com/_ping: Error (2232 ms): Error: connect ECONNREFUSED 140.82.114.21:443
	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
Connecting to https://default.exp-tas.com: Error (2254 ms): Error: connect ECONNREFUSED 13.107.5.93:443
	at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Number of system certificates: 103

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).