<cfscript>
	profiler = request.managers.singleton.getProfiler();
	
	profiler.start('startup');
	
	// Setup a transport object to transport scopes
	transport = {
		theApplication = application,
		theCGI = cgi,
		theCookie = cookie,
		theForm = form,
		theRequest = request,
		theServer = server,
		theSession = session,
		theUrl = url
	};
	
	// Retrieve the admin objects
	i18n = transport.theApplication.managers.singleton.getI18N();
	locale = transport.theSession.managers.singleton.getSession().getLocale();
	modelSerial = transport.theApplication.factories.transient.getModelSerial(transport);
	
	// Create and store the services manager
	services = transport.theApplication.factories.transient.getManagerService(transport);
	transport.theRequest.managers.singleton.setManagerService(services);
	
	// Create and store the model manager
	models = transport.theApplication.factories.transient.getManagerModel(transport, i18n, locale);
	transport.theRequest.managers.singleton.setManagerModel(models);
	
	// Create and store the view manager
	views = transport.theApplication.factories.transient.getManagerView(transport);
	transport.theRequest.managers.singleton.setManagerView(views);
	
	// Create and store the api manager
	crons = transport.theApplication.factories.transient.getManagerCron(transport);
	transport.theRequest.managers.singleton.setManagerCron(crons);
	
	profiler.stop('startup');
	
	profiler.start('processing');
	
	// Make the request last a long time if needed
	setting requesttimeout="500";
	
	servTask = services.get('cron', 'task');
	servUnit = services.get('cron', 'unit');
	
	if(!structKeyExists(transport.theUrl, 'task')) {
		writeOutput('<div>No task found to run.</div>');
		
		abort;
	}
	
	tasks = servTask.getTasks({ 'task': transport.theUrl.task });
	
	if(tasks.recordCount == 0) {
		writeOutput('<div>No matching <strong>tasks</strong> found.</div>');
		abort;
	}
	
	task = servTask.getTask( tasks.taskID );
	
	units = servUnit.getUnits({
		taskID: task.getTaskID()
	});
	
	if(units.recordCount == 0) {
		writeOutput('<div>No <strong>units</strong> found for the <strong>#task.getTask()#</strong> task.</div>');
		abort;
	}
	
	writeOutput('<pre>');
	
	writeOutput('<div>Starting the `<strong>' & task.getTask() & '</strong>` task.</div>');
	
	writeOutput('<dl>');
	
	// Execute all waiting crons
	for(i = 1; i <= units.recordCount; i++) {
		writeOutput('<dt>Running the `<strong>#units.cron[i]#</strong>` cron in the `<strong>#units.plugin[i]#</strong>` plugin</dt>')
		
		try {
			cron = crons.get(units.plugin[i], units.cron[i], task);
			
			cron.execute(deserializeJson(units.options[i]));
			
			writeOutput('<dd><em>Completed Normally.</em></dd>')
		} catch( any exception ) {
			getPageContext().getResponse().setStatus(500, 'Internal Server Error');
			
			transport.theSession.managers.singleton.getErrorLog().log(exception);
			
			writeOutput('<dd><strong><em>Error!</em></strong></dd>')
		}
	}
	
	writeOutput('</dl>');
	
	writeOutput('<div>Finished the `<strong>' & task.getTask() & '</strong>` task.</div>');
	
	writeOutput('</pre>');
	
	profiler.stop('processing');
</cfscript>
