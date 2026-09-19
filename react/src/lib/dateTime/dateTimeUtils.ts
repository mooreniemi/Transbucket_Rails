export function formatDateTime(datetime: Date, includeTime = false, locale = 'US-EN', timezone?: string) {
    const formatterOptions: Intl.DateTimeFormatOptions = {
        dateStyle: 'medium',
        timeZone: timezone
    };

    if (includeTime) formatterOptions.timeStyle = 'medium';
    
    if (timezone) formatterOptions.timeZone = timezone;
    
    const formatter = Intl.DateTimeFormat(locale, formatterOptions);
    return formatter.format(datetime);
}

export function sinceDate(datetime: Date) {

}

export function fromISOString(datetime: string) {
    
}
