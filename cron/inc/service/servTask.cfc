component extends="algid.inc.resource.base.service" {
	public component function init( required struct transport ) {
		super.init(arguments.transport);
		
		variables.prefix = variables.transport.theApplication.managers.plugin.getCron().getCron().prefix;
		
		return this;
	}
	
	public query function getScheduledTasks(struct filter = {}) {
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
	
	public component function getTask(required string taskID) {
		local.task = getModel('cron', 'task');
		
		if ( !len(arguments.taskID)) {
			return local.task;
		}
		
		query name="local.results" datasource="#variables.datasource.name#" {
			// Filter down to just the cron tasks
			writeOutput( 'SELECT "taskID", "task" ' );
			writeOutput( 'FROM "#variables.datasource.prefix#cron"."task" ' );
			writeOutput( 'WHERE "taskID" = ' );
			
			queryparam value="#arguments.taskID#" cfsqltype="cf_sql_varchar";
			
			writeOutput( '::uuid' );
		}
		
		if (local.results.recordCount) {
			local.modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport);
			
			local.modelSerial.deserialize(local.results, local.task);
			
			schedule action="list" returnvariable="local.allTasks";
			
			query dbtype="query" name="local.tasks" {
				// Filter down to just the cron tasks
				writeOutput( "SELECT startDate, endDate, startTime, endTime, url, port, interval, timeout " );
				writeOutput( "FROM local.allTasks " );
				writeOutput( "WHERE task = " );
				
				queryparam value="#variables.prefix##local.results.task#" cfsqltype="cf_sql_varchar";
			}
			
			local.modelSerial.deserialize(local.tasks, local.task);
		}
		
		return local.task;
	}
	
	public query function getTasks(struct filter = {}) {
		arguments.filter = extend({
			orderBy = 'task',
			orderSort = 'asc'
		}, arguments.filter)
		
		query name="local.results" datasource="#variables.datasource.name#" {
			// Filter down to just the cron tasks
			writeOutput( 'SELECT "taskID", "task" ' );
			writeOutput( 'FROM "#variables.datasource.prefix#cron"."task" ' );
			writeOutput( 'WHERE 1 = 1 ' );
			
			if (structKeyExists(arguments.filter, 'search') and arguments.filter.search neq '') {
				writeOutput( 'AND ( "task" LIKE ' );
				
				queryparam value="%#arguments.filter.search#%" cfsqltype="cf_sql_varchar";
				
				writeOutput( ' ) ' );
			}
			
			if (structKeyExists(arguments.filter, 'task') and arguments.filter.task neq '') {
				writeOutput( 'AND "task" = ' );
				
				queryparam value="#arguments.filter.task#" cfsqltype="cf_sql_varchar";
			}
		}
		
		return local.results;
	}
}
