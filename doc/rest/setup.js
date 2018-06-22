// Install https://marketplace.visualstudio.com/items?itemName=humao.rest-client extension to vscode
// Do command + , and paste these settings there
var settings = {
	"rest-client.environmentVariables": {
		"pp-dev": {
			"protocol": "http",
			"host": "localhost",
			"port": ":3000",
			"endpoint": ""
		},
		"pp-py-live": {
			"protocol": "http",
			"host": "jerseycoder.webfactional.com",
			"port": "",
			"endpoint": ""
		},
		"pp-wp-live": {
			"protocol": "http",
			"host": "jerseycoder.webfactional.com",
			"port": "",
			"endpoint": ""
		}
	}
}