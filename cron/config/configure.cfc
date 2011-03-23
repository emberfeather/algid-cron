<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
<cfscript>
	public void function onApplicationStart(required struct theApplication) {
		// Get the plugin
		local.plugin = arguments.theApplication.managers.plugin.getCron();
		
		// Check for control of the main application index
		local.pluginHandlerDir = '/root/' & local.plugin.getPath();
		
		if(!directoryExists(local.pluginHandlerDir)) {
			directoryCreate(local.pluginHandlerDir);
		}
		
		if(!fileExists(local.pluginHandlerDir & 'index.cfm')) {
			fileWrite(local.pluginHandlerDir & 'index.cfm', '<!--- This application is controlled by the cron plugin --->' & chr(10) & '<cfinclude template="/plugins/cron/inc/wrapper.cfm" />' & chr(10));
		}
	}
</cfscript>
	<!---
		Configures the database for v0.1.0
	--->
	<cffunction name="postgreSQL0_1_0" access="public" returntype="void" output="false">
		<cfset var i = '' />
		
		<!---
			SCHEMA
		--->
		
		<!--- Cron Schema --->
		<cfquery datasource="#variables.datasource.name#">
			CREATE SCHEMA "#variables.datasource.prefix#cron"
				AUTHORIZATION #variables.datasource.owner#;
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			COMMENT ON SCHEMA "#variables.datasource.prefix#cron" IS 'Cron Plugin Schema';
		</cfquery>
		
		<!---
			TABLES
		--->
		
		<!--- Task Table --->
		<cfquery datasource="#variables.datasource.name#">
			CREATE TABLE "#variables.datasource.prefix#cron"."task"
			(
				"taskID" uuid NOT NULL,
				task character varying NOT NULL,
					CONSTRAINT task_pkey PRIMARY KEY ("taskID"),
					CONSTRAINT task_task_key UNIQUE (task)
			)
			WITH (OIDS=FALSE);
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#cron"."task" OWNER TO #variables.datasource.owner#;
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			COMMENT ON TABLE "#variables.datasource.prefix#cron"."task" IS 'Tasks being administered by the cron plugin.';
		</cfquery>
		
		<!--- Unit Table --->
		<cfquery datasource="#variables.datasource.name#">
			CREATE TABLE "#variables.datasource.prefix#cron"."unit"
			(
				"unitID" uuid NOT NULL, 
				"taskID" uuid NOT NULL, 
				plugin character varying(75) NOT NULL,
				cron character varying(75) NOT NULL,
				options text NOT NULL DEFAULT '{}'::text,
					CONSTRAINT unit_pkey PRIMARY KEY ("unitID"),
					CONSTRAINT "unit_taskID_fkey" FOREIGN KEY ("taskID")
						REFERENCES "#variables.datasource.prefix#cron".task ("taskID") MATCH SIMPLE
						ON UPDATE CASCADE ON DELETE CASCADE,
					CONSTRAINT "unit_taskID_key" UNIQUE ("taskID", plugin, cron)
			)
			WITH (OIDS=FALSE);
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#cron"."task" OWNER TO #variables.datasource.owner#;
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			COMMENT ON TABLE "#variables.datasource.prefix#cron"."task" IS 'Tasks being administered by the cron plugin.';
		</cfquery>
	</cffunction>
<cfscript>
	public void function update( required struct plugin, string installedVersion = '' ) {
		var versions = createObject('component', 'algid.inc.resource.utility.version').init();
		
		// fresh => 0.1.0
		if (versions.compareVersions(arguments.installedVersion, '0.1.0') lt 0) {
			switch (variables.datasource.type) {
			case 'PostgreSQL':
				postgreSQL0_1_0();
				
				break;
			default:
				throw(message="Database Type Not Supported", detail="The #variables.datasource.type# database type is not currently supported");
			}
		}
	}
</cfscript>
	<!--- TODO Remove when Railo supports directoryCreate() --->
	<cffunction name="directoryCreate" access="public" returntype="void" output="false">
		<cfargument name="path" type="string" required="true" />
		
		<cfdirectory action="create" directory="#arguments.path#" />
	</cffunction>
</cfcomponent>
