<cfset viewTask = views.get('cron', 'task') />

<cfset filter = {
	'search' = theURL.search('search')
} />

<cfoutput>
	#viewTask.filter( filter )#
</cfoutput>
