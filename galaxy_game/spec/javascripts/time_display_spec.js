// spec/javascripts/time_display_spec.js
describe('Game time display', function() {
  it('updates the display when time advances', function() {
    // Setup
    document.body.innerHTML = `
      <div class="current-time">Year: 0 | Day: 0</div>
    `;
    
    // Call the function
    updateTimeDisplay({ year: 2, day: 45 });
    
    // Assert the display was updated
    expect(document.querySelector('.current-time').textContent)
      .toEqual('Year: 2 | Day: 45');
  });
});