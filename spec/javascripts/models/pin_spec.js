describe('Transbucket.Models.Pin', function() {
    it('should be defined', function() {
        expect(Transbucket.Models.Pin).toBeDefined();
    });

    it('can be instantiated', function() {
        var pin = new Transbucket.Models.Pin();
        expect(pin).not.toBeNull();
    });
});

describe('Transbucket.Models.Pin', function() {
    beforeEach(function() {
        this.task = new Transbucket.Models.Pin();
    });

    describe('new instance default values', function() {
        it('has default value for the .name attribute', function() {
            expect(this.task.get('name')).toEqual('');
        });

        it('has default value for the .complete attribute', function() {
            expect(this.task.get('complete')).toBeFalsy();
        });
    });
});