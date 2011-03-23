component extends="cf-compendium.inc.resource.base.base" {
	public component function init(required struct transport, required struct datasource, required component task) {
		super.init();
		
		variables.transport = arguments.transport;
		variables.datasource = arguments.datasource;
		variables.task = arguments.task;
		variables.services = arguments.transport.theRequest.managers.singleton.getManagerService();
		
		return this;
	}
	
	public void function execute() {
		// base does nothing
	}
}
