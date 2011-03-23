component extends="cf-compendium.inc.resource.base.base" {
	public component function init(required struct transport, required struct datasource, required component task) {
		super.init();
		
		variables.transport = arguments.transport;
		variables.datasource = arguments.datasource;
		variables.task = arguments.task;
		variables.services = arguments.transport.theRequest.managers.singleton.getManagerService();
		
		return this;
	}
	
	public void function execute(struct options = {}) {
		// base does nothing
	}
	
	public component function getModel(string plugin = '', string model = '') {
		local.models = variables.transport.theRequest.managers.singleton.getManagerModel();
		
		return local.models.get(arguments.plugin, arguments.model);
	}
	
	public component function getView(required string plugin, required string view) {
		local.views = variables.transport.theRequest.managers.singleton.getViewModel();
		
		return local.views.get(arguments.plugin, arguments.view);
	}
	
	public component function getPluginObserver( required string plugin, required string observer ) {
		// Get the plugin singleton
		local.plugin = variables.transport.theApplication.managers.plugin.get(arguments.plugin);
		
		// Get the observer manager for the plugin
		local.observerManager = local.plugin.getObserver();
		
		// Get the specific observer
		local.observer = local.observerManager.get(arguments.observer);
		
		return local.observer;
	}
}
