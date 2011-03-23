<cfset tasks = servTask.getTasks('Testing', filter) />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(tasks.recordCount, session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, tasks, viewTask, paginate, filter)#</cfoutput>
