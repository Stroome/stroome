(function(j) {

j.fn.accordionGallery = function(opts) {
  opts = j.extend({
    interval: 6000,
    speed: 600
  }, opts || {});

  // When there is not children, then we just skip
  if (!this.children().length) { return this; }

  var items = this.children()
    , first = items.first()
    , current = first
    , clk = 'click'
    , itemCls = 'ag-item'
    , currentIndex = 0
    , len = items.length
    , expandedWidth = current.width()
    , minimizedWidth = current.next().width()
    , prev, timeoutId;

  current.css( 'width', expandedWidth );
  current.nextAll().css( 'width', minimizedWidth );

  // Add class to LIs to easier to locate the root later
  items.addClass(itemCls);

  this.find('.ag-container')
    .find('a')
    .not('.register')
    .bind(clk, function(e) {
      e.preventDefault();
    });

  items.bind(clk, function(e) {
    var target = $(e.target)
      , item = $(this)
      , canGo = !target.is('.register') &&
                 target.is('a') &&
                 item.index() !== current.index();

    canGo && next( target.index() === len-1 ? first : $(this) );
  });

  function cycle() {
    timeoutId = setTimeout(function() {
      next(
        current.index() === len-1 ? 
          first : current.next()
      );
    }, opts.interval);
  }

  function next(item) {

    prev = current;
    current = item;
    currentIndex = item.index();

    prev
      .animate({width: minimizedWidth}, opts.speed)
      .removeClass('active');
    item
      .animate({width: expandedWidth}, opts.speed)
      .addClass('active');

    clearTimeout(timeoutId);
    cycle();
  }

  cycle();
}

})(jQuery);