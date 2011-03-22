component extends="algid.inc.resource.base.service" {
	public component function init( required struct transport ) {
		super.init(arguments.transport);
		
		variables.prefix = variables.transport.theApplication.managers.plugin.getCron().getCron().prefix;
		
		return this;
	}
	
	public query function getTasks(required string password, struct filter = {}) {
		schedule action="list" returnvariable="local.allTasks";
		
		query dbtype="query" name="local.tasks" {
			// Filter down to just the cron tasks
			writeOutput( "SELECT *, RIGHT(task, LENGTH( task ) - #len(variables.prefix)#) AS taskName " );
			writeOutput( "FROM local.allTasks " );
			writeOutput( "WHERE task LIKE ('#variables.prefix#%') " );
			writeOutput( "ORDER BY task ASC" );
		}
		
		return local.tasks;
	}
}
