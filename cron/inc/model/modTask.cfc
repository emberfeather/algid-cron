component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, required string locale) {
		super.init(arguments.i18n, arguments.locale);
		
		// Set the bundle information for translation
		add__bundle('plugins/cron/i18n/inc/model', 'modTask');
		
		// Task ID
		add__attribute(
			attribute = 'taskID'
		);
		
		// End Date
		add__attribute(
			attribute = 'endDate'
		);
		
		// End Time
		add__attribute(
			attribute = 'endTime'
		);
		
		// Interval
		add__attribute(
			attribute = 'interval'
		);
		
		// Port
		add__attribute(
			attribute = 'port'
		);
		
		// Start Date
		add__attribute(
			attribute = 'startDate'
		);
		
		// Start Time
		add__attribute(
			attribute = 'startTime'
		);
		
		// Task
		add__attribute(
			attribute = 'task'
		);
		
		// Timeout
		add__attribute(
			attribute = 'timeout'
		);
		
		// Url
		add__attribute(
			attribute = 'url'
		);
		
		return this;
	}
	
	void function setInterval( any interval ) {
		if(isSimpleValue(arguments.interval)) {
			switch (arguments.interval) {
			case 'daily':
				arguments.interval = 86400; // Seconds in a day
				
				break;
			case 'once':
				arguments.interval = 0;
				
				break;
			case 'monthly':
				arguments.interval = 2592000; // Seconds in 30 days
				
				break;
			case 'weekly':
				arguments.interval = 604800; // Seconds in a week
				
				break;
			}
		}
		
		super.setInterval(arguments.interval);
	}
}
