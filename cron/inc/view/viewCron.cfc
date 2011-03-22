<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="datagrid" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		
		<cfset arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL() />
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset datagrid.addBundle('plugins/cron/i18n/inc/view', 'viewCron') />
		
		<cfset datagrid.addColumn({
			key = 'taskName',
			label = 'task',
			link = {
				'task' = 'taskName',
			}
		}) />
		
		<cfset datagrid.addColumn({
			key = 'interval',
			label = 'interval'
		}) />
		
		<cfset datagrid.addColumn({
			class = 'phantom align-right',
			value = [ 'delete', 'edit' ],
			link = [
				{
					'task' = 'taskName',
					'_base' = '/admin/cron/delete'
				},
				{
					'task' = 'taskName',
					'_base' = '/admin/cron/edit'
				}
			],
			linkClass = [ 'delete', '' ],
			title = 'taskName'
		}) />
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
	
	<cffunction name="filter" access="public" returntype="string" output="false">
		<cfargument name="values" type="struct" default="#{}#" />
		
		<cfset var filter = '' />
		<cfset var i = '' />
		<cfset var options = '' />
		<cfset var results = '' />
		
		<cfset filter = variables.transport.theApplication.factories.transient.getFilterVertical(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filter.addBundle('plugins/cron/i18n/inc/view', 'viewCron') />
		
		<!--- Search --->
		<cfset filter.addFilter('search') />
		
		<cfreturn filter.toHTML(variables.transport.theRequest.managers.singleton.getURL(), arguments.values) />
	</cffunction>
	
	<cffunction name="filterActive" access="public" returntype="string" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var filterActive = '' />
		<cfset var options = '' />
		<cfset var results = '' />
		
		<cfset filterActive = variables.transport.theApplication.factories.transient.getFilterActive(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filterActive.addBundle('plugins/cron/i18n/inc/view', 'viewCron') />
		
		<cfreturn filterActive.toHTML(arguments.filter, variables.transport.theRequest.managers.singleton.getURL()) />
	</cffunction>
	
	<cffunction name="login" access="public" returntype="string" output="false">
		<cfsavecontent variable="local.html">
			TODO Login Form
		</cfsavecontent>
		
		<cfreturn local.html />
	</cffunction>
</cfcomponent>
