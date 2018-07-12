// Install https://marketplace.visualstudio.com/items?itemName=humao.rest-client extension to vscode
// Do command + , and paste these settings there
var settings = {
	"rest-client.environmentVariables": {
        "projectplay-wp-live": {
			"protocol": "http",
			"host": "jerseycoder.webfactional.com",
			"port": ":80",
			"endpoint": ""
        },
        "projectplay-py-local": {
			"protocol": "http",
			"host": "localhost",
			"port": ":3000",
			"endpoint": ""
		}
	}
}