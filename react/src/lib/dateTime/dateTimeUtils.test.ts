import { describe, expect, it } from 'vitest'
import { formatDateTime } from './dateTimeUtils'

describe('dateTimeUtils', () => {
    it('should format date correctly', () => {
        const date = new Date('2024-06-01T12:00:00Z');
        const formattedDate = formatDateTime(date);
        expect(formattedDate).toBe('Jun 1, 2024');
    });

    it('should format date and time correctly', () => {
        const date = new Date('2024-06-01T12:00:00Z');
        const formattedDateTime = formatDateTime(date, true, undefined, 'UTC');
        expect(formattedDateTime).toBe('Jun 1, 2024, 12:00:00 PM');
    });

    it('should internationalize date correctly for locale', () => {
        const date = new Date('2024-06-01T12:00:00Z');
        const formattedDate = formatDateTime(date, false, 'fr-FR');
        expect(formattedDate).toBe('1 juin 2024');
    });

    it('should internationalize date and time correctly for locale', () => {
        const date = new Date('2024-06-01T12:00:00Z');
        const formattedDateTime = formatDateTime(date, true, 'fr-FR', 'UTC');
        expect(formattedDateTime).toBe('1 juin 2024, 12:00:00');
    });

    it('should error when given an invalid date', () => {
        const invalidDate = new Date('invalid-date-string');
        expect(() => formatDateTime(invalidDate)).toThrow('Invalid time value');
    });
});
