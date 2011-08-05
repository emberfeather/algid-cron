<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="deleteUnit" access="public" returntype="void" output="false">
		<cfargument name="unit" type="component" required="true" />
		
		<cfset local.observer = getPluginObserver('cron', 'unit') />
		
		<cfset local.observer.beforeArchive(variables.transport, arguments.unit) />
		
		<cftransaction>
			<cfquery datasource="#variables.datasource.name#">
				DELETE FROm "#variables.datasource.prefix#cron"."unit"
				WHERE
					"unitID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getUnitID()#" />::uuid
			</cfquery>
		</cftransaction>
		
		<cfset local.observer.afterArchive(variables.transport, arguments.unit) />
	</cffunction>
	
	<cffunction name="getUnit" access="public" returntype="component" output="false">
		<cfargument name="unitID" type="string" required="true" />
		
		<cfset local.unit = getModel('cron', 'unit') />
		
		<cfif not len(arguments.unitID)>
			<cfreturn local.unit />
		</cfif>
		
		<cfquery name="local.results" datasource="#variables.datasource.name#">
			SELECT "unitID", "taskID", "plugin", "cron", "options"
			FROM "#variables.datasource.prefix#cron"."unit"
			WHERE "unitID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unitID#" null="#arguments.unitID eq ''#" />::uuid
		</cfquery>
		
		<cfif local.results.recordCount>
			<cfset local.modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport) />
			
			<cfset local.modelSerial.deserialize(local.results, local.unit) />
			
			<cfset local.unit.setOptions(deserializeJson(local.results.options)) />
		</cfif>
		
		<cfreturn local.unit />
	</cffunction>
	
	<cffunction name="getUnits" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<!--- Expand the with defaults --->
		<cfset arguments.filter = extend({
			orderBy = 'plugin',
			orderSort = 'asc'
		}, arguments.filter) />
		
		<cfquery name="local.results" datasource="#variables.datasource.name#">
			SELECT DISTINCT "unitID", "taskID", "plugin", "cron", "options"
			FROM "#variables.datasource.prefix#cron"."unit"
			WHERE 1=1
			
			<cfif structKeyExists(arguments.filter, 'search') and arguments.filter.search neq ''>
				AND (
					"cron" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
					OR "plugin" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
				)
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'plugin') and arguments.filter.plugin neq ''>
				AND "plugin" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.plugin#" />
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'taskID') and arguments.filter.taskID neq ''>
				AND "taskID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.taskID#" />::uuid
			</cfif>
			
			ORDER BY
			<cfswitch expression="#arguments.filter.orderBy#">
				<cfdefaultcase>
					"plugin" #arguments.filter.orderSort#,
					"cron" #arguments.filter.orderSort#
				</cfdefaultcase>
			</cfswitch>
			
			<cfif structKeyExists(arguments.filter, 'limit')>
				LIMIT <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter.limit#" />
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'offset')>
				OFFSET <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter.offset#" />
			</cfif>
		</cfquery>
		
		<cfreturn local.results />
	</cffunction>
	
	<cffunction name="setUnit" access="public" returntype="void" output="false">
		<cfargument name="unit" type="component" required="true" />
		
		<cfset local.observer = getPluginObserver('cron', 'unit') />
		
		<cfset scrub__model(arguments.unit) />
		<cfset validate__model(arguments.unit) />
		
		<cfset local.observer.beforeSave(variables.transport, arguments.unit) />
		
		<cfif arguments.unit.getUnitID() eq ''>
			<!--- Insert as a new unit --->
			<cfset arguments.unit.setUnitID( createUUID() ) />
			
			<cfset local.observer.beforeCreate(variables.transport, arguments.unit) />
			
			<cftransaction>
				<cfquery datasource="#variables.datasource.name#">
					INSERT INTO "#variables.datasource.prefix#cron"."unit"
					(
						"unitID",
						"taskID",
						"plugin",
						"cron",
						"options"
					) VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getUnitID()#" />::uuid,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getTaskID()#" />::uuid,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getPlugin()#" />,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getCron()#" />,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJson(arguments.unit.getOptions())#" />::text
					)
				</cfquery>
			</cftransaction>
			
			<cfset local.observer.afterCreate(variables.transport, arguments.unit) />
		<cfelse>
			<cfset local.observer.beforeUpdate(variables.transport, arguments.unit) />
			
			<cftransaction>
				<cfquery datasource="#variables.datasource.name#">
					UPDATE "#variables.datasource.prefix#cron"."unit"
					SET
						"taskID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getTaskID()#" />::uuid,
						"plugin" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getPlugin()#" />,
						"cron" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getCron()#" />
						"options" = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJson(arguments.unit.getOptions())#" />::text
					WHERE
						"unitID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit.getUnitID()#" />::uuid
				</cfquery>
			</cftransaction>
			
			<cfset local.observer.afterUpdate(variables.transport, arguments.unit) />
		</cfif>
		
		<cfset local.observer.afterSave(variables.transport, arguments.unit) />
	</cffunction>
</cfcomponent>
