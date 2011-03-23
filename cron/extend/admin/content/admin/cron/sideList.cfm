<cfset viewTask = views.get('cron', 'task') />

<cfset filter = {
	'search' = theURL.search('search')
} />

<cfoutput>
	#viewCron.filter( filter )#
</cfoutput>
