component extends="algid.inc.resource.base.manager" {
	public component function init( required struct transport ) {
		super.init();
		
		variables.transport = arguments.transport;
		variables.datasource = variables.transport.theApplication.managers.singleton.getApplication().getDSUpdate();
		
		return this;
	}
	
	public component function get(required string plugin, required string cron, required component task) {
		var hasTransient = '';
		var temp = '';
		
		arguments.cron = ucase(left(arguments.cron, 1)) & right(arguments.cron, len(arguments.cron) - 1);
		
		// Use the transient definitions over the convention
		if (variables.transport.theApplication.factories.transient['hasCron' & arguments.cron & 'for' & arguments.plugin]()) {
			temp = variables.transport.theApplication.factories.transient['getCron' & arguments.cron & 'for' & arguments.plugin](variables.transport, variables.datasource, arguments.task);
			
			return temp;
		} else if (fileExists('/plugins/' & arguments.plugin & '/extend/cron/cron/cron' & arguments.cron & '.cfc')) {
			variables.transport.theApplication.factories.transient['setCron' & arguments.cron & 'for' & arguments.plugin]('plugins.' & arguments.plugin & '.extend.cron.cron.cron' & arguments.cron);
			
			return createObject('component', 'plugins.' & arguments.plugin & '.extend.cron.cron.cron' & arguments.cron).init(variables.transport, variables.datasource, arguments.task);
		} else {
			throw( message="Missing Cron", detail="Could not find the #arguments.cron# cron for the #arguments.plugin# plugin");
		}
	}
}
