javascript: (function() {
  var to = function(a) {
      window.open('https://amatsuka.herokuapp.com/extract/' + a);
    },
    check = function() {
      var a = location.hostname;
      if (['tweetdeck.twitter.com', 'twitter.com'].includes(a)) {
        if ('tweetdeck.twitter.com' === a) {
          var b = $('.mdl .username').text(),
            c = $('.mdl .username')
              .children()
              .text(),
            b = b.replace(c, '');
          to(b);
        }
        'twitter.com' === a &&
          ((a = $('.Gallery-content .username').text()),
          (b = $('.ProfileHeaderCard-screennameLink').text()),
          'none' === $('.GalleryNav').css('display')
            ? to(b)
            : (a || b) && to(a || b));
      }
    };
  check();
})();
