describe('Transbucket.Models.Pin', function() {
    it('should be defined', function() {
        expect(Transbucket.Models.Pin).toBeDefined();
    });

    it('can be instantiated', function() {
        var pin = new Transbucket.Models.Pin();
        expect(pin).not.toBeNull();
    });
});
